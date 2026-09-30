import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import 'journal_repository.dart' show NamedDose;
import 'local_db.dart';
import 'models.dart';

DateTime _local(String value) => DateTime.parse(value).toLocal();
DateTime? _localOrNull(Object? value) => value == null ? null : _local(value as String);

/// A time the baby was unwell, from [startedAt] until [recoveredAt] (null
/// while still unwell).
class Illness {
  const Illness({required this.id, required this.startedAt, this.name, this.recoveredAt, this.notes});

  final String id;
  final String? name;
  final DateTime startedAt;
  final DateTime? recoveredAt;
  final String? notes;

  bool get ongoing => recoveredAt == null;

  /// Day 1 is the day it started (calendar days, so a fever that began at
  /// 11 pm is on day 2 the next morning).
  int dayNumber(DateTime at) {
    final start = DateTime.utc(startedAt.year, startedAt.month, startedAt.day);
    final day = DateTime.utc(at.year, at.month, at.day);
    return day.difference(start).inDays + 1;
  }

  /// How many days it lasted (or has lasted so far).
  int days(DateTime now) => dayNumber(recoveredAt ?? now);

  factory Illness.fromJson(Map<String, dynamic> json) => Illness(
        id: json['id'] as String,
        name: json['name'] as String?,
        startedAt: _local(json['started_at'] as String),
        recoveredAt: _localOrNull(json['recovered_at']),
        notes: json['notes'] as String?,
      );
}

class DoctorVisit {
  const DoctorVisit({required this.id, required this.visitedAt, this.doctor, this.diagnosis, this.advice});

  final String id;
  final DateTime visitedAt;
  final String? doctor;
  final String? diagnosis;
  final String? advice;

  factory DoctorVisit.fromJson(Map<String, dynamic> json) => DoctorVisit(
        id: json['id'] as String,
        visitedAt: _local(json['visited_at'] as String),
        doctor: json['doctor'] as String?,
        diagnosis: json['diagnosis'] as String?,
        advice: json['advice'] as String?,
      );
}

/// Everything logged during one illness.
class IllnessEpisode {
  const IllnessEpisode({
    required this.illness,
    this.symptoms = const [],
    this.doses = const [],
    this.visits = const [],
  });

  final Illness illness;

  /// Oldest first.
  final List<SymptomLog> symptoms;
  final List<NamedDose> doses;
  final List<DoctorVisit> visits;

  /// The symptoms seen so far, most frequent first (codes, e.g. 'fever').
  List<String> get symptomCodes {
    final counts = <String, int>{};
    for (final s in symptoms) {
      counts[s.symptom] = (counts[s.symptom] ?? 0) + 1;
    }
    return counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  }

  SymptomLog? get lastTemperature => symptoms.lastWhereOrNull((s) => s.temperatureC != null);

  SymptomLog? get highestTemperature {
    SymptomLog? best;
    for (final s in symptoms) {
      if (s.temperatureC != null && (best == null || s.temperatureC! > best.temperatureC!)) best = s;
    }
    return best;
  }

  int dosesOn(DateTime day) => doses.where((d) => !d.dose.skipped && _sameDay(d.dose.givenAt, day)).length;
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}

class IllnessRepository {
  IllnessRepository(this._db);

  final PowerSyncDatabase _db;

  static const _illnessColumns = 'id, name, started_at, recovered_at, notes';
  static const _visitColumns = 'id, visited_at, doctor, diagnosis, advice';

  /// Every illness for the baby, newest first.
  Stream<List<Illness>> watchAll(String babyId) => _db
      .watch(
        'SELECT $_illnessColumns FROM illnesses WHERE baby_id = ? AND deleted_at IS NULL '
        'ORDER BY julianday(started_at) DESC',
        parameters: [babyId],
      )
      .map((rows) => rows.map(Illness.fromJson).toList());

  Future<IllnessEpisode?> episode(String babyId, String illnessId) async {
    final rows = await _db.getAll(
      'SELECT $_illnessColumns FROM illnesses WHERE id = ? AND deleted_at IS NULL',
      [illnessId],
    );
    if (rows.isEmpty) return null;
    final illness = Illness.fromJson(rows.first);
    final from = utcTimestamp(illness.startedAt);
    // Until recovered, or open-ended (anything logged later still counts).
    final to = utcTimestamp(illness.recoveredAt ?? DateTime(9999));
    final symptoms = await _db.getAll(
      'SELECT id, symptom, occurred_at, temperature_c, severity, notes FROM symptom_logs '
      'WHERE baby_id = ? AND deleted_at IS NULL '
      'AND julianday(occurred_at) >= julianday(?) AND julianday(occurred_at) <= julianday(?) '
      'ORDER BY julianday(occurred_at)',
      [babyId, from, to],
    );
    final doses = await _db.getAll(
      'SELECT d.id, d.medication_id, d.given_at, d.skipped, d.scheduled_for, m.name AS medicine '
      'FROM medication_doses d JOIN medications m ON m.id = d.medication_id '
      'WHERE d.baby_id = ? AND d.deleted_at IS NULL '
      'AND julianday(d.given_at) >= julianday(?) AND julianday(d.given_at) <= julianday(?) '
      'ORDER BY julianday(d.given_at)',
      [babyId, from, to],
    );
    final visits = await _db.getAll(
      'SELECT $_visitColumns FROM doctor_visits WHERE baby_id = ? AND deleted_at IS NULL '
      'AND julianday(visited_at) >= julianday(?) AND julianday(visited_at) <= julianday(?) '
      'ORDER BY julianday(visited_at)',
      [babyId, from, to],
    );
    return IllnessEpisode(
      illness: illness,
      symptoms: symptoms.map(SymptomLog.fromJson).toList(),
      doses: [for (final d in doses) (dose: MedicationDose.fromJson(d), medicine: d['medicine'] as String)],
      visits: visits.map(DoctorVisit.fromJson).toList(),
    );
  }

  Stream<IllnessEpisode?> watchEpisode(String babyId, String illnessId) => watchTables(
        _db,
        const ['illnesses', 'symptom_logs', 'medication_doses', 'medications', 'doctor_visits'],
        () => episode(babyId, illnessId),
      );

  /// Doctor's visits since [from], oldest first (for the journal).
  Future<List<DoctorVisit>> visitsBetween(String babyId, DateTime from, DateTime to) async => (await _db.getAll(
        'SELECT $_visitColumns FROM doctor_visits WHERE baby_id = ? AND deleted_at IS NULL '
        'AND julianday(visited_at) >= julianday(?) AND julianday(visited_at) < julianday(?) '
        'ORDER BY julianday(visited_at)',
        [babyId, utcTimestamp(from), utcTimestamp(to)],
      ))
          .map(DoctorVisit.fromJson)
          .toList();

  Future<void> saveIllness(
    Baby baby, {
    String? existingId,
    String? name,
    required DateTime startedAt,
    DateTime? recoveredAt,
    String? notes,
  }) async {
    final fields = {
      'name': name,
      'started_at': utcTimestamp(startedAt),
      'recovered_at': recoveredAt == null ? null : utcTimestamp(recoveredAt),
      'notes': notes,
    };
    if (existingId != null) return updateRow(_db, 'illnesses', existingId, fields);
    await insertRow(_db, 'illnesses', {'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> setRecovered(String id, DateTime? at) =>
      updateRow(_db, 'illnesses', id, {'recovered_at': at == null ? null : utcTimestamp(at)});

  Future<void> deleteIllness(String id) =>
      updateRow(_db, 'illnesses', id, {'deleted_at': utcTimestamp(DateTime.now())});

  Future<void> saveVisit(
    Baby baby, {
    String? existingId,
    required DateTime visitedAt,
    String? doctor,
    String? diagnosis,
    String? advice,
  }) async {
    final fields = {
      'visited_at': utcTimestamp(visitedAt),
      'doctor': doctor,
      'diagnosis': diagnosis,
      'advice': advice,
    };
    if (existingId != null) return updateRow(_db, 'doctor_visits', existingId, fields);
    await insertRow(_db, 'doctor_visits', {'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> deleteVisit(String id) =>
      updateRow(_db, 'doctor_visits', id, {'deleted_at': utcTimestamp(DateTime.now())});
}

final illnessRepositoryProvider = Provider((ref) => IllnessRepository(ref.watch(powerSyncProvider)));

final illnessesProvider = StreamProvider.family<List<Illness>, String>(
  (ref, babyId) => ref.watch(illnessRepositoryProvider).watchAll(babyId),
);

final illnessEpisodeProvider = StreamProvider.autoDispose.family<IllnessEpisode?, ({String babyId, String illnessId})>(
  (ref, key) => ref.watch(illnessRepositoryProvider).watchEpisode(key.babyId, key.illnessId),
);

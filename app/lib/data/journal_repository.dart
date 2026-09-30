import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import 'illness_repository.dart';
import 'local_db.dart';
import 'models.dart';
import 'solids_repository.dart';

/// A medicine dose with the medicine's name, for the journal.
typedef NamedDose = ({MedicationDose dose, String medicine});

/// Everything logged for a baby on one calendar day.
class JournalDay {
  const JournalDay({
    required this.day,
    required this.log,
    this.pumping = const [],
    this.doses = const [],
    this.symptoms = const [],
    this.foodTries = const [],
    this.growth = const [],
    this.vaccinations = const [],
    this.milestones = const [],
    this.visits = const [],
  });

  final DateTime day;

  /// Feeds, diapers and sleeps (a sleep crossing midnight is on both days).
  final TodayLog log;
  final List<PumpingSession> pumping;
  final List<NamedDose> doses;
  final List<SymptomLog> symptoms;

  // These have a date but no time.
  final List<FoodTry> foodTries;
  final List<GrowthMeasurement> growth;
  final List<Vaccination> vaccinations;
  final List<MilestoneCheck> milestones;

  final List<DoctorVisit> visits;

  bool get isEmpty =>
      log.feeds.isEmpty &&
      log.diapers.isEmpty &&
      log.sleeps.isEmpty &&
      pumping.isEmpty &&
      doses.isEmpty &&
      symptoms.isEmpty &&
      foodTries.isEmpty &&
      growth.isEmpty &&
      vaccinations.isEmpty &&
      milestones.isEmpty &&
      visits.isEmpty;
}

class JournalRepository {
  JournalRepository(this._db);

  final PowerSyncDatabase _db;

  static const _tables = [
    'feeds',
    'diapers',
    'sleeps',
    'pumping_sessions',
    'medication_doses',
    'medications',
    'symptom_logs',
    'food_tries',
    'growth_measurements',
    'vaccinations',
    'milestone_checks',
    'doctor_visits',
  ];

  Future<JournalDay> load(String babyId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day + 1);
    final from = utcTimestamp(start), to = utcTimestamp(end), date = dateOnly(start);

    Future<List<Map<String, dynamic>>> inRange(String table, String columns, String timeColumn) => _db.getAll(
          'SELECT $columns FROM $table WHERE baby_id = ? AND deleted_at IS NULL '
          'AND julianday($timeColumn) >= julianday(?) AND julianday($timeColumn) < julianday(?)',
          [babyId, from, to],
        );
    Future<List<Map<String, dynamic>>> onDate(String table, String columns, String dateColumn) => _db.getAll(
          'SELECT $columns FROM $table WHERE baby_id = ? AND deleted_at IS NULL AND $dateColumn = ?',
          [babyId, date],
        );

    final feeds = await inRange(
      'feeds',
      'id, type, side, started_at, ended_at, amount_ml, left_seconds, right_seconds, timer_side, timer_started_at',
      'started_at',
    );
    final diapers = await inRange('diapers', 'id, occurred_at, is_wet, is_dirty', 'occurred_at');
    final sleeps = await _db.getAll(
      'SELECT id, kind, started_at, ended_at FROM sleeps WHERE baby_id = ? AND deleted_at IS NULL '
      'AND julianday(started_at) < julianday(?) AND (ended_at IS NULL OR julianday(ended_at) > julianday(?))',
      [babyId, to, from],
    );
    final pumping = await inRange('pumping_sessions', 'id, side, started_at, ended_at, amount_ml', 'started_at');
    final doses = await _db.getAll(
      'SELECT d.id, d.medication_id, d.given_at, d.skipped, d.scheduled_for, m.name AS medicine '
      'FROM medication_doses d JOIN medications m ON m.id = d.medication_id '
      'WHERE d.baby_id = ? AND d.deleted_at IS NULL '
      'AND julianday(d.given_at) >= julianday(?) AND julianday(d.given_at) < julianday(?)',
      [babyId, from, to],
    );
    final symptoms = await inRange(
      'symptom_logs',
      'id, symptom, occurred_at, temperature_c, severity, notes',
      'occurred_at',
    );
    final tries = await onDate('food_tries', 'id, food_id, tried_on, opinion, reaction, notes', 'tried_on');
    final growth = await onDate('growth_measurements', 'id, measured_on, weight_g, length_mm, head_mm', 'measured_on');
    final vaccinations = await onDate(
      'vaccinations',
      'id, vaccine_code, given_on, batch_number, clinic, notes',
      'given_on',
    );
    final milestones = await onDate('milestone_checks', 'id, milestone_id, achieved_on', 'achieved_on');
    final visits = await inRange('doctor_visits', 'id, visited_at, doctor, diagnosis, advice', 'visited_at');

    return JournalDay(
      day: start,
      log: TodayLog(
        dayStart: start,
        feeds: feeds.map(Feed.fromJson).toList(),
        diapers: diapers.map(Diaper.fromJson).toList(),
        sleeps: sleeps.map(Sleep.fromJson).toList(),
      ),
      pumping: pumping.map(PumpingSession.fromJson).toList(),
      doses: [for (final d in doses) (dose: MedicationDose.fromJson(d), medicine: d['medicine'] as String)],
      symptoms: symptoms.map(SymptomLog.fromJson).toList(),
      foodTries: tries.map(FoodTry.fromJson).toList(),
      growth: growth.map(GrowthMeasurement.fromJson).toList(),
      vaccinations: vaccinations.map(Vaccination.fromJson).toList(),
      milestones: [
        for (final m in milestones)
          MilestoneCheck(
            id: m['id'] as String,
            milestoneId: m['milestone_id'] as String,
            achievedOn: DateTime.parse(m['achieved_on'] as String),
          ),
      ],
      visits: visits.map(DoctorVisit.fromJson).toList(),
    );
  }

  Stream<JournalDay> watch(String babyId, DateTime day) => watchTables(_db, _tables, () => load(babyId, day));
}

final journalRepositoryProvider = Provider((ref) => JournalRepository(ref.watch(powerSyncProvider)));

/// One day of the journal for a baby, kept live.
final journalDayProvider = StreamProvider.autoDispose.family<JournalDay, ({String babyId, DateTime day})>(
  (ref, key) => ref.watch(journalRepositoryProvider).watch(key.babyId, key.day),
);

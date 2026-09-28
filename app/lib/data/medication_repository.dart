import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import 'local_db.dart';
import 'models.dart';

class MedicationRepository {
  MedicationRepository(this._db);

  final PowerSyncDatabase _db;

  static const _medicationsSql =
      'SELECT ${Medication.columns} FROM medications WHERE baby_id = ? AND deleted_at IS NULL ORDER BY start_date DESC';
  static const _dosesSql = 'SELECT id, medication_id, given_at, skipped, scheduled_for FROM medication_doses '
      'WHERE baby_id = ? AND deleted_at IS NULL AND julianday(given_at) >= julianday(?) '
      'ORDER BY julianday(given_at) DESC';

  Future<List<Medication>> all(String babyId) async =>
      (await _db.getAll(_medicationsSql, [babyId])).map(Medication.fromJson).toList();

  Stream<List<Medication>> watchAll(String babyId) =>
      _db.watch(_medicationsSql, parameters: [babyId]).map((rows) => rows.map(Medication.fromJson).toList());

  Future<List<MedicationDose>> dosesSince(String babyId, DateTime since) async =>
      (await _db.getAll(_dosesSql, [babyId, utcTimestamp(since)])).map(MedicationDose.fromJson).toList();

  /// Doses recorded in the last [days] days, newest first.
  Stream<List<MedicationDose>> watchRecentDoses(String babyId, {int days = 3}) => _db
      .watch(_dosesSql, parameters: [babyId, utcTimestamp(DateTime.now().subtract(Duration(days: days)))])
      .map((rows) => rows.map(MedicationDose.fromJson).toList());

  /// Adds a medicine, or updates [existingId].
  Future<void> save(
    Baby baby, {
    String? existingId,
    required String name,
    required String prescribedDose,
    required List<DoseTime> doseTimes,
    required bool asNeeded,
    required DateTime startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? notes,
  }) async {
    final fields = {
      'name': name,
      'prescribed_dose': prescribedDose,
      'dose_times': asNeeded ? <String>[] : [for (final t in doseTimes) t.toDb()],
      'as_needed': asNeeded,
      'start_date': dateOnly(startDate),
      'end_date': endDate == null ? null : dateOnly(endDate),
      'prescribed_by': prescribedBy,
      'notes': notes,
    };
    if (existingId != null) return updateRow(_db, 'medications', existingId, fields);
    await insertRow(_db, 'medications', {'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> delete(String id) => updateRow(_db, 'medications', id, {'deleted_at': utcTimestamp(DateTime.now())});

  /// Records a dose as given now (or skipped), for [scheduledFor] if it was
  /// a scheduled one.
  Future<void> recordDose(Baby baby, Medication medication, {DateTime? scheduledFor, bool skipped = false}) async {
    await insertRow(_db, 'medication_doses', {
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'medication_id': medication.id,
      'given_at': utcTimestamp(DateTime.now()),
      'skipped': skipped,
      'scheduled_for': scheduledFor == null ? null : utcTimestamp(scheduledFor),
    });
  }

  Future<void> undoDose(String doseId) =>
      updateRow(_db, 'medication_doses', doseId, {'deleted_at': utcTimestamp(DateTime.now())});
}

final medicationRepositoryProvider = Provider((ref) => MedicationRepository(ref.watch(powerSyncProvider)));

final medicationsProvider = StreamProvider.family<List<Medication>, String>(
  (ref, babyId) => ref.watch(medicationRepositoryProvider).watchAll(babyId),
);

final recentDosesProvider = StreamProvider.family<List<MedicationDose>, String>(
  (ref, babyId) => ref.watch(medicationRepositoryProvider).watchRecentDoses(babyId),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'models.dart';

class MedicationRepository {
  MedicationRepository(this._db);

  final SupabaseClient _db;

  Future<List<Medication>> all(String babyId) async {
    final rows = await _db
        .from('medications')
        .select(Medication.columns)
        .eq('baby_id', babyId)
        .isFilter('deleted_at', null)
        .order('start_date', ascending: false);
    return rows.map(Medication.fromJson).toList();
  }

  /// Doses recorded in the last [days] days, newest first.
  Future<List<MedicationDose>> recentDoses(String babyId, {int days = 3}) =>
      dosesSince(babyId, DateTime.now().subtract(Duration(days: days)));

  Future<List<MedicationDose>> dosesSince(String babyId, DateTime since) async {
    final rows = await _db
        .from('medication_doses')
        .select('id, medication_id, given_at, skipped, scheduled_for')
        .eq('baby_id', babyId)
        .isFilter('deleted_at', null)
        .gte('given_at', utcTimestamp(since))
        .order('given_at', ascending: false);
    return rows.map(MedicationDose.fromJson).toList();
  }

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
  }) {
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
    if (existingId != null) return _db.from('medications').update(fields).eq('id', existingId);
    return _db.from('medications').insert({'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> delete(String id) =>
      _db.from('medications').update({'deleted_at': utcTimestamp(DateTime.now())}).eq('id', id);

  /// Records a dose as given now (or skipped), for [scheduledFor] if it was
  /// a scheduled one.
  Future<void> recordDose(Baby baby, Medication medication, {DateTime? scheduledFor, bool skipped = false}) {
    return _db.from('medication_doses').insert({
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'medication_id': medication.id,
      'given_at': utcTimestamp(DateTime.now()),
      'skipped': skipped,
      'scheduled_for': scheduledFor == null ? null : utcTimestamp(scheduledFor),
    });
  }

  Future<void> undoDose(String doseId) =>
      _db.from('medication_doses').update({'deleted_at': utcTimestamp(DateTime.now())}).eq('id', doseId);
}

final medicationRepositoryProvider = Provider((ref) => MedicationRepository(ref.watch(supabaseProvider)));

final medicationsProvider = FutureProvider.family<List<Medication>, String>(
  (ref, babyId) => ref.watch(medicationRepositoryProvider).all(babyId),
);

final recentDosesProvider = FutureProvider.family<List<MedicationDose>, String>(
  (ref, babyId) => ref.watch(medicationRepositoryProvider).recentDoses(babyId),
);

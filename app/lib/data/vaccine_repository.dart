import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'models.dart';

class VaccineRepository {
  VaccineRepository(this._db);

  final SupabaseClient _db;

  /// The national schedule, in order. Pakistan only for now.
  Future<List<VaccineDose>> schedule({String country = 'PK'}) async {
    final rows = await _db
        .from('vaccine_schedule')
        .select('code, name, dose_label, due_age_value, due_age_unit, sort_order')
        .eq('country_code', country)
        .order('sort_order');
    return rows.map(VaccineDose.fromJson).toList();
  }

  Future<List<Vaccination>> given(String babyId) async {
    final rows = await _db
        .from('vaccinations')
        .select('id, vaccine_code, given_on, batch_number, clinic, notes')
        .eq('baby_id', babyId)
        .isFilter('deleted_at', null)
        .order('given_on');
    return rows.map(Vaccination.fromJson).toList();
  }

  /// Records [codes] as given on the same day (e.g. a whole clinic visit).
  Future<void> markGiven(
    Baby baby, {
    required List<String> codes,
    required DateTime givenOn,
    String? batchNumber,
    String? clinic,
    String? notes,
  }) {
    return _db.from('vaccinations').insert([
      for (final code in codes)
        {
          'family_id': baby.familyId,
          'baby_id': baby.id,
          'vaccine_code': code,
          'given_on': dateOnly(givenOn),
          'batch_number': batchNumber,
          'clinic': clinic,
          'notes': notes,
        },
    ]);
  }

  Future<void> update(
    String id, {
    required DateTime givenOn,
    String? batchNumber,
    String? clinic,
    String? notes,
  }) {
    return _db.from('vaccinations').update({
      'given_on': dateOnly(givenOn),
      'batch_number': batchNumber,
      'clinic': clinic,
      'notes': notes,
    }).eq('id', id);
  }

  Future<void> delete(String id) {
    return _db.from('vaccinations').update({'deleted_at': utcTimestamp(DateTime.now())}).eq('id', id);
  }
}

final vaccineRepositoryProvider = Provider((ref) => VaccineRepository(ref.watch(supabaseProvider)));

/// The schedule rarely changes, so it's loaded once per app run.
final vaccineScheduleProvider = FutureProvider((ref) => ref.watch(vaccineRepositoryProvider).schedule());

final vaccinationsProvider = FutureProvider.family<List<Vaccination>, String>(
  (ref, babyId) => ref.watch(vaccineRepositoryProvider).given(babyId),
);

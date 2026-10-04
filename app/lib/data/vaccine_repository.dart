import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import 'local_db.dart';
import 'models.dart';

class VaccineRepository {
  VaccineRepository(this._db);

  final PowerSyncDatabase _db;

  /// [country]'s national schedule, in order; empty for a country we don't
  /// have a schedule for yet.
  Stream<List<VaccineDose>> watchSchedule(String country) => _db
      .watch(
        'SELECT code, name, dose_label, due_age_value, due_age_unit, sort_order FROM vaccine_schedule '
        'WHERE country_code = ? ORDER BY sort_order',
        parameters: [country],
      )
      .map((rows) => rows.map(VaccineDose.fromJson).toList());

  Stream<List<Vaccination>> watchGiven(String babyId) => _db
      .watch(
        'SELECT id, vaccine_code, vaccine_name, given_on, batch_number, clinic, notes FROM vaccinations '
        'WHERE baby_id = ? AND deleted_at IS NULL ORDER BY given_on',
        parameters: [babyId],
      )
      .map((rows) => rows.map(Vaccination.fromJson).toList());

  /// Records [codes] as given on the same day (e.g. a whole clinic visit).
  Future<void> markGiven(
    Baby baby, {
    required List<String> codes,
    required DateTime givenOn,
    String? batchNumber,
    String? clinic,
    String? notes,
  }) {
    return _db.writeTransaction((tx) async {
      for (final code in codes) {
        await insertRow(tx, 'vaccinations', {
          'family_id': baby.familyId,
          'baby_id': baby.id,
          'vaccine_code': code,
          'given_on': dateOnly(givenOn),
          'batch_number': batchNumber,
          'clinic': clinic,
          'notes': notes,
        });
      }
    });
  }

  /// Records a vaccine that isn't in the schedule, by its name.
  Future<void> addOther(
    Baby baby, {
    required String name,
    required DateTime givenOn,
    String? batchNumber,
    String? clinic,
    String? notes,
  }) {
    return _db.writeTransaction((tx) async {
      await insertRow(tx, 'vaccinations', {
        'family_id': baby.familyId,
        'baby_id': baby.id,
        'vaccine_code': Vaccination.otherCode,
        'vaccine_name': name,
        'given_on': dateOnly(givenOn),
        'batch_number': batchNumber,
        'clinic': clinic,
        'notes': notes,
      });
    });
  }

  /// [name] is only changed for a vaccine added by name.
  Future<void> update(
    String id, {
    required DateTime givenOn,
    String? name,
    String? batchNumber,
    String? clinic,
    String? notes,
  }) {
    return updateRow(_db, 'vaccinations', id, {
      'vaccine_name': ?name,
      'given_on': dateOnly(givenOn),
      'batch_number': batchNumber,
      'clinic': clinic,
      'notes': notes,
    });
  }

  Future<void> delete(String id) => updateRow(_db, 'vaccinations', id, {'deleted_at': utcTimestamp(DateTime.now())});
}

final vaccineRepositoryProvider = Provider((ref) => VaccineRepository(ref.watch(powerSyncProvider)));

/// The schedule for a country, e.g. `vaccineScheduleProvider(baby.countryCode)`.
final vaccineScheduleProvider = StreamProvider.family<List<VaccineDose>, String>(
  (ref, country) => ref.watch(vaccineRepositoryProvider).watchSchedule(country),
);

final vaccinationsProvider = StreamProvider.family<List<Vaccination>, String>(
  (ref, babyId) => ref.watch(vaccineRepositoryProvider).watchGiven(babyId),
);

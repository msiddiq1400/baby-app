import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import '../core/weight_velocity.dart';
import '../core/who_growth.dart';
import 'local_db.dart';
import 'models.dart';

class GrowthRepository {
  GrowthRepository(this._db);

  final PowerSyncDatabase _db;

  static const _sql = 'SELECT id, measured_on, weight_g, length_mm, head_mm FROM growth_measurements '
      'WHERE baby_id = ? AND deleted_at IS NULL ORDER BY measured_on';

  /// All measurements, oldest first.
  Future<List<GrowthMeasurement>> all(String babyId) async =>
      (await _db.getAll(_sql, [babyId])).map(GrowthMeasurement.fromJson).toList();

  Stream<List<GrowthMeasurement>> watchAll(String babyId) =>
      _db.watch(_sql, parameters: [babyId]).map((rows) => rows.map(GrowthMeasurement.fromJson).toList());

  /// Adds a measurement, or updates [existingId].
  Future<void> save(
    Baby baby, {
    String? existingId,
    required DateTime measuredOn,
    int? weightG,
    int? lengthMm,
    int? headMm,
  }) async {
    final fields = {
      'measured_on': dateOnly(measuredOn),
      'weight_g': weightG,
      'length_mm': lengthMm,
      'head_mm': headMm,
    };
    if (existingId != null) return updateRow(_db, 'growth_measurements', existingId, fields);
    await insertRow(_db, 'growth_measurements', {'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> delete(String id) =>
      updateRow(_db, 'growth_measurements', id, {'deleted_at': utcTimestamp(DateTime.now())});
}

final growthRepositoryProvider = Provider((ref) => GrowthRepository(ref.watch(powerSyncProvider)));

final growthMeasurementsProvider = StreamProvider.family<List<GrowthMeasurement>, String>(
  (ref, babyId) => ref.watch(growthRepositoryProvider).watchAll(babyId),
);

final whoGrowthProvider = FutureProvider<WhoGrowth>((ref) => WhoGrowth.load());

final weightVelocityProvider = FutureProvider<WeightVelocity>((ref) => WeightVelocity.load());

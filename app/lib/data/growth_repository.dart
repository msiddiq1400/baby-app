import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import '../core/who_growth.dart';
import 'models.dart';

class GrowthRepository {
  GrowthRepository(this._db);

  final SupabaseClient _db;

  /// All measurements, oldest first.
  Future<List<GrowthMeasurement>> all(String babyId) async {
    final rows = await _db
        .from('growth_measurements')
        .select('id, measured_on, weight_g, length_mm, head_mm')
        .eq('baby_id', babyId)
        .isFilter('deleted_at', null)
        .order('measured_on');
    return rows.map(GrowthMeasurement.fromJson).toList();
  }

  /// Adds a measurement, or updates [existingId].
  Future<void> save(
    Baby baby, {
    String? existingId,
    required DateTime measuredOn,
    int? weightG,
    int? lengthMm,
    int? headMm,
  }) {
    final fields = {
      'measured_on': dateOnly(measuredOn),
      'weight_g': weightG,
      'length_mm': lengthMm,
      'head_mm': headMm,
    };
    if (existingId != null) return _db.from('growth_measurements').update(fields).eq('id', existingId);
    return _db.from('growth_measurements').insert({'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> delete(String id) {
    return _db.from('growth_measurements').update({'deleted_at': utcTimestamp(DateTime.now())}).eq('id', id);
  }
}

final growthRepositoryProvider = Provider((ref) => GrowthRepository(ref.watch(supabaseProvider)));

final growthMeasurementsProvider = FutureProvider.family<List<GrowthMeasurement>, String>(
  (ref, babyId) => ref.watch(growthRepositoryProvider).all(babyId),
);

final whoGrowthProvider = FutureProvider<WhoGrowth>((ref) => WhoGrowth.load());

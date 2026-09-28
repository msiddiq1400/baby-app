import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'models.dart';

class BabyRepository {
  BabyRepository(this._db);

  final SupabaseClient _db;

  /// The family's first baby. Choosing between several babies comes later.
  Future<Baby?> currentBaby() async {
    final row = await _db
        .from('babies')
        .select(Baby.columns)
        .isFilter('deleted_at', null)
        .order('created_at')
        .limit(1)
        .maybeSingle();
    return row == null ? null : Baby.fromJson(row);
  }

  /// Adds a baby, creating the user's family first if they don't have one.
  Future<void> addBaby({
    required String name,
    required DateTime birthDate,
    String? sex,
    int? birthWeightG,
  }) async {
    final family = await _db.from('families').select('id').limit(1).maybeSingle();
    final familyId = family?['id'] as String? ??
        (await _db.from('families').insert({'name': '$name family'}).select('id').single())['id'] as String;

    await _db.from('babies').insert({
      'family_id': familyId,
      'name': name,
      'birth_date': dateOnly(birthDate),
      'sex': ?sex,
      'birth_weight_g': ?birthWeightG,
    });
  }

  Future<void> setSex(String babyId, String sex) =>
      _db.from('babies').update({'sex': sex}).eq('id', babyId);
}

final babyRepositoryProvider = Provider((ref) => BabyRepository(ref.watch(supabaseProvider)));

final currentBabyProvider = FutureProvider<Baby?>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return null;
  return ref.watch(babyRepositoryProvider).currentBaby();
});

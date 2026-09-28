import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'local_db.dart';
import 'models.dart';

class BabyRepository {
  BabyRepository(this._db);

  final PowerSyncDatabase _db;

  /// The family's first baby. Choosing between several babies comes later.
  static const _currentBabySql = 'SELECT ${Baby.columns} FROM babies WHERE deleted_at IS NULL '
      'ORDER BY julianday(created_at) LIMIT 1';

  Stream<Baby?> watchCurrentBaby() =>
      _db.watch(_currentBabySql).map((rows) => rows.isEmpty ? null : Baby.fromJson(rows.first));

  /// Adds a baby, creating the user's family first if they don't have one.
  /// The server makes the creator the family's owner when the family uploads.
  Future<void> addBaby({
    required String name,
    required DateTime birthDate,
    String? sex,
    int? birthWeightG,
  }) {
    return _db.writeTransaction((tx) async {
      final family = await tx.getOptional('SELECT id FROM families LIMIT 1');
      final familyId = family?['id'] as String? ?? await insertRow(tx, 'families', {'name': '$name family'});
      await insertRow(tx, 'babies', {
        'family_id': familyId,
        'name': name,
        'birth_date': dateOnly(birthDate),
        'sex': sex,
        'birth_weight_g': birthWeightG,
        'created_at': utcTimestamp(DateTime.now()),
      });
    });
  }

  Future<void> setSex(String babyId, String sex) => updateRow(_db, 'babies', babyId, {'sex': sex});
}

final babyRepositoryProvider = Provider((ref) => BabyRepository(ref.watch(powerSyncProvider)));

final currentBabyProvider = StreamProvider<Baby?>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(null);
  return ref.watch(babyRepositoryProvider).watchCurrentBaby();
});

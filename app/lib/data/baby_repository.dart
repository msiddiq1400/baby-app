import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'local_db.dart';
import 'models.dart';
import 'settings_repository.dart';

class BabyRepository {
  BabyRepository(this._db);

  final PowerSyncDatabase _db;

  /// Every baby in the user's families, oldest profile first.
  Stream<List<Baby>> watchBabies() => _db
      .watch('SELECT ${Baby.columns} FROM babies WHERE deleted_at IS NULL ORDER BY julianday(created_at)')
      .map((rows) => rows.map(Baby.fromJson).toList());

  /// Adds a baby to [familyId], or to a new family if the user has none yet
  /// (the server makes the creator its owner when it uploads). Returns the
  /// new baby's id.
  Future<String> addBaby({
    required String name,
    required DateTime birthDate,
    String? familyId,
    String? sex,
    int? birthWeightG,
    int? birthLengthMm,
    int? birthHeadMm,
  }) {
    return _db.writeTransaction((tx) async {
      final existing = familyId ?? (await tx.getOptional('SELECT id FROM families LIMIT 1'))?['id'] as String?;
      final family = existing ?? await insertRow(tx, 'families', {'name': '$name family'});
      return insertRow(tx, 'babies', {
        'family_id': family,
        'name': name,
        'birth_date': dateOnly(birthDate),
        'sex': sex,
        'birth_weight_g': birthWeightG,
        'birth_length_mm': birthLengthMm,
        'birth_head_mm': birthHeadMm,
        'created_at': utcTimestamp(DateTime.now()),
      });
    });
  }

  Future<void> updateBaby(
    String id, {
    required String name,
    required DateTime birthDate,
    String? sex,
    int? birthWeightG,
    int? birthLengthMm,
    int? birthHeadMm,
  }) {
    return updateRow(_db, 'babies', id, {
      'name': name,
      'birth_date': dateOnly(birthDate),
      'sex': sex,
      'birth_weight_g': birthWeightG,
      'birth_length_mm': birthLengthMm,
      'birth_head_mm': birthHeadMm,
    });
  }

  Future<void> setSex(String babyId, String sex) => updateRow(_db, 'babies', babyId, {'sex': sex});

  /// Soft delete; the baby's history stays in the database but is hidden.
  Future<void> delete(String id) => updateRow(_db, 'babies', id, {'deleted_at': utcTimestamp(DateTime.now())});
}

final babyRepositoryProvider = Provider((ref) => BabyRepository(ref.watch(powerSyncProvider)));

final babiesProvider = StreamProvider<List<Baby>>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(const []);
  return ref.watch(babyRepositoryProvider).watchBabies();
});

/// The baby shown in the app: the one chosen on this phone, else the first.
final currentBabyProvider = StreamProvider<Baby?>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(null);
  final selectedId = ref.watch(settingProvider(SettingKeys.babyId)).value;
  return ref
      .watch(babyRepositoryProvider)
      .watchBabies()
      .map((babies) => babies.where((b) => b.id == selectedId).firstOrNull ?? babies.firstOrNull);
});

/// Shows [babyId] from now on (on this phone).
Future<void> selectBaby(WidgetRef ref, String babyId) =>
    ref.read(settingsRepositoryProvider).set(SettingKeys.babyId, babyId);

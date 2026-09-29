import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import 'local_db.dart';
import 'models.dart';

/// One time a food was offered: when, whether the baby liked it, and any
/// reaction.
class FoodTry {
  const FoodTry({
    required this.id,
    required this.foodId,
    required this.triedOn,
    required this.reaction,
    this.opinion,
    this.notes,
  });

  final String id;
  final String foodId;
  final DateTime triedOn;

  /// 'liked', 'neutral', 'disliked' or null.
  final String? opinion;

  /// 'none', 'mild' or 'severe'.
  final String reaction;
  final String? notes;

  factory FoodTry.fromJson(Map<String, dynamic> json) => FoodTry(
        id: json['id'] as String,
        foodId: json['food_id'] as String,
        triedOn: DateTime.parse(json['tried_on'] as String),
        opinion: json['opinion'] as String?,
        reaction: (json['reaction'] as String?) ?? 'none',
        notes: json['notes'] as String?,
      );
}

class MilestoneCheck {
  const MilestoneCheck({required this.id, required this.milestoneId, required this.achievedOn});

  final String id;
  final String milestoneId;
  final DateTime achievedOn;
}

class SolidsRepository {
  SolidsRepository(this._db);

  final PowerSyncDatabase _db;

  /// Every try, newest first.
  Stream<List<FoodTry>> watchTries(String babyId) => _db
      .watch(
        'SELECT id, food_id, tried_on, opinion, reaction, notes FROM food_tries '
        'WHERE baby_id = ? AND deleted_at IS NULL ORDER BY tried_on DESC',
        parameters: [babyId],
      )
      .map((rows) => rows.map(FoodTry.fromJson).toList());

  /// Adds a try, or updates [existingId].
  Future<void> saveTry(
    Baby baby, {
    String? existingId,
    required String foodId,
    required DateTime triedOn,
    String? opinion,
    required String reaction,
    String? notes,
  }) async {
    final fields = {
      'food_id': foodId,
      'tried_on': dateOnly(triedOn),
      'opinion': opinion,
      'reaction': reaction,
      'notes': notes,
    };
    if (existingId != null) return updateRow(_db, 'food_tries', existingId, fields);
    await insertRow(_db, 'food_tries', {'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> deleteTry(String id) =>
      updateRow(_db, 'food_tries', id, {'deleted_at': utcTimestamp(DateTime.now())});

  /// Milestones reached, by milestone id.
  Stream<Map<String, MilestoneCheck>> watchMilestones(String babyId) => _db
      .watch(
        'SELECT id, milestone_id, achieved_on FROM milestone_checks WHERE baby_id = ? AND deleted_at IS NULL',
        parameters: [babyId],
      )
      .map((rows) => {
            for (final r in rows)
              r['milestone_id'] as String: MilestoneCheck(
                id: r['id'] as String,
                milestoneId: r['milestone_id'] as String,
                achievedOn: DateTime.parse(r['achieved_on'] as String),
              ),
          });

  /// Ticks a milestone as reached today, or un-ticks it.
  Future<void> setMilestone(Baby baby, String milestoneId, MilestoneCheck? existing, {required bool reached}) async {
    if (!reached) {
      if (existing != null) {
        await updateRow(_db, 'milestone_checks', existing.id, {'deleted_at': utcTimestamp(DateTime.now())});
      }
      return;
    }
    if (existing != null) return;
    await insertRow(_db, 'milestone_checks', {
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'milestone_id': milestoneId,
      'achieved_on': dateOnly(DateTime.now()),
    });
  }
}

final solidsRepositoryProvider = Provider((ref) => SolidsRepository(ref.watch(powerSyncProvider)));

final foodTriesProvider = StreamProvider.family<List<FoodTry>, String>(
  (ref, babyId) => ref.watch(solidsRepositoryProvider).watchTries(babyId),
);

final milestoneChecksProvider = StreamProvider.family<Map<String, MilestoneCheck>, String>(
  (ref, babyId) => ref.watch(solidsRepositoryProvider).watchMilestones(babyId),
);

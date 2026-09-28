import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../core/dates.dart';
import 'local_db.dart';
import 'models.dart';

/// Pumping sessions and the stored-milk inventory.
class MilkRepository {
  MilkRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<List<PumpingSession>> watchPumpingSince(String babyId, DateTime since) => _db
      .watch(
        'SELECT id, side, started_at, ended_at, amount_ml FROM pumping_sessions '
        'WHERE baby_id = ? AND deleted_at IS NULL AND julianday(started_at) >= julianday(?) '
        'ORDER BY julianday(started_at) DESC',
        parameters: [babyId, utcTimestamp(since)],
      )
      .map((rows) => rows.map(PumpingSession.fromJson).toList());

  /// Bags not yet used or thrown away.
  Stream<List<MilkBag>> watchActiveBags(String babyId) => _db
      .watch(
        'SELECT ${MilkBag.columns} FROM milk_stash WHERE baby_id = ? AND deleted_at IS NULL AND finished_at IS NULL',
        parameters: [babyId],
      )
      .map((rows) => rows.map(MilkBag.fromJson).toList());

  /// Logs a pumping session ([at] = when it ended). With [storeIn], the
  /// milk also goes into the inventory as one bag.
  Future<void> logPumping(
    Baby baby, {
    required DateTime at,
    BreastSide? side,
    int? amountMl,
    int? minutes,
    MilkLocation? storeIn,
  }) {
    final startedAt = minutes == null ? at : at.subtract(Duration(minutes: minutes));
    return _db.writeTransaction((tx) async {
      final sessionId = await insertRow(tx, 'pumping_sessions', {
        'family_id': baby.familyId,
        'baby_id': baby.id,
        'side': side?.name,
        'amount_ml': amountMl,
        'started_at': utcTimestamp(startedAt),
        'ended_at': minutes == null ? null : utcTimestamp(at),
      });
      if (storeIn != null && amountMl != null) {
        await _insertBag(tx, baby, amountMl: amountMl, pumpedAt: at, location: storeIn, sessionId: sessionId);
      }
    });
  }

  Future<void> updatePumping(String id, {required DateTime at, BreastSide? side, int? amountMl, int? minutes}) {
    final startedAt = minutes == null ? at : at.subtract(Duration(minutes: minutes));
    return updateRow(_db, 'pumping_sessions', id, {
      'side': side?.name,
      'amount_ml': amountMl,
      'started_at': utcTimestamp(startedAt),
      'ended_at': minutes == null ? null : utcTimestamp(at),
    });
  }

  Future<void> deletePumping(String id) =>
      updateRow(_db, 'pumping_sessions', id, {'deleted_at': utcTimestamp(DateTime.now())});

  Future<void> addBag(Baby baby, {required int amountMl, required DateTime pumpedAt, required MilkLocation location}) =>
      _insertBag(_db, baby, amountMl: amountMl, pumpedAt: pumpedAt, location: location);

  Future<void> _insertBag(
    SqliteWriteContext db,
    Baby baby, {
    required int amountMl,
    required DateTime pumpedAt,
    required MilkLocation location,
    String? sessionId,
  }) async {
    final now = utcTimestamp(DateTime.now());
    await insertRow(db, 'milk_stash', {
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'pumping_session_id': sessionId,
      'pumped_at': utcTimestamp(pumpedAt),
      'amount_ml': amountMl,
      'location': location.name,
      'frozen_at': location == MilkLocation.freezer ? now : null,
      'thawed_at': location == MilkLocation.thawed ? now : null,
    });
  }

  /// Moves a bag, e.g. fridge to freezer, or freezer to thawing in the fridge.
  Future<void> move(MilkBag bag, MilkLocation to) {
    final now = utcTimestamp(DateTime.now());
    return updateRow(_db, 'milk_stash', bag.id, {
      'location': to.name,
      if (to == MilkLocation.freezer) 'frozen_at': now,
      if (to == MilkLocation.thawed) 'thawed_at': now,
    });
  }

  Future<void> finish(MilkBag bag, {required bool used}) => updateRow(_db, 'milk_stash', bag.id, {
        'finished_at': utcTimestamp(DateTime.now()),
        'finished_reason': used ? 'used' : 'discarded',
      });
}

final milkRepositoryProvider = Provider((ref) => MilkRepository(ref.watch(powerSyncProvider)));

final milkBagsProvider = StreamProvider.family<List<MilkBag>, String>(
  (ref, babyId) => ref.watch(milkRepositoryProvider).watchActiveBags(babyId),
);

/// Today's pumping sessions.
final pumpingTodayProvider = StreamProvider.family<List<PumpingSession>, String>((ref, babyId) {
  final now = DateTime.now();
  return ref.watch(milkRepositoryProvider).watchPumpingSince(babyId, DateTime(now.year, now.month, now.day));
});

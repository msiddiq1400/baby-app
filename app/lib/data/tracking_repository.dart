import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import 'local_db.dart';
import 'models.dart';

/// Reads and writes feeds, diapers and sleep in the database on the phone;
/// PowerSync uploads the changes.
class TrackingRepository {
  TrackingRepository(this._db);

  final PowerSyncDatabase _db;

  static const _feedColumns = 'id, type, side, started_at, ended_at, amount_ml';
  static const _diaperColumns = 'id, occurred_at, is_wet, is_dirty';

  Future<TodayLog> today(String babyId) async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final from = utcTimestamp(dayStart);

    final feeds = await _db.getAll(
      'SELECT $_feedColumns FROM feeds WHERE baby_id = ? AND deleted_at IS NULL '
      'AND julianday(started_at) >= julianday(?) ORDER BY julianday(started_at) DESC',
      [babyId, from],
    );
    final diapers = await _db.getAll(
      'SELECT $_diaperColumns FROM diapers WHERE baby_id = ? AND deleted_at IS NULL '
      'AND julianday(occurred_at) >= julianday(?) ORDER BY julianday(occurred_at) DESC',
      [babyId, from],
    );
    // Includes a sleep that started last night and is still going.
    final sleeps = await _db.getAll(
      'SELECT id, kind, started_at, ended_at FROM sleeps WHERE baby_id = ? AND deleted_at IS NULL '
      'AND (ended_at IS NULL OR julianday(ended_at) >= julianday(?)) ORDER BY julianday(started_at) DESC',
      [babyId, from],
    );

    return TodayLog(
      dayStart: dayStart,
      feeds: feeds.map(Feed.fromJson).toList(),
      diapers: diapers.map(Diaper.fromJson).toList(),
      sleeps: sleeps.map(Sleep.fromJson).toList(),
    );
  }

  Stream<TodayLog> watchToday(String babyId) =>
      watchTables(_db, const ['feeds', 'diapers', 'sleeps'], () => today(babyId));

  /// Feeds and diapers since [from], e.g. for the doctor summary.
  Future<(List<Feed>, List<Diaper>)> feedsAndDiapersSince(String babyId, DateTime from) async {
    final since = utcTimestamp(from);
    final feeds = await _db.getAll(
      'SELECT $_feedColumns FROM feeds WHERE baby_id = ? AND deleted_at IS NULL '
      'AND julianday(started_at) >= julianday(?)',
      [babyId, since],
    );
    final diapers = await _db.getAll(
      'SELECT $_diaperColumns FROM diapers WHERE baby_id = ? AND deleted_at IS NULL '
      'AND julianday(occurred_at) >= julianday(?)',
      [babyId, since],
    );
    return (feeds.map(Feed.fromJson).toList(), diapers.map(Diaper.fromJson).toList());
  }

  /// Adds a feed, or updates [existingId] with the same fields.
  Future<void> saveFeed(
    Baby baby, {
    String? existingId,
    required FeedType type,
    required DateTime at,
    BreastSide? side,
    int? amountMl,
    int? minutes,
  }) {
    // "at" is when the feed ended; with a duration we work back to the start.
    final startedAt = minutes == null ? at : at.subtract(Duration(minutes: minutes));
    return _save('feeds', baby, existingId, {
      'type': type.dbValue,
      'side': side?.name,
      'amount_ml': amountMl,
      'started_at': utcTimestamp(startedAt),
      'ended_at': minutes == null ? null : utcTimestamp(at),
    });
  }

  Future<void> saveDiaper(
    Baby baby, {
    String? existingId,
    required DateTime at,
    required bool wet,
    required bool dirty,
  }) {
    return _save('diapers', baby, existingId, {'occurred_at': utcTimestamp(at), 'is_wet': wet, 'is_dirty': dirty});
  }

  /// Edits a sleep's times; a null [endedAt] means still asleep.
  Future<void> updateSleep(String id, {required SleepKind kind, required DateTime startedAt, DateTime? endedAt}) {
    return updateRow(_db, 'sleeps', id, {
      'kind': kind.name,
      'started_at': utcTimestamp(startedAt),
      'ended_at': endedAt == null ? null : utcTimestamp(endedAt),
    });
  }

  /// Soft delete, so the deletion also reaches other caregivers' phones.
  Future<void> delete(TrackedTable table, String id) =>
      updateRow(_db, table.name, id, {'deleted_at': utcTimestamp(DateTime.now())});

  Future<void> _save(String table, Baby baby, String? existingId, Map<String, Object?> fields) async {
    if (existingId != null) return updateRow(_db, table, existingId, fields);
    await insertRow(_db, table, {'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> startSleep(Baby baby, {required DateTime at}) async {
    // Sleep starting between 7 pm and 6 am counts as night sleep.
    final kind = at.hour >= 19 || at.hour < 6 ? SleepKind.night : SleepKind.nap;
    await insertRow(_db, 'sleeps', {
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'kind': kind.name,
      'started_at': utcTimestamp(at),
    });
  }

  Future<void> endSleep(String sleepId, {required DateTime at}) =>
      updateRow(_db, 'sleeps', sleepId, {'ended_at': utcTimestamp(at)});
}

enum TrackedTable { feeds, diapers, sleeps }

final trackingRepositoryProvider = Provider((ref) => TrackingRepository(ref.watch(powerSyncProvider)));

final todayLogProvider = StreamProvider.family<TodayLog, String>(
  (ref, babyId) => ref.watch(trackingRepositoryProvider).watchToday(babyId),
);

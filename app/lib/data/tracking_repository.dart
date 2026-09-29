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

  static const _feedColumns =
      'id, type, side, started_at, ended_at, amount_ml, left_seconds, right_seconds, timer_side, timer_started_at';
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

  /// Feeds since [from], oldest first, kept live (for the hunger guide).
  Stream<List<Feed>> watchFeedsSince(String babyId, DateTime from) => _db
      .watch(
        'SELECT $_feedColumns FROM feeds WHERE baby_id = ? AND deleted_at IS NULL '
        'AND julianday(started_at) >= julianday(?) ORDER BY julianday(started_at)',
        parameters: [babyId, utcTimestamp(from)],
      )
      .map((rows) => rows.map(Feed.fromJson).toList());

  /// Sleeps overlapping the time since [from], kept live (for sleep insights).
  Stream<List<Sleep>> watchSleepsSince(String babyId, DateTime from) => _db
      .watch(
        'SELECT id, kind, started_at, ended_at FROM sleeps WHERE baby_id = ? AND deleted_at IS NULL '
        'AND (ended_at IS NULL OR julianday(ended_at) >= julianday(?)) ORDER BY julianday(started_at)',
        parameters: [babyId, utcTimestamp(from)],
      )
      .map((rows) => rows.map(Sleep.fromJson).toList());

  /// Diapers since [from], oldest first, kept live (for reports).
  Stream<List<Diaper>> watchDiapersSince(String babyId, DateTime from) => _db
      .watch(
        'SELECT $_diaperColumns FROM diapers WHERE baby_id = ? AND deleted_at IS NULL '
        'AND julianday(occurred_at) >= julianday(?) ORDER BY julianday(occurred_at)',
        parameters: [babyId, utcTimestamp(from)],
      )
      .map((rows) => rows.map(Diaper.fromJson).toList());

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

  /// Adds a feed, or updates [existingId] with the same fields. Breastfeeds
  /// take the time on each side; bottles take [amountMl].
  Future<void> saveFeed(
    Baby baby, {
    String? existingId,
    required FeedType type,
    required DateTime at,
    int? amountMl,
    int? leftSeconds,
    int? rightSeconds,
  }) {
    final total = (leftSeconds ?? 0) + (rightSeconds ?? 0);
    // "at" is when the feed ended; with a duration we work back to the start.
    final startedAt = at.subtract(Duration(seconds: total));
    final breast = type == FeedType.breast;
    return _save('feeds', baby, existingId, {
      'type': type.dbValue,
      'side': breast ? sideFromSeconds(leftSeconds ?? 0, rightSeconds ?? 0)?.name : null,
      'amount_ml': breast ? null : amountMl,
      'left_seconds': breast ? leftSeconds : null,
      'right_seconds': breast ? rightSeconds : null,
      'started_at': utcTimestamp(startedAt),
      'ended_at': total == 0 ? null : utcTimestamp(at),
      // Saving from the form always ends a timer.
      'timer_side': null,
      'timer_started_at': null,
    });
  }

  /// The breastfeeding timer that is going for [babyId] (running or paused),
  /// if any. Kept live, so a timer started on another phone shows up too.
  Stream<Feed?> watchFeedTimer(String babyId) => _db
      .watch(
        'SELECT $_feedColumns FROM feeds WHERE baby_id = ? AND deleted_at IS NULL '
        'AND timer_side IS NOT NULL ORDER BY julianday(started_at) DESC LIMIT 1',
        parameters: [babyId],
      )
      .map((rows) => rows.isEmpty ? null : Feed.fromJson(rows.first));

  /// Starts a breastfeed with the timer running on [side].
  Future<void> startFeedTimer(Baby baby, BreastSide side, {required DateTime at}) => insertRow(_db, 'feeds', {
        'family_id': baby.familyId,
        'baby_id': baby.id,
        'type': FeedType.breast.dbValue,
        'started_at': utcTimestamp(at),
        'left_seconds': 0,
        'right_seconds': 0,
        'timer_side': side.name,
        'timer_started_at': utcTimestamp(at),
      });

  /// Moves the timer to [side] (running), banking the time on the other side.
  Future<void> switchFeedSide(Feed feed, BreastSide side, {required DateTime at}) {
    final (left, right) = feed.bankedAt(at);
    return updateRow(_db, 'feeds', feed.id, {
      'left_seconds': left,
      'right_seconds': right,
      'timer_side': side.name,
      'timer_started_at': utcTimestamp(at),
    });
  }

  Future<void> pauseFeedTimer(Feed feed, {required DateTime at}) {
    final (left, right) = feed.bankedAt(at);
    return updateRow(_db, 'feeds', feed.id, {'left_seconds': left, 'right_seconds': right, 'timer_started_at': null});
  }

  Future<void> resumeFeedTimer(Feed feed, {required DateTime at}) =>
      updateRow(_db, 'feeds', feed.id, {'timer_started_at': utcTimestamp(at)});

  /// Stops the timer and saves the feed as finished at [at].
  Future<void> finishFeedTimer(Feed feed, {required DateTime at}) {
    final (left, right) = feed.bankedAt(at);
    return updateRow(_db, 'feeds', feed.id, {
      'left_seconds': left,
      'right_seconds': right,
      'side': sideFromSeconds(left, right)?.name,
      'ended_at': utcTimestamp(at),
      'timer_side': null,
      'timer_started_at': null,
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

/// The breastfeeding timer that's going, if any.
final feedTimerProvider = StreamProvider.family<Feed?, String>(
  (ref, babyId) => ref.watch(trackingRepositoryProvider).watchFeedTimer(babyId),
);

/// Last 3 days of feeds.
final recentFeedsProvider = StreamProvider.family<List<Feed>, String>((ref, babyId) {
  final now = DateTime.now();
  return ref.watch(trackingRepositoryProvider).watchFeedsSince(babyId, DateTime(now.year, now.month, now.day - 3));
});

/// Last 8 days of sleep (7 full days for "usual", plus today).
final recentSleepsProvider = StreamProvider.family<List<Sleep>, String>((ref, babyId) {
  final now = DateTime.now();
  return ref.watch(trackingRepositoryProvider).watchSleepsSince(babyId, DateTime(now.year, now.month, now.day - 8));
});

/// A report period: the last [days] days for [babyId].
typedef ReportPeriod = ({String babyId, int days});

DateTime _periodStart(int days) {
  final now = DateTime.now();
  // One extra day: a sleep crossing into the first day, and the first gap.
  return DateTime(now.year, now.month, now.day - days);
}

final reportFeedsProvider = StreamProvider.family<List<Feed>, ReportPeriod>(
  (ref, p) => ref.watch(trackingRepositoryProvider).watchFeedsSince(p.babyId, _periodStart(p.days)),
);

final reportSleepsProvider = StreamProvider.family<List<Sleep>, ReportPeriod>(
  (ref, p) => ref.watch(trackingRepositoryProvider).watchSleepsSince(p.babyId, _periodStart(p.days)),
);

final reportDiapersProvider = StreamProvider.family<List<Diaper>, ReportPeriod>(
  (ref, p) => ref.watch(trackingRepositoryProvider).watchDiapersSince(p.babyId, _periodStart(p.days)),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'models.dart';

/// Reads and writes feeds, diapers and sleep. All database access for
/// tracking goes through here, so offline sync can be added in one place.
class TrackingRepository {
  TrackingRepository(this._db);

  final SupabaseClient _db;

  Future<TodayLog> today(String babyId) async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final from = utcTimestamp(dayStart);

    final results = await Future.wait([
      _db
          .from('feeds')
          .select('id, type, side, started_at, ended_at, amount_ml')
          .eq('baby_id', babyId)
          .isFilter('deleted_at', null)
          .gte('started_at', from)
          .order('started_at', ascending: false),
      _db
          .from('diapers')
          .select('id, occurred_at, is_wet, is_dirty')
          .eq('baby_id', babyId)
          .isFilter('deleted_at', null)
          .gte('occurred_at', from)
          .order('occurred_at', ascending: false),
      _db
          .from('sleeps')
          .select('id, kind, started_at, ended_at')
          .eq('baby_id', babyId)
          .isFilter('deleted_at', null)
          .or('ended_at.is.null,ended_at.gte.$from')
          .order('started_at', ascending: false),
    ]);

    return TodayLog(
      dayStart: dayStart,
      feeds: results[0].map(Feed.fromJson).toList(),
      diapers: results[1].map(Diaper.fromJson).toList(),
      sleeps: results[2].map(Sleep.fromJson).toList(),
    );
  }

  /// Feeds and diapers since [from], e.g. for the doctor summary.
  Future<(List<Feed>, List<Diaper>)> feedsAndDiapersSince(String babyId, DateTime from) async {
    final since = utcTimestamp(from);
    final results = await Future.wait([
      _db
          .from('feeds')
          .select('id, type, side, started_at, ended_at, amount_ml')
          .eq('baby_id', babyId)
          .isFilter('deleted_at', null)
          .gte('started_at', since),
      _db
          .from('diapers')
          .select('id, occurred_at, is_wet, is_dirty')
          .eq('baby_id', babyId)
          .isFilter('deleted_at', null)
          .gte('occurred_at', since),
    ]);
    return (results[0].map(Feed.fromJson).toList(), results[1].map(Diaper.fromJson).toList());
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
    final fields = {
      'type': type.dbValue,
      'side': side?.name,
      'amount_ml': amountMl,
      'started_at': utcTimestamp(startedAt),
      'ended_at': minutes == null ? null : utcTimestamp(at),
    };
    return _save('feeds', baby, existingId, fields);
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
    return _db.from('sleeps').update({
      'kind': kind.name,
      'started_at': utcTimestamp(startedAt),
      'ended_at': endedAt == null ? null : utcTimestamp(endedAt),
    }).eq('id', id);
  }

  /// Soft delete, so the deletion also reaches other caregivers' phones.
  Future<void> delete(TrackedTable table, String id) {
    return _db.from(table.name).update({'deleted_at': utcTimestamp(DateTime.now())}).eq('id', id);
  }

  Future<void> _save(String table, Baby baby, String? existingId, Map<String, Object?> fields) {
    if (existingId != null) return _db.from(table).update(fields).eq('id', existingId);
    return _db.from(table).insert({'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> startSleep(Baby baby, {required DateTime at}) {
    // Sleep starting between 7 pm and 6 am counts as night sleep.
    final kind = at.hour >= 19 || at.hour < 6 ? SleepKind.night : SleepKind.nap;
    return _db.from('sleeps').insert({
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'kind': kind.name,
      'started_at': utcTimestamp(at),
    });
  }

  Future<void> endSleep(String sleepId, {required DateTime at}) {
    return _db.from('sleeps').update({'ended_at': utcTimestamp(at)}).eq('id', sleepId);
  }
}

enum TrackedTable { feeds, diapers, sleeps }

final trackingRepositoryProvider = Provider((ref) => TrackingRepository(ref.watch(supabaseProvider)));

final todayLogProvider = FutureProvider.family<TodayLog, String>(
  (ref, babyId) => ref.watch(trackingRepositoryProvider).today(babyId),
);

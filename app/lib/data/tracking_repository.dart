import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/providers.dart';
import 'models.dart';

/// Reads and writes feeds, diapers and sleep. All database access for
/// tracking goes through here, so offline sync can be added in one place.
class TrackingRepository {
  TrackingRepository(this._db);

  final SupabaseClient _db;

  static String _utc(DateTime t) => t.toUtc().toIso8601String();

  Future<TodayLog> today(String babyId) async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final from = _utc(dayStart);

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

  Future<void> logFeed(
    Baby baby, {
    required FeedType type,
    required DateTime at,
    BreastSide? side,
    int? amountMl,
    int? minutes,
  }) {
    // "at" is when the feed ended; with a duration we work back to the start.
    final startedAt = minutes == null ? at : at.subtract(Duration(minutes: minutes));
    return _db.from('feeds').insert({
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'type': type.dbValue,
      'side': ?side?.name,
      'amount_ml': ?amountMl,
      'started_at': _utc(startedAt),
      if (minutes != null) 'ended_at': _utc(at),
    });
  }

  Future<void> logDiaper(Baby baby, {required DateTime at, required bool wet, required bool dirty}) {
    return _db.from('diapers').insert({
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'occurred_at': _utc(at),
      'is_wet': wet,
      'is_dirty': dirty,
    });
  }

  Future<void> startSleep(Baby baby, {required DateTime at}) {
    // Sleep starting between 7 pm and 6 am counts as night sleep.
    final kind = at.hour >= 19 || at.hour < 6 ? SleepKind.night : SleepKind.nap;
    return _db.from('sleeps').insert({
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'kind': kind.name,
      'started_at': _utc(at),
    });
  }

  Future<void> endSleep(String sleepId, {required DateTime at}) {
    return _db.from('sleeps').update({'ended_at': _utc(at)}).eq('id', sleepId);
  }
}

final trackingRepositoryProvider = Provider((ref) => TrackingRepository(ref.watch(supabaseProvider)));

final todayLogProvider = FutureProvider.family<TodayLog, String>(
  (ref, babyId) => ref.watch(trackingRepositoryProvider).today(babyId),
);

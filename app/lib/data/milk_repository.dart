import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'models.dart';

/// Pumping sessions and the stored-milk inventory.
class MilkRepository {
  MilkRepository(this._db);

  final SupabaseClient _db;

  Future<List<PumpingSession>> pumpingSince(String babyId, DateTime since) async {
    final rows = await _db
        .from('pumping_sessions')
        .select('id, side, started_at, ended_at, amount_ml')
        .eq('baby_id', babyId)
        .isFilter('deleted_at', null)
        .gte('started_at', utcTimestamp(since))
        .order('started_at', ascending: false);
    return rows.map(PumpingSession.fromJson).toList();
  }

  /// Bags not yet used or thrown away.
  Future<List<MilkBag>> activeBags(String babyId) async {
    final rows = await _db
        .from('milk_stash')
        .select(MilkBag.columns)
        .eq('baby_id', babyId)
        .isFilter('deleted_at', null)
        .isFilter('finished_at', null);
    return rows.map(MilkBag.fromJson).toList();
  }

  /// Logs a pumping session ([at] = when it ended). With [storeIn], the
  /// milk also goes into the inventory as one bag.
  Future<void> logPumping(
    Baby baby, {
    required DateTime at,
    BreastSide? side,
    int? amountMl,
    int? minutes,
    MilkLocation? storeIn,
  }) async {
    final startedAt = minutes == null ? at : at.subtract(Duration(minutes: minutes));
    final session = await _db
        .from('pumping_sessions')
        .insert({
          'family_id': baby.familyId,
          'baby_id': baby.id,
          'side': side?.name,
          'amount_ml': amountMl,
          'started_at': utcTimestamp(startedAt),
          'ended_at': minutes == null ? null : utcTimestamp(at),
        })
        .select('id')
        .single();
    if (storeIn != null && amountMl != null) {
      await addBag(baby, amountMl: amountMl, pumpedAt: at, location: storeIn, sessionId: session['id'] as String);
    }
  }

  Future<void> updatePumping(String id, {required DateTime at, BreastSide? side, int? amountMl, int? minutes}) {
    final startedAt = minutes == null ? at : at.subtract(Duration(minutes: minutes));
    return _db.from('pumping_sessions').update({
      'side': side?.name,
      'amount_ml': amountMl,
      'started_at': utcTimestamp(startedAt),
      'ended_at': minutes == null ? null : utcTimestamp(at),
    }).eq('id', id);
  }

  Future<void> deletePumping(String id) =>
      _db.from('pumping_sessions').update({'deleted_at': utcTimestamp(DateTime.now())}).eq('id', id);

  Future<void> addBag(
    Baby baby, {
    required int amountMl,
    required DateTime pumpedAt,
    required MilkLocation location,
    String? sessionId,
  }) {
    final now = DateTime.now();
    return _db.from('milk_stash').insert({
      'family_id': baby.familyId,
      'baby_id': baby.id,
      'pumping_session_id': sessionId,
      'pumped_at': utcTimestamp(pumpedAt),
      'amount_ml': amountMl,
      'location': location.name,
      if (location == MilkLocation.freezer) 'frozen_at': utcTimestamp(now),
      if (location == MilkLocation.thawed) 'thawed_at': utcTimestamp(now),
    });
  }

  /// Moves a bag, e.g. fridge to freezer, or freezer to thawing in the fridge.
  Future<void> move(MilkBag bag, MilkLocation to) {
    final now = utcTimestamp(DateTime.now());
    return _db.from('milk_stash').update({
      'location': to.name,
      if (to == MilkLocation.freezer) 'frozen_at': now,
      if (to == MilkLocation.thawed) 'thawed_at': now,
    }).eq('id', bag.id);
  }

  Future<void> finish(MilkBag bag, {required bool used}) => _db.from('milk_stash').update({
        'finished_at': utcTimestamp(DateTime.now()),
        'finished_reason': used ? 'used' : 'discarded',
      }).eq('id', bag.id);
}

final milkRepositoryProvider = Provider((ref) => MilkRepository(ref.watch(supabaseProvider)));

final milkBagsProvider = FutureProvider.family<List<MilkBag>, String>(
  (ref, babyId) => ref.watch(milkRepositoryProvider).activeBags(babyId),
);

/// Today's pumping sessions.
final pumpingTodayProvider = FutureProvider.family<List<PumpingSession>, String>((ref, babyId) {
  final now = DateTime.now();
  return ref.watch(milkRepositoryProvider).pumpingSince(babyId, DateTime(now.year, now.month, now.day));
});

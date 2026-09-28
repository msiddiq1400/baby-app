import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/dates.dart';
import '../core/providers.dart';
import 'models.dart';

class SymptomRepository {
  SymptomRepository(this._db);

  final SupabaseClient _db;

  /// Entries since [from], newest first.
  Future<List<SymptomLog>> since(String babyId, DateTime from) async {
    final rows = await _db
        .from('symptom_logs')
        .select('id, symptom, occurred_at, temperature_c, severity, notes')
        .eq('baby_id', babyId)
        .isFilter('deleted_at', null)
        .gte('occurred_at', utcTimestamp(from))
        .order('occurred_at', ascending: false);
    return rows.map(SymptomLog.fromJson).toList();
  }

  /// Adds an entry, or updates [existingId].
  Future<void> save(
    Baby baby, {
    String? existingId,
    required String symptom,
    required DateTime occurredAt,
    double? temperatureC,
    int? severity,
    String? notes,
  }) {
    final fields = {
      'symptom': symptom,
      'occurred_at': utcTimestamp(occurredAt),
      'temperature_c': temperatureC,
      'severity': severity,
      'notes': notes,
    };
    if (existingId != null) return _db.from('symptom_logs').update(fields).eq('id', existingId);
    return _db.from('symptom_logs').insert({'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> delete(String id) =>
      _db.from('symptom_logs').update({'deleted_at': utcTimestamp(DateTime.now())}).eq('id', id);
}

final symptomRepositoryProvider = Provider((ref) => SymptomRepository(ref.watch(supabaseProvider)));

/// The last 14 days, which is what the diary shows and the summary can cover.
final recentSymptomsProvider = FutureProvider.family<List<SymptomLog>, String>((ref, babyId) {
  final now = DateTime.now();
  return ref.watch(symptomRepositoryProvider).since(babyId, DateTime(now.year, now.month, now.day - 14));
});

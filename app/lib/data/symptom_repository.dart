import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../core/dates.dart';
import 'local_db.dart';
import 'models.dart';

class SymptomRepository {
  SymptomRepository(this._db);

  final PowerSyncDatabase _db;

  static const _sql = 'SELECT id, symptom, occurred_at, temperature_c, severity, notes FROM symptom_logs '
      'WHERE baby_id = ? AND deleted_at IS NULL AND julianday(occurred_at) >= julianday(?) '
      'ORDER BY julianday(occurred_at) DESC';

  /// Entries since [from], newest first.
  Future<List<SymptomLog>> since(String babyId, DateTime from) async =>
      (await _db.getAll(_sql, [babyId, utcTimestamp(from)])).map(SymptomLog.fromJson).toList();

  Stream<List<SymptomLog>> watchSince(String babyId, DateTime from) =>
      _db.watch(_sql, parameters: [babyId, utcTimestamp(from)]).map((rows) => rows.map(SymptomLog.fromJson).toList());

  /// Adds an entry, or updates [existingId].
  Future<void> save(
    Baby baby, {
    String? existingId,
    required String symptom,
    required DateTime occurredAt,
    double? temperatureC,
    int? severity,
    String? notes,
  }) async {
    final fields = {
      'symptom': symptom,
      'occurred_at': utcTimestamp(occurredAt),
      'temperature_c': temperatureC,
      'severity': severity,
      'notes': notes,
    };
    if (existingId != null) return updateRow(_db, 'symptom_logs', existingId, fields);
    await insertRow(_db, 'symptom_logs', {'family_id': baby.familyId, 'baby_id': baby.id, ...fields});
  }

  Future<void> delete(String id) => updateRow(_db, 'symptom_logs', id, {'deleted_at': utcTimestamp(DateTime.now())});
}

final symptomRepositoryProvider = Provider((ref) => SymptomRepository(ref.watch(powerSyncProvider)));

/// The last 14 days, which is what the diary shows and the summary can cover.
final recentSymptomsProvider = StreamProvider.family<List<SymptomLog>, String>((ref, babyId) {
  final now = DateTime.now();
  return ref.watch(symptomRepositoryProvider).watchSince(babyId, DateTime(now.year, now.month, now.day - 14));
});

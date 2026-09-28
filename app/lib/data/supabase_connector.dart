import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/env.dart';

/// Connects the phone's database to the backend: PowerSync downloads using
/// the Supabase login token, and local changes are uploaded through
/// Supabase's normal API, so the same privacy rules apply to every write.
class SupabaseConnector extends PowerSyncBackendConnector {
  SupabaseConnector(this._supabase);

  final SupabaseClient _supabase;

  /// Columns stored as 0/1 on the phone but boolean in Postgres.
  static const _booleanColumns = {
    'diapers': {'is_wet', 'is_dirty'},
    'medications': {'as_needed'},
    'medication_doses': {'skipped'},
  };

  /// Columns stored as JSON text on the phone but arrays in Postgres.
  static const _arrayColumns = {
    'medications': {'dose_times'},
  };

  /// Errors a retry can't fix (bad data, constraint or permission failures).
  /// Such a change is dropped, otherwise it would block every later upload.
  static final _fatalCodes = [RegExp(r'^22...$'), RegExp(r'^23...$'), RegExp(r'^42501$')];

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    return PowerSyncCredentials(
      endpoint: Env.powersyncUrl,
      token: session.accessToken,
      userId: session.user.id,
      expiresAt: session.expiresAt == null ? null : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
    );
  }

  @override
  void invalidateCredentials() {
    // Token expired or rejected: get a fresh one; PowerSync asks again after.
    _supabase.auth.refreshSession().ignore();
  }

  Map<String, dynamic> _toServer(String table, Map<String, dynamic> data) => {
        for (final MapEntry(:key, :value) in data.entries)
          key: switch (value) {
            final int v when _booleanColumns[table]?.contains(key) ?? false => v == 1,
            final String v when _arrayColumns[table]?.contains(key) ?? false => jsonDecode(v),
            _ => value,
          },
      };

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    CrudEntry? current;
    try {
      for (final op in transaction.crud) {
        current = op;
        final table = _supabase.from(op.table);
        final data = _toServer(op.table, op.opData ?? const {});
        switch (op.op) {
          case UpdateType.put:
            await table.upsert({...data, 'id': op.id});
          case UpdateType.patch:
            await table.update(data).eq('id', op.id);
          case UpdateType.delete:
            await table.delete().eq('id', op.id);
        }
      }
      await transaction.complete();
    } on PostgrestException catch (e) {
      if (e.code != null && _fatalCodes.any((re) => re.hasMatch(e.code!))) {
        debugPrint('Upload rejected, discarding change $current: ${e.message}');
        await transaction.complete();
      } else {
        rethrow; // e.g. offline: PowerSync retries later
      }
    }
  }
}

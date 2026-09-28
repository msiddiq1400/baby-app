import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:uuid/uuid.dart';

/// The database on the phone. Opened in main() before the app starts.
final powerSyncProvider = Provider<PowerSyncDatabase>(
  (ref) => throw UnimplementedError('Overridden in main() with the opened database'),
);

/// Sync state: online or not, uploading, and whether the first download
/// after signing in has finished.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final db = ref.watch(powerSyncProvider);
  yield db.currentStatus;
  yield* db.statusStream;
});

const _uuid = Uuid();

/// SQLite has no booleans or arrays: store 0/1 and JSON text.
Object? _toSql(Object? value) => switch (value) {
      bool b => b ? 1 : 0,
      List<Object?> l => jsonEncode(l),
      _ => value,
    };

/// Inserts a row with a new id (unless [values] has one) and returns the id.
Future<String> insertRow(SqliteWriteContext db, String table, Map<String, Object?> values) async {
  final row = {'id': _uuid.v4(), ...values};
  final columns = row.keys.join(', ');
  final placeholders = List.filled(row.length, '?').join(', ');
  await db.execute('INSERT INTO $table ($columns) VALUES ($placeholders)', row.values.map(_toSql).toList());
  return row['id'] as String;
}

Future<void> updateRow(SqliteWriteContext db, String table, String id, Map<String, Object?> values) async {
  final assignments = values.keys.map((c) => '$c = ?').join(', ');
  await db.execute('UPDATE $table SET $assignments WHERE id = ?', [...values.values.map(_toSql), id]);
}

/// Re-runs [load] whenever any of [tables] changes (locally or from sync),
/// starting immediately.
Stream<T> watchTables<T>(PowerSyncDatabase db, List<String> tables, Future<T> Function() load) async* {
  await for (final _ in db.onChange(tables)) {
    yield await load();
  }
}

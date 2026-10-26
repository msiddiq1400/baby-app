// Keeps the phone's database and the server's in step. Fails when:
// - a table or column is on the phone (lib/data/local_schema.dart) but not
//   on the server (supabase/migrations), or the other way round for
//   columns the app reads;
// - a phone table isn't streamed (publication + powersync/sync-config.yaml);
// - code under lib/ reads or writes a table the phone doesn't have.
// When one of these fails after adding a column or table: add it on the
// other side too (a migration, the local schema, the sync config).

import 'dart:io';

import 'package:baby_app/data/local_schema.dart';
import 'package:baby_app/data/tracking_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'schema_guard_migrations.dart';

void main() {
  final server = parseServerTables();
  final synced = [
    for (final t in localSchema.tables)
      if (!t.localOnly && !t.name.startsWith('attachments')) t,
  ];
  final localNames = {for (final t in localSchema.tables) t.name};

  test('the migrations parse into the expected core tables', () {
    // A guard for the parser itself: if this fails, the checks below would
    // pass for the wrong reason.
    for (final t in ['families', 'babies', 'feeds', 'diapers', 'medications', 'photos']) {
      expect(server, contains(t), reason: t);
    }
    expect(server['feeds'], containsPair('timer_side', 'text'), reason: 'added by a later ALTER TABLE');
    expect(server['medications'], isNot(contains('every_hours')), reason: 'dropped by a later ALTER TABLE');
    expect(server['medications'], containsPair('as_needed', 'boolean'));
  });

  test('every table on the phone exists on the server', () {
    for (final t in synced) {
      expect(server, contains(t.name), reason: 'phone table ${t.name} has no server table');
    }
  });

  for (final t in synced) {
    test('every column of ${t.name} exists on the server', () {
      final selected = syncedColumns(t.name);
      final serverColumns = selected ?? server[t.name]?.keys.toSet() ?? const <String>{};
      for (final c in t.columns) {
        expect(serverColumns, contains(c.name), reason: '${t.name}.${c.name} is on the phone but not on the server');
      }
    });
  }

  test('every phone table is streamed to phones', () {
    final published = publishedTables();
    final downloaded = syncedTables();
    for (final t in synced) {
      expect(published, contains(t.name), reason: '${t.name} is missing from the powersync publication');
      expect(downloaded, contains(t.name), reason: '${t.name} is missing from powersync/sync-config.yaml');
    }
  });

  test('everything streamed has a table on the phone', () {
    for (final name in syncedTables()) {
      expect(localNames, contains(name), reason: 'sync-config downloads $name but the phone has no such table');
    }
  });

  test('code under lib/ only uses tables the phone has', () {
    final used = <String, String>{}; // table -> where
    final patterns = [
      RegExp(r"insertRow\(\s*\w+,\s*'(\w+)'"),
      RegExp(r"updateRow\(\s*\w+,\s*'(\w+)'"),
      RegExp(r'\b(?:FROM|JOIN|INTO|UPDATE)\s+([a-z_]+)\b'),
      RegExp(r"onChange\(\s*(?:const\s*)?\[([^\]]*)\]"),
      RegExp(r"watchTables\(\s*\w+,\s*(?:const\s*)?\[([^\]]*)\]"),
    ];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      if (f.path.contains('l10n')) continue;
      final source = f.readAsStringSync();
      for (final p in patterns) {
        for (final m in p.allMatches(source)) {
          for (final name in RegExp(r"[a-z_]+").allMatches(m.group(1)!).map((x) => x.group(0)!)) {
            used.putIfAbsent(name, () => f.path);
          }
        }
      }
    }
    expect(used, contains('feeds'), reason: 'the scan itself should find the tables');
    for (final MapEntry(key: table, value: where) in used.entries) {
      expect(localNames, contains(table), reason: '$where uses table "$table", which the phone does not have');
    }
    for (final t in TrackedTable.values) {
      expect(localNames, contains(t.name), reason: 'TrackedTable.${t.name}');
    }
  });
}

// Reads the server's tables and columns from supabase/migrations/*.sql (in
// file order: create table, then alter table add / drop / rename column),
// and the tables PowerSync streams (publication + sync-config.yaml). Used by
// schema_guard_test.dart and upload_test.dart to compare the phone's schema
// with the server's, so a column added on one side only fails a test.

import 'dart:io';

/// Server table -> column -> type as written in SQL, lower case (e.g.
/// 'uuid', 'boolean', 'time[]', 'public.feed_type').
typedef ServerTables = Map<String, Map<String, String>>;

/// Paths are relative to the app folder (where `flutter test` runs).
const migrationsDir = '../supabase/migrations';
const syncConfigPath = '../powersync/sync-config.yaml';

String _stripComments(String sql) => sql.replaceAll(RegExp(r'--[^\n]*'), '');

/// Splits on commas that aren't inside brackets.
List<String> _splitTopLevel(String body) {
  final parts = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < body.length; i++) {
    final c = body[i];
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (c == ',' && depth == 0) {
      parts.add(body.substring(start, i).trim());
      start = i + 1;
    }
  }
  parts.add(body.substring(start).trim());
  return parts.where((p) => p.isNotEmpty).toList();
}

final _notAColumn = RegExp(r'^(primary\s+key|foreign\s+key|unique|check|constraint|exclude)\b', caseSensitive: false);

/// Every migration, oldest first.
List<File> migrationFiles() {
  final files = Directory(migrationsDir).listSync().whereType<File>().where((f) => f.path.endsWith('.sql')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return files;
}

ServerTables parseServerTables() {
  final tables = <String, Map<String, String>>{};
  for (final file in migrationFiles()) {
    final sql = _stripComments(file.readAsStringSync());
    // Statements in order, so a later ALTER sees the CREATE before it.
    final statement = RegExp(
      r'create\s+table\s+(?:if\s+not\s+exists\s+)?public\.(\w+)\s*\((.*?)\)\s*;|alter\s+table\s+(?:only\s+)?public\.(\w+)\s+(.*?);',
      caseSensitive: false,
      dotAll: true,
    );
    for (final m in statement.allMatches(sql)) {
      if (m.group(1) != null) {
        final columns = <String, String>{};
        for (final part in _splitTopLevel(m.group(2)!)) {
          if (_notAColumn.hasMatch(part)) continue;
          final words = part.split(RegExp(r'\s+'));
          if (words.length < 2) continue;
          columns[words[0].toLowerCase()] = words[1].toLowerCase();
        }
        tables[m.group(1)!.toLowerCase()] = columns;
      } else {
        final table = tables[m.group(3)!.toLowerCase()];
        if (table == null) continue;
        for (final part in _splitTopLevel(m.group(4)!)) {
          final add = RegExp(r'^add\s+column\s+(?:if\s+not\s+exists\s+)?(\w+)\s+(\S+)', caseSensitive: false).firstMatch(part);
          final drop = RegExp(r'^drop\s+column\s+(?:if\s+exists\s+)?(\w+)', caseSensitive: false).firstMatch(part);
          final rename = RegExp(r'^rename\s+column\s+(\w+)\s+to\s+(\w+)', caseSensitive: false).firstMatch(part);
          if (add != null) table[add.group(1)!.toLowerCase()] = add.group(2)!.toLowerCase();
          if (drop != null) table.remove(drop.group(1)!.toLowerCase());
          if (rename != null) {
            final type = table.remove(rename.group(1)!.toLowerCase());
            if (type != null) table[rename.group(2)!.toLowerCase()] = type;
          }
        }
      }
    }
  }
  return tables;
}

/// Tables in the "powersync" publication (what the server streams out).
Set<String> publishedTables() {
  final names = <String>{};
  for (final file in migrationFiles()) {
    final sql = _stripComments(file.readAsStringSync());
    final pub = RegExp(
      r'(?:create\s+publication\s+powersync\s+for\s+table|alter\s+publication\s+powersync\s+add\s+table)\s+(.*?);',
      caseSensitive: false,
      dotAll: true,
    );
    for (final m in pub.allMatches(sql)) {
      for (final t in RegExp(r'public\.(\w+)').allMatches(m.group(1)!)) {
        names.add(t.group(1)!.toLowerCase());
      }
    }
  }
  return names;
}

/// Tables the sync config downloads to phones.
Set<String> syncedTables() {
  final yaml = File(syncConfigPath).readAsStringSync();
  return {for (final m in RegExp(r'\bFROM\s+(\w+)').allMatches(yaml)) m.group(1)!.toLowerCase()}
    ..remove('family_members'); // only used to pick the user's families
}

/// For a table synced with an explicit column list (e.g. vaccine_schedule),
/// the column names it selects (aliases included); null for SELECT *.
Set<String>? syncedColumns(String table) {
  final yaml = File(syncConfigPath).readAsStringSync();
  final from = RegExp(r'\bFROM\s+' + table + r'\b').firstMatch(yaml);
  if (from == null) return null;
  // The column list of the query that reads this table: from its SELECT.
  final select = yaml.lastIndexOf('SELECT', from.start);
  final list = yaml.substring(select + 'SELECT'.length, from.start).trim();
  if (list == '*') return null;
  return {
    for (final part in _splitTopLevel(list))
      RegExp(r'(\w+)\s*$').firstMatch(part)!.group(1)!.toLowerCase(),
  };
}

/// Tables phones only read (never upload to).
const downloadOnlyTables = {'vaccine_schedule'};

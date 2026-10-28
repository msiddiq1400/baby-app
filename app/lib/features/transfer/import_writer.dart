import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;

import '../../core/dates.dart';
import '../../data/local_db.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart' show sleepKindAt;
import 'import_model.dart';

/// How many entries were added, and how many were already there.
typedef ImportCounts = ({int added, int duplicates});

/// Rows per write transaction. Each transaction uploads as one batch, and
/// the server discards a whole batch if it rejects one row, so batches stay
/// small (the importers already drop rows the server would reject).
const importBatchSize = 100;

int _minute(DateTime t) => t.toUtc().millisecondsSinceEpoch ~/ 60000;

/// Minutes (since 1970, UTC) at which [table] already has an entry for the
/// baby, so importing the same file twice, or a file with entries already
/// logged in Palna, doesn't double them.
Future<Set<int>> _existingMinutes(SqliteReadContext db, String table, String column, String babyId) async {
  final rows = await db.getAll('SELECT $column AS t FROM $table WHERE baby_id = ? AND deleted_at IS NULL', [babyId]);
  return {for (final r in rows) _minute(DateTime.parse(r['t'] as String))};
}

/// Writes [entries] for [baby], skipping any that match an entry already
/// there (same kind within a minute; growth: same date). [onProgress] gets
/// the number done so far.
Future<ImportCounts> writeImport(
  PowerSyncDatabase db,
  Baby baby,
  List<ImportedEntry> entries, {
  void Function(int done)? onProgress,
}) async {
  final seen = {
    'feeds': await _existingMinutes(db, 'feeds', 'started_at', baby.id),
    'pumping_sessions': await _existingMinutes(db, 'pumping_sessions', 'started_at', baby.id),
    'diapers': await _existingMinutes(db, 'diapers', 'occurred_at', baby.id),
    'sleeps': await _existingMinutes(db, 'sleeps', 'started_at', baby.id),
    'activities': await _existingMinutes(db, 'activities', 'started_at', baby.id),
    'symptom_logs': await _existingMinutes(db, 'symptom_logs', 'occurred_at', baby.id),
  };
  final growthDays = {
    for (final r in await db.getAll(
      'SELECT measured_on FROM growth_measurements WHERE baby_id = ? AND deleted_at IS NULL',
      [baby.id],
    ))
      r['measured_on'] as String,
  };
  // A bottle of breast milk and one of formula at the same minute (a mixed
  // bottle) are two feeds: feeds are matched on minute and type.
  final feedKeys = {
    for (final r in await db.getAll(
      'SELECT started_at, type FROM feeds WHERE baby_id = ? AND deleted_at IS NULL',
      [baby.id],
    ))
      '${_minute(DateTime.parse(r['started_at'] as String))}/${r['type']}',
  };

  bool isNew(String table, DateTime at) {
    final m = _minute(at);
    final set = seen[table]!;
    if (set.contains(m) || set.contains(m - 1) || set.contains(m + 1)) return false;
    set.add(m);
    return true;
  }

  final base = {'family_id': baby.familyId, 'baby_id': baby.id};
  final writes = <(String, Map<String, Object?>)>[];
  var duplicates = 0;
  String? ts(DateTime? t) => t == null ? null : utcTimestamp(t);

  for (final e in entries) {
    final write = switch (e) {
      ImportedFeed() => () {
          final key = '${_minute(e.startedAt)}/${e.type.dbValue}';
          if (!feedKeys.add(key)) return null;
          final breast = e.type == FeedType.breast;
          final left = e.leftSeconds ?? 0, right = e.rightSeconds ?? 0;
          // Without times, a side that's set (even to 0) is the side used.
          final side = sideFromSeconds(left, right) ??
              switch ((e.leftSeconds != null, e.rightSeconds != null)) {
                (true, false) => BreastSide.left,
                (false, true) => BreastSide.right,
                _ => null,
              };
          return (
            'feeds',
            {
              'type': e.type.dbValue,
              'side': breast ? side?.name : null,
              'started_at': ts(e.startedAt),
              'ended_at': ts(e.endedAt),
              'amount_ml': breast ? null : e.amountMl,
              'left_seconds': breast ? e.leftSeconds : null,
              'right_seconds': breast ? e.rightSeconds : null,
              'notes': e.notes,
            },
          );
        }(),
      ImportedPumping() => isNew('pumping_sessions', e.startedAt)
          ? (
              'pumping_sessions',
              {
                'side': e.side?.name,
                'started_at': ts(e.startedAt),
                'ended_at': ts(e.endedAt),
                'amount_ml': e.amountMl,
                'notes': e.notes,
              },
            )
          : null,
      ImportedDiaper() => isNew('diapers', e.at)
          ? ('diapers', {'occurred_at': ts(e.at), 'is_wet': e.wet, 'is_dirty': e.dirty, 'notes': e.notes})
          : null,
      ImportedSleep() => isNew('sleeps', e.startedAt)
          ? (
              'sleeps',
              {
                'kind': (e.kind ?? sleepKindAt(e.startedAt)).name,
                'started_at': ts(e.startedAt),
                'ended_at': ts(e.endedAt),
                'notes': e.notes,
              },
            )
          : null,
      ImportedActivity() => isNew('activities', e.startedAt)
          ? (
              'activities',
              {
                'kind': e.kind.dbValue,
                'label': e.kind == ActivityKind.other ? e.label : null,
                'started_at': ts(e.startedAt),
                'ended_at': ts(e.endedAt ?? e.startedAt),
                'notes': e.notes,
              },
            )
          : null,
      ImportedGrowth() => growthDays.add(dateOnly(e.on))
          ? (
              'growth_measurements',
              {'measured_on': dateOnly(e.on), 'weight_g': e.weightG, 'length_mm': e.lengthMm, 'head_mm': e.headMm},
            )
          : null,
      ImportedTemperature() => isNew('symptom_logs', e.at)
          ? (
              'symptom_logs',
              {
                'symptom': e.celsius >= 38 ? 'fever' : 'other',
                'occurred_at': ts(e.at),
                'temperature_c': (e.celsius * 10).round() / 10,
                'notes': e.notes,
              },
            )
          : null,
    };
    if (write == null) {
      duplicates++;
    } else {
      writes.add(write);
    }
  }

  for (var i = 0; i < writes.length; i += importBatchSize) {
    final batch = writes.sublist(i, (i + importBatchSize).clamp(0, writes.length));
    await db.writeTransaction((tx) async {
      for (final (table, values) in batch) {
        await insertRow(tx, table, {...base, ...values});
      }
    });
    onProgress?.call(i + batch.length);
  }
  return (added: writes.length, duplicates: duplicates);
}

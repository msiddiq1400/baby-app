// Export and import on a real on-phone database (no widgets): the CSV holds
// every kind of entry; importing it into another baby recreates them;
// importing the same file again adds nothing (duplicates are skipped); big
// imports are written in small batches.

import 'package:baby_app/core/dates.dart';
import 'package:baby_app/data/local_db.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/transfer/csv.dart';
import 'package:baby_app/features/transfer/export.dart';
import 'package:baby_app/features/transfer/import_model.dart';
import 'package:baby_app/features/transfer/import_writer.dart';
import 'package:baby_app/features/transfer/importers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart';

import 'harness.dart';

Future<Baby> loadBaby(PowerSyncDatabase db, String id) async =>
    Baby.fromJson(await db.get('SELECT ${Baby.columns} FROM babies WHERE id = ?', [id]));

Future<int> count(PowerSyncDatabase db, String table, String babyId) async =>
    (await db.get('SELECT count(*) AS n FROM $table WHERE baby_id = ? AND deleted_at IS NULL', [babyId]))['n'] as int;

void main() {
  late FlowEnv env;
  late PowerSyncDatabase db;
  late Baby baby;
  late Baby other;

  setUp(() async {
    env = await FlowEnv.open();
    db = env.db;
    baby = await loadBaby(db, env.babyId!);
    other = await loadBaby(db, await env.seedBaby(name: 'Omar', sex: 'male'));
  });
  tearDown(() => env.close());

  final day = DateTime(2026, 10, 20);
  DateTime at(int hour, [int minute = 0]) => DateTime(day.year, day.month, day.day, hour, minute);

  Future<void> seed() async {
    final base = {'family_id': baby.familyId, 'baby_id': baby.id};
    await insertRow(db, 'feeds', {
      ...base,
      'type': 'breast',
      'side': 'both',
      'started_at': utcTimestamp(at(6)),
      'ended_at': utcTimestamp(at(6, 20)),
      'left_seconds': 600,
      'right_seconds': 600,
    });
    await insertRow(db, 'feeds', {
      ...base,
      'type': 'bottle_formula',
      'started_at': utcTimestamp(at(9)),
      'amount_ml': 120,
      'notes': 'Ate it all, "quickly"',
    });
    await insertRow(db, 'diapers', {...base, 'occurred_at': utcTimestamp(at(7)), 'is_wet': true, 'is_dirty': true});
    await insertRow(db, 'sleeps', {
      ...base,
      'kind': 'nap',
      'started_at': utcTimestamp(at(10)),
      'ended_at': utcTimestamp(at(11, 30)),
    });
    await insertRow(db, 'pumping_sessions', {
      ...base,
      'side': 'left',
      'started_at': utcTimestamp(at(11, 40)),
      'ended_at': utcTimestamp(at(11, 55)),
      'amount_ml': 90,
    });
    await insertRow(db, 'activities', {
      ...base,
      'kind': 'tummy_time',
      'started_at': utcTimestamp(at(13)),
      'ended_at': utcTimestamp(at(13, 10)),
    });
    await insertRow(db, 'activities', {
      ...base,
      'kind': 'other',
      'label': 'Swimming, with Dad',
      'started_at': utcTimestamp(at(15)),
      'ended_at': utcTimestamp(at(15)),
    });
    await insertRow(db, 'growth_measurements', {
      ...base,
      'measured_on': dateOnly(day),
      'weight_g': 5230,
      'length_mm': 585,
      'head_mm': 395,
    });
    await insertRow(db, 'symptom_logs', {
      ...base,
      'symptom': 'fever',
      'occurred_at': utcTimestamp(at(18)),
      'temperature_c': 38.4,
    });
    // Another baby's entries never appear in this baby's export.
    await insertRow(db, 'diapers', {
      'family_id': other.familyId,
      'baby_id': other.id,
      'occurred_at': utcTimestamp(at(8)),
      'is_wet': true,
      'is_dirty': false,
    });
  }

  test('the export has a row per entry, oldest first, with readable local times', () async {
    await seed();
    final table = CsvTable.parse(await exportCsv(db, baby));
    expect(table.header, PalnaCsv.header);
    // Growth has a date only: it sorts at midday.
    final types = [for (final r in table.rows) table.get(r, PalnaCsv.type)];
    expect(types, [
      'Feed', 'Diaper', 'Feed', 'Sleep', 'Pumping', 'Growth', 'Growth', 'Growth', 'Activity', 'Activity', 'Symptom', //
    ]);
    final bottle = table.rows[2];
    expect(table.get(bottle, PalnaCsv.start), '2026-10-20 09:00');
    expect(table.get(bottle, PalnaCsv.amount), '120');
    expect(table.get(bottle, PalnaCsv.notes), 'Ate it all, "quickly"');
    final sleep = table.rows[3];
    expect(table.get(sleep, PalnaCsv.minutes), '90');
    final swim = table.rows[9];
    expect(table.get(swim, PalnaCsv.label), 'Swimming, with Dad');
    expect(table.get(swim, PalnaCsv.end), isNull, reason: 'no duration');
    expect(exportFileName(baby, day), startsWith('palna-'));
    expect(exportFileName(baby, day), endsWith('-2026-10-20.csv'));
  });

  test('importing the export into another baby recreates the entries; a second import adds nothing', () async {
    await seed();
    final result = importPalna(await exportCsv(db, baby));
    expect(result.entries, hasLength(9)); // growth's three rows are one measurement

    final first = await writeImport(db, other, result.entries);
    expect(first.added, 9);
    expect(await count(db, 'feeds', other.id), 2);
    expect(await count(db, 'diapers', other.id), 2); // its own + the imported one
    expect(await count(db, 'sleeps', other.id), 1);
    expect(await count(db, 'pumping_sessions', other.id), 1);
    expect(await count(db, 'activities', other.id), 2);
    expect(await count(db, 'growth_measurements', other.id), 1);
    expect(await count(db, 'symptom_logs', other.id), 1);

    final growth = await db.get('SELECT weight_g, length_mm, head_mm FROM growth_measurements WHERE baby_id = ?', [other.id]);
    expect(growth, {'weight_g': 5230, 'length_mm': 585, 'head_mm': 395});
    final breast = await db.get(
      "SELECT side, left_seconds, right_seconds, started_at, ended_at FROM feeds WHERE baby_id = ? AND type = 'breast'",
      [other.id],
    );
    expect(breast['left_seconds'], 600);
    expect(breast['side'], 'both');
    expect(DateTime.parse(breast['started_at'] as String).toLocal(), at(6));
    final swim = await db.get("SELECT label, started_at, ended_at FROM activities WHERE baby_id = ? AND kind = 'other'", [
      other.id,
    ]);
    expect(swim['label'], 'Swimming, with Dad');
    expect(swim['ended_at'], swim['started_at']);

    final again = await writeImport(db, other, result.entries);
    expect(again, (added: 0, duplicates: 9));
  });

  test('big imports are written in batches and report progress', () async {
    final start = DateTime(2026, 9, 1, 8);
    final entries = [
      for (var i = 0; i < 250; i++)
        ImportedDiaper(at: start.add(Duration(minutes: 30 * i)), wet: true, dirty: i.isEven),
    ];
    final progress = <int>[];
    final counts = await writeImport(db, baby, entries, onProgress: progress.add);
    expect(counts, (added: 250, duplicates: 0));
    expect(progress, [100, 200, 250]);
    expect(await count(db, 'diapers', baby.id), 250);
  });

  test('entries within a minute of an existing one of the same kind are duplicates', () async {
    final t = DateTime(2026, 10, 1, 12, 0, 20);
    await writeImport(db, baby, [ImportedDiaper(at: t, wet: true, dirty: false)]);
    final counts = await writeImport(db, baby, [
      ImportedDiaper(at: t.add(const Duration(seconds: 50)), wet: true, dirty: false), // same minute-ish
      ImportedDiaper(at: t.add(const Duration(minutes: 5)), wet: true, dirty: false), // new
      // A mixed bottle: breast milk and formula at the same minute are two feeds.
      ImportedFeed(type: FeedType.bottleBreastMilk, startedAt: t, amountMl: 60),
      ImportedFeed(type: FeedType.bottleFormula, startedAt: t, amountMl: 60),
    ]);
    expect(counts, (added: 3, duplicates: 1));
  });

  test('a breastfeed with a side but no times keeps its side', () async {
    final t = DateTime(2026, 10, 2, 9);
    await writeImport(db, baby, [ImportedFeed(type: FeedType.breast, startedAt: t, rightSeconds: 0)]);
    final feed = await db.get('SELECT side, ended_at FROM feeds WHERE baby_id = ?', [baby.id]);
    expect(feed, {'side': 'right', 'ended_at': null});
  });
}

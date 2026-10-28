import 'dart:io';

import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/transfer/csv.dart';
import 'package:baby_app/features/transfer/import_model.dart';
import 'package:baby_app/features/transfer/importers.dart';
import 'package:flutter_test/flutter_test.dart';

String fixture(String name) => File('test/transfer/fixtures/$name').readAsStringSync();

/// A UTC instant, to compare with the importers' local times.
DateTime utc(int y, int mo, int d, [int h = 0, int mi = 0, int s = 0]) => DateTime.utc(y, mo, d, h, mi, s);

/// A small Nara file: the header is the union of the rows' columns.
String nara(List<Map<String, String>> rows) {
  final header = <String>{'Type', 'Start Date/time (Epoch)', for (final r in rows) ...r.keys}.toList();
  return csvDocument(header, [
    for (final r in rows) [for (final h in header) r[h]],
  ]);
}

/// 2026-09-22 07:00 in Pakistan (UTC+5).
const naraT0 = '1790042400000';

String huckleberry(List<String> rows) =>
    '"Type","Start","End","Duration","Start Condition","Start Location","End Condition","Notes"\n${rows.join('\n')}\n';

/// A Palna export with [rows] (cells in PalnaCsv.header order, from Baby).
String palna(List<List<Object?>> rows) => csvDocument(PalnaCsv.header, rows);

List<Object?> palnaRow(
  String type, {
  String? subtype,
  String? label,
  String? start,
  Object? amount,
  Object? left,
  Object? right,
  String? notes,
  String? startUtc,
  String? endUtc,
}) => ['Amna', type, subtype, label, start, null, null, amount, null, left, right, notes, startUtc, endUtc];

void main() {
  group('detectSource', () {
    test('recognises each export by its header', () {
      expect(detectSource(fixture('nara_full.csv')), ImportSource.nara);
      expect(detectSource(fixture('nara_sparse.csv')), ImportSource.nara);
      expect(detectSource(fixture('huckleberry.csv')), ImportSource.huckleberry);
      expect(detectSource(palna([])), ImportSource.palna);
    });

    test('anything else is null', () {
      expect(detectSource(''), isNull);
      expect(detectSource('Date,Amount\n2025-01-01,3\n'), isNull);
      expect(detectSource('just some text'), isNull);
    });

    test('each importer refuses the other formats', () {
      final huck = fixture('huckleberry.csv'), naraFile = fixture('nara_full.csv'), own = palna([]);
      expect(() => importNara(huck), throwsA(isA<ImportFormatException>()));
      expect(() => importNara(own), throwsA(isA<ImportFormatException>()));
      expect(() => importHuckleberry(naraFile), throwsA(isA<ImportFormatException>()));
      expect(() => importHuckleberry(own), throwsA(isA<ImportFormatException>()));
      expect(() => importPalna(naraFile), throwsA(isA<ImportFormatException>()));
      expect(() => importPalna(huck), throwsA(isA<ImportFormatException>()));
      expect(() => importPalna(''), throwsA(isA<ImportFormatException>()));
    });
  });

  group('Nara Baby, full header', () {
    final result = importNara(fixture('nara_full.csv'));
    final feeds = result.entries.whereType<ImportedFeed>().toList();
    final pumps = result.entries.whereType<ImportedPumping>().toList();
    final sleeps = result.entries.whereType<ImportedSleep>().toList();
    final diapers = result.entries.whereType<ImportedDiaper>().toList();
    final growth = result.entries.whereType<ImportedGrowth>().toList();
    final temps = result.entries.whereType<ImportedTemperature>().toList();
    final activities = result.entries.whereType<ImportedActivity>().toList();

    test('baby name from the Profile row (one cell short)', () {
      expect(result.babyName, 'Zara');
    });

    test('counts', () {
      expect(result.entries, hasLength(22));
      expect(result.skipped, {
        SkipReason.outOfRange: 2,
        SkipReason.sleepGoing: 1,
        SkipReason.dryDiaper: 1,
        SkipReason.medicine: 2,
        SkipReason.solidFood: 1,
        SkipReason.milestone: 2,
        SkipReason.vaccine: 1,
        'Other: Journal': 1,
        SkipReason.unreadable: 1,
      });
    });

    test('breastfeed: rounded side seconds, end = start + both, trimmed note', () {
      final f = feeds[0];
      expect(f.type, FeedType.breast);
      expect(f.startedAt.toUtc(), utc(2026, 9, 20, 3));
      expect(f.startedAt.isUtc, isFalse);
      expect((f.leftSeconds, f.rightSeconds), (300, 280));
      expect(f.endedAt!.toUtc(), utc(2026, 9, 20, 3, 9, 40));
      expect(f.notes, 'Good latch');
    });

    test('breastfeed without durations keeps the begin side (RIGHT.nonTimer)', () {
      final f = feeds[1];
      expect((f.leftSeconds, f.rightSeconds, f.endedAt), (null, 0, null));
      expect(f.notes, isNull);
    });

    test('bottles: fl oz to ml, mixed bottles split or counted as formula', () {
      expect(feeds[2].type, FeedType.bottleFormula);
      expect(feeds[2].amountMl, 118); // 4 fl oz
      expect((feeds[3].type, feeds[3].amountMl), (FeedType.bottleBreastMilk, 60));
      expect((feeds[4].type, feeds[4].amountMl), (FeedType.bottleFormula, 59)); // 2 oz
      expect(feeds[3].startedAt, feeds[4].startedAt);
      expect((feeds[5].type, feeds[5].amountMl), (FeedType.bottleFormula, 90)); // mixed, total only
    });

    test('combo feed: a breastfeed and a bottle', () {
      final breast = feeds[6], bottle = feeds[7];
      expect((breast.type, breast.leftSeconds, breast.rightSeconds), (FeedType.breast, 600, null));
      expect(breast.endedAt!.difference(breast.startedAt), const Duration(minutes: 10));
      expect((bottle.type, bottle.amountMl), (FeedType.bottleBreastMilk, 30));
      expect(feeds, hasLength(8));
    });

    test('pump: total and sides, duplicate activity key dropped', () {
      expect(pumps, hasLength(2));
      expect((pumps[0].amountMl, pumps[0].side), (130, BreastSide.both));
      expect(pumps[0].endedAt!.difference(pumps[0].startedAt), const Duration(minutes: 15));
      expect((pumps[1].amountMl, pumps[1].side), (59, BreastSide.left));
      expect(pumps[1].endedAt!.toUtc(), utc(2026, 9, 21, 8, 20));
    });

    test('sleep: end epoch, or start + duration', () {
      expect(sleeps, hasLength(2));
      expect(sleeps[0].endedAt.toUtc(), utc(2026, 9, 21, 5, 15));
      expect(sleeps[0].kind, isNull);
      expect(sleeps[1].endedAt.toUtc(), utc(2026, 9, 21, 9, 30));
    });

    test('diapers, with a multi-line quoted note', () {
      expect(diapers, hasLength(2));
      expect((diapers[0].wet, diapers[0].dirty), (true, false));
      expect((diapers[1].wet, diapers[1].dirty), (true, true));
      expect(diapers[1].notes, 'Leaked, changed clothes\nand "bodysuit"');
    });

    test('growth: units converted, out-of-range values dropped', () {
      expect(growth, hasLength(2));
      expect(growth[0].on, DateTime(2026, 9, 15));
      expect((growth[0].weightG, growth[0].lengthMm, growth[0].headMm), (4309, 546, 380));
      expect(growth[1].on, DateTime(2026, 9, 16));
      expect((growth[1].weightG, growth[1].lengthMm, growth[1].headMm), (null, 550, null));
    });

    test('temperature: F to C, one decimal; medication counted', () {
      expect(temps.map((t) => t.celsius), [38.5, 38.2]);
    });

    test('routines', () {
      expect(activities.map((a) => a.kind), [
        ActivityKind.bath,
        ActivityKind.reading,
        ActivityKind.tummyTime,
        ActivityKind.other,
      ]);
      expect(activities.map((a) => a.label), [null, null, null, 'Swaddle practice']);
      expect(activities.every((a) => a.endedAt == null), isTrue);
    });
  });

  group('Nara Baby, sparse header in another order', () {
    final result = importNara(fixture('nara_sparse.csv'));

    test('reads every row', () {
      expect(result.skipped, isEmpty);
      expect(result.entries, hasLength(6));
      expect(result.babyName, 'Ali'); // no Profile row
      final diapers = result.entries.whereType<ImportedDiaper>().toList();
      expect(diapers.map((d) => (d.wet, d.dirty)), [(true, false), (true, true), (true, false), (true, true)]);
      expect(diapers.last.notes, 'Rash, cream applied');
      final sleep = result.entries.whereType<ImportedSleep>().single;
      expect(sleep.endedAt.difference(sleep.startedAt), const Duration(minutes: 90));
      final feed = result.entries.whereType<ImportedFeed>().single;
      expect((feed.leftSeconds, feed.rightSeconds), (null, 420));
    });

    test('a row without an epoch falls back to the local start (device time)', () {
      final diaper = result.entries.whereType<ImportedDiaper>().toList()[2];
      expect(diaper.at, DateTime(2026, 9, 22, 14));
    });
  });

  group('Nara Baby, edge cases', () {
    test('Excel-mangled epochs refuse the whole file; fractional ones are fine', () {
      final mangled = fixture('nara_sparse.csv').replaceFirst('1790049600000', '1.79005E+12');
      expect(
        () => importNara(mangled),
        throwsA(isA<ImportFormatException>().having((e) => e.message, 'message', 're-saved in Excel')),
      );
      final decimal = nara([
        {'Type': 'Sleep', 'Start Date/time (Epoch)': naraT0, '[Sleep] End Date/time (Epoch)': '1790046000000.0'},
      ]);
      // Fractional milliseconds (Nara sometimes stores them) are read, not
      // taken for Excel.
      final sleep = importNara(decimal).entries.single as ImportedSleep;
      expect(sleep.endedAt, DateTime.fromMillisecondsSinceEpoch(1790046000000));
    });

    test('Postpartum rows are skipped silently, unknown types counted', () {
      final r = importNara(
        nara([
          {'Type': 'Postpartum Mood', 'Start Date/time (Epoch)': naraT0},
          {'Type': 'Teething', 'Start Date/time (Epoch)': naraT0},
        ]),
      );
      expect(r.entries, isEmpty);
      expect(r.skipped, {'Other: Teething': 1});
    });

    test('a breastfeed with nothing recorded has no side', () {
      final f =
          importNara(
                nara([
                  {
                    'Type': 'Breastfeed',
                    'Start Date/time (Epoch)': naraT0,
                    '[Breastfeed] Left Duration (Seconds)': '0',
                  },
                ]),
              ).entries.single
              as ImportedFeed;
      expect((f.leftSeconds, f.rightSeconds, f.endedAt), (null, null, null));
    });

    test('a combo feed with only a bottle gives one feed', () {
      final r = importNara(
        nara([
          {
            'Type': 'Combo Feed',
            'Start Date/time (Epoch)': naraT0,
            '[Combo Feed] Type': 'Formula',
            '[Combo Feed] Formula Volume': '2.5',
            '[Combo Feed] Formula Volume Unit': 'fl oz',
          },
        ]),
      );
      final f = r.entries.single as ImportedFeed;
      expect((f.type, f.amountMl), (FeedType.bottleFormula, 74));
    });

    test('pump sides: right only; left + right without a total', () {
      final r = importNara(
        nara([
          {
            'Type': 'Pump',
            'Start Date/time (Epoch)': naraT0,
            '[Pump] Right Volume': '40',
            '[Pump] Right Volume Unit': 'ML',
          },
          {
            'Type': 'Pump',
            'Start Date/time (Epoch)': naraT0,
            '[Pump] Left Volume': '40',
            '[Pump] Left Volume Unit': 'ML',
            '[Pump] Right Volume': '1',
            '[Pump] Right Volume Unit': 'OZ',
          },
        ]),
      );
      final pumps = r.entries.cast<ImportedPumping>();
      expect(pumps.map((p) => (p.amountMl, p.side, p.endedAt)), [
        (40, BreastSide.right, null),
        (70, BreastSide.both, null),
      ]);
    });

    test('bad values skip the row with a reason', () {
      final r = importNara(
        nara([
          // Ends before it starts.
          {'Type': 'Sleep', 'Start Date/time (Epoch)': naraT0, '[Sleep] End Date/time (Epoch)': '1790038800000'},
          // Negative duration.
          {'Type': 'Sleep', 'Start Date/time (Epoch)': naraT0, '[Sleep] Duration (Seconds)': '-60'},
          // Unknown unit.
          {
            'Type': 'Bottle Feed',
            'Start Date/time (Epoch)': naraT0,
            '[Bottle Feed] Volume': '3',
            '[Bottle Feed] Volume Unit': 'CUPS',
          },
          // Pump sides adding up to over a litre.
          {
            'Type': 'Pump',
            'Start Date/time (Epoch)': naraT0,
            '[Pump] Left Volume': '600',
            '[Pump] Left Volume Unit': 'ML',
            '[Pump] Right Volume': '600',
            '[Pump] Right Volume Unit': 'ML',
          },
          // A cold reading.
          {
            'Type': 'Medical',
            'Start Date/time (Epoch)': naraT0,
            '[Medical] Temperature': '80',
            '[Medical] Temperature Unit': 'F',
          },
          // No time at all.
          {'Type': 'Diaper', '[Diaper] Type': 'Wet'},
          // Not a number.
          {'Type': 'Diaper', 'Start Date/time (Epoch)': 'soon', '[Diaper] Type': 'Wet'},
          // A diaper type nobody knows.
          {'Type': 'Diaper', 'Start Date/time (Epoch)': naraT0, '[Diaper] Type': 'Sparkly'},
          // A growth row without measurements.
          {'Type': 'Growth', 'Start Date/time (Epoch)': naraT0},
        ]),
      );
      expect(r.entries, isEmpty);
      expect(r.skipped, {SkipReason.outOfRange: 4, SkipReason.unreadable: 5});
    });

    test('notes are capped at 500 characters; blank notes dropped', () {
      final r = importNara(
        nara([
          {'Type': 'Diaper', 'Start Date/time (Epoch)': naraT0, '[Diaper] Type': 'Wet', 'Note': '${'ب' * 600}  '},
          {'Type': 'Diaper', 'Start Date/time (Epoch)': naraT0, '[Diaper] Type': 'Wet', 'Note': '   '},
        ]),
      );
      final diapers = r.entries.cast<ImportedDiaper>().toList();
      expect(diapers[0].notes!.runes.length, 500);
      expect(diapers[1].notes, isNull);
    });

    test('routine labels: other, capped at 60 characters; outdoors', () {
      final r = importNara(
        nara([
          {'Type': 'Routine', 'Start Date/time (Epoch)': naraT0, '[Routine] Routine': 'x' * 80},
          {'Type': 'Routine', 'Start Date/time (Epoch)': naraT0, '[Routine] Routine': 'Stroll in the park'},
          {'Type': 'Routine', 'Start Date/time (Epoch)': naraT0, '[Routine] Routine': 'MASSAGE'},
          {'Type': 'Routine', 'Start Date/time (Epoch)': naraT0, '[Routine] Routine': 'Playtime'},
        ]),
      );
      final a = r.entries.cast<ImportedActivity>().toList();
      expect(a[0].kind, ActivityKind.other);
      expect(a[0].label, 'x' * 60);
      expect(a.skip(1).map((e) => e.kind), [ActivityKind.outdoors, ActivityKind.massage, ActivityKind.play]);
    });

    test('growth in ounces and a temperature in C without a unit', () {
      final r = importNara(
        nara([
          {'Type': 'Growth', 'Start Date/time (Epoch)': naraT0, '[Growth] Weight': '120', '[Growth] Weight Unit': 'OZ'},
          {'Type': 'Medical', 'Start Date/time (Epoch)': naraT0, '[Medical] Temperature': '37.04'},
        ]),
      );
      expect((r.entries[0] as ImportedGrowth).weightG, 3402);
      expect((r.entries[1] as ImportedTemperature).celsius, 37.0);
    });
  });

  group('Huckleberry', () {
    final result = importHuckleberry(fixture('huckleberry.csv'));
    final feeds = result.entries.whereType<ImportedFeed>().toList();

    test('counts', () {
      expect(result.entries, hasLength(16));
      expect(result.babyName, isNull);
      expect(result.skipped, {
        SkipReason.sleepGoing: 1,
        SkipReason.dryDiaper: 1,
        SkipReason.outOfRange: 1,
        SkipReason.medicine: 1,
        SkipReason.solidFood: 1,
        'Other: Potty': 1,
      });
    });

    test('bottles: milk type, ml and oz; cow milk as formula', () {
      expect(feeds.take(3).map((f) => (f.type, f.amountMl)), [
        (FeedType.bottleFormula, 150),
        (FeedType.bottleBreastMilk, 133),
        (FeedType.bottleFormula, 89),
      ]);
      expect(feeds[0].startedAt, DateTime(2025, 3, 2, 6, 10));
      expect(feeds[0].endedAt, isNull);
      expect(feeds[1].notes, 'Fussy after');
    });

    test('breastfeeds: sides by suffix, whichever column', () {
      expect(feeds.skip(3).map((f) => (f.type, f.leftSeconds, f.rightSeconds)), [
        (FeedType.breast, 360, 480),
        (FeedType.breast, 720, null),
        (FeedType.breast, null, 540),
      ]);
      expect(feeds[3].endedAt, DateTime(2025, 3, 1, 18, 17));
    });

    test('sleep', () {
      final s = result.entries.whereType<ImportedSleep>().single;
      expect((s.startedAt, s.endedAt), (DateTime(2025, 3, 1, 9, 20), DateTime(2025, 3, 1, 10, 45)));
    });

    test('diapers: first word of End Condition; notes kept', () {
      final d = result.entries.whereType<ImportedDiaper>().toList();
      expect(d.map((e) => (e.wet, e.dirty)), [(false, true), (true, false), (true, true)]);
      expect(d[0].notes, 'Blowout');
    });

    test('pump: amounts summed; both sides only when both are set', () {
      final p = result.entries.whereType<ImportedPumping>().toList();
      expect(p.map((e) => (e.amountMl, e.side)), [(200, BreastSide.both), (89, null)]);
      expect(p[0].endedAt, DateTime(2025, 2, 28, 21, 20));
    });

    test('growth: kg/cm, decimal pounds and decimal feet', () {
      final g = result.entries.whereType<ImportedGrowth>().toList();
      expect(g.map((e) => (e.weightG, e.lengthMm, e.headMm)), [(6450, 640, 415), (5783, 625, 409)]);
      expect(g[1].on, DateTime(2025, 1, 15));
    });

    test('tummy time and bath', () {
      final a = result.entries.whereType<ImportedActivity>().toList();
      expect(a.map((e) => e.kind), [ActivityKind.tummyTime, ActivityKind.bath]);
      expect(a[0].endedAt, DateTime(2025, 2, 27, 10, 7));
      expect(a[1].endedAt, isNull);
    });

    test('an extra Logged By column is fine', () {
      final r = importHuckleberry(
        '"Type","Start","End","Duration","Start Condition","Start Location","End Condition","Notes","Logged By"\n'
        '"Diaper","2025-01-29 20:34",,,,,"Pee",,"Mum"\n',
      );
      expect(r.entries.single, isA<ImportedDiaper>());
    });

    test('bad rows: end before start, future date, broken time, odd amount', () {
      final r = importHuckleberry(
        huckleberry([
          '"Sleep","2025-03-01 10:00","2025-03-01 09:00","00:00",,,,',
          '"Diaper","2099-01-01 10:00",,,,,"Pee",',
          '"Diaper","01/03/2025 10:00",,,,,"Pee",',
          '"Feed","2025-03-01 10:00",,,"Formula","Bottle","a lot",',
          '"Feed","2025-03-01 10:00",,,"Formula","Bottle","1.2l",',
          '"Feed","2025-03-01 10:00",,,,"Spoon",,',
        ]),
      );
      expect(r.entries, isEmpty);
      expect(r.skipped, {SkipReason.outOfRange: 1, SkipReason.unreadable: 5});
    });
  });

  group('Palna', () {
    final result = importPalna(
      palna([
        palnaRow(
          'Feed',
          subtype: 'breast',
          left: 600,
          right: 300,
          notes: ' sleepy ',
          startUtc: '2026-10-01T05:00:00.000Z',
          endUtc: '2026-10-01T05:15:00.000Z',
        ),
        palnaRow('Feed', subtype: 'bottle_formula', amount: 120, startUtc: '2026-10-01T08:00:00.000Z'),
        palnaRow('Feed', subtype: 'bottle_breast_milk', amount: 1200, startUtc: '2026-10-01T09:00:00.000Z'),
        palnaRow('Feed', subtype: 'solids', startUtc: '2026-10-01T10:00:00.000Z'),
        palnaRow('Feed', subtype: 'breast', startUtc: 'not a date'),
        palnaRow('Pumping', subtype: 'left', amount: 80, startUtc: '2026-10-01T11:00:00.000Z'),
        palnaRow('Pumping', amount: 50, startUtc: '2026-10-01T12:00:00.000Z', endUtc: '2026-10-01T12:20:00.000Z'),
        palnaRow('Diaper', subtype: 'both', startUtc: '2026-10-01T13:00:00.000Z'),
        palnaRow('Diaper', subtype: 'wet', startUtc: '2026-10-01T14:00:00.000Z'),
        palnaRow('Sleep', subtype: 'nap', startUtc: '2026-10-01T15:00:00.000Z', endUtc: '2026-10-01T16:00:00.000Z'),
        palnaRow('Sleep', subtype: 'night', startUtc: '2026-10-01T17:00:00.000Z'),
        palnaRow(
          'Activity',
          subtype: 'tummy_time',
          startUtc: '2026-10-01T06:00:00.000Z',
          endUtc: '2026-10-01T06:05:00.000Z',
        ),
        palnaRow('Activity', subtype: 'other', label: 'Swimming', startUtc: '2026-10-01T07:00:00.000Z'),
        palnaRow('Growth', subtype: 'weight', start: '2026-09-01', amount: 4.25, notes: 'clinic'),
        palnaRow('Growth', subtype: 'length', start: '2026-09-01', amount: 55.5),
        palnaRow('Growth', subtype: 'head', start: '2026-09-01', amount: 38),
        palnaRow('Growth', subtype: 'weight', start: '2026-09-01', amount: 4.3),
        palnaRow('Growth', subtype: 'weight', start: '2026-09-02', amount: 90),
        palnaRow('Growth', subtype: 'head', start: '2026-09-02', amount: 39),
        palnaRow('Symptom', subtype: 'fever', amount: 38.6, startUtc: '2026-10-02T05:00:00.000Z'),
        palnaRow('Symptom', subtype: 'cough', startUtc: '2026-10-02T06:00:00.000Z'),
        palnaRow('Medicine', subtype: 'Calpol', label: 'given', startUtc: '2026-10-02T07:00:00.000Z'),
        palnaRow('Vaccine', subtype: 'bcg', label: 'BCG', start: '2026-08-02'),
        palnaRow('Doctor visit', label: 'Dr Khan', startUtc: '2026-10-02T08:00:00.000Z'),
        palnaRow('Food', subtype: 'banana', start: '2026-10-03'),
        palnaRow('Milestone', subtype: 'smile', start: '2026-09-10'),
      ]),
    );

    test('baby name and counts', () {
      expect(result.babyName, 'Amna');
      expect(result.entries, hasLength(13));
      expect(result.skipped, {
        SkipReason.outOfRange: 2,
        SkipReason.solidFood: 2,
        SkipReason.unreadable: 1,
        SkipReason.sleepGoing: 1,
        'Other: Symptom': 1,
        SkipReason.medicine: 1,
        SkipReason.vaccine: 1,
        SkipReason.doctorVisit: 1,
        SkipReason.milestone: 1,
      });
    });

    test('feeds from the UTC columns, as local times', () {
      final f = result.entries.whereType<ImportedFeed>().toList();
      expect(f, hasLength(2));
      expect(f[0].startedAt.isUtc, isFalse);
      expect(f[0].startedAt.toUtc(), utc(2026, 10, 1, 5));
      expect(f[0].endedAt!.toUtc(), utc(2026, 10, 1, 5, 15));
      expect((f[0].type, f[0].leftSeconds, f[0].rightSeconds, f[0].amountMl), (FeedType.breast, 600, 300, null));
      expect(f[0].notes, 'sleepy');
      expect((f[1].type, f[1].amountMl, f[1].leftSeconds), (FeedType.bottleFormula, 120, null));
    });

    test('pumping, diapers, sleep and activities', () {
      final p = result.entries.whereType<ImportedPumping>().toList();
      expect(p.map((e) => (e.amountMl, e.side)), [(80, BreastSide.left), (50, null)]);
      final d = result.entries.whereType<ImportedDiaper>().toList();
      expect(d.map((e) => (e.wet, e.dirty)), [(true, true), (true, false)]);
      final s = result.entries.whereType<ImportedSleep>().single;
      expect((s.kind, s.endedAt.toUtc()), (SleepKind.nap, utc(2026, 10, 1, 16)));
      final a = result.entries.whereType<ImportedActivity>().toList();
      expect(a.map((e) => (e.kind, e.label)), [(ActivityKind.tummyTime, null), (ActivityKind.other, 'Swimming')]);
      expect(a[1].endedAt, isNull);
    });

    test('growth rows merged by date; a second weighing stays separate', () {
      final g = result.entries.whereType<ImportedGrowth>().toList();
      expect(g.map((e) => (e.on, e.weightG, e.lengthMm, e.headMm)), [
        (DateTime(2026, 9, 1), 4250, 555, 380),
        (DateTime(2026, 9, 1), 4300, null, null),
        (DateTime(2026, 9, 2), null, null, 390),
      ]);
    });

    test('a symptom with a temperature', () {
      final t = result.entries.whereType<ImportedTemperature>().single;
      expect((t.celsius, t.at.toUtc()), (38.6, utc(2026, 10, 2, 5)));
    });

    test('the header alone is an empty import', () {
      final r = importPalna(palna([]));
      expect(r.entries, isEmpty);
      expect(r.skipped, isEmpty);
      expect(r.babyName, isNull);
    });
  });
}

// Today tab flows on the real app and database: logging, editing and
// deleting feeds, diapers and sleep from the Feed / Diaper / Sleep bar and
// the cards, what Today then shows (counts, last feed, the timeline), and
// the card buttons (past entries, past days, reports). Timers are in
// timers_flow_test.dart; the journal and reports in
// journal_reports_flow_test.dart.

import 'package:baby_app/core/dates.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/features/home/live_timers.dart';
import 'package:baby_app/features/home/timeline.dart';
import 'package:baby_app/features/journal/journal_screen.dart';
import 'package:baby_app/features/reports/reports_screen.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// Inside the open form sheet.
Finder inSheet(Finder f) => find.descendant(of: find.byType(BottomSheet), matching: f);

/// The Feed / Diaper / Sleep bar button with [label].
Finder barButton(String label) => find.widgetWithText(FilledButton, label).first;

/// Today's timeline rows, top to bottom.
List<String> timelineTexts(WidgetTester tester) => [
      for (final tile in tester.widgetList<ListTile>(find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile))))
        (tile.title! as Text).data!,
    ];

/// A time earlier today, [fraction] of the way from midnight to now, so
/// entries stay on Today whatever time the test runs.
DateTime todayAt(double fraction) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return start.add(Duration(microseconds: (now.difference(start).inMicroseconds * fraction).round()));
}

DateTime parseUtc(Object? v) => DateTime.parse(v! as String).toLocal();

/// Picks yesterday in the date picker opened by a form's day button.
Future<void> pickYesterday(WidgetTester tester) async {
  await tapAndSettle(tester, inSheet(find.widgetWithText(OutlinedButton, en.tabToday)));
  final now = DateTime.now();
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (yesterday.month != now.month) {
    await tapAndSettle(tester, find.byTooltip('Previous month'));
  }
  await tapAndSettle(tester, find.descendant(of: find.byType(Dialog), matching: find.text('${yesterday.day}')));
  await tapAndSettle(tester, find.text('OK'));
}

/// testWidgets that removes the app at the end of the body and lets its
/// database watches finish, so no throttle timer is left pending when
/// flutter_test checks for timers.
void flowTest(String description, Future<void> Function(WidgetTester tester) body) =>
    flowWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

void main() {
  setUpFlowTests();

  late FlowEnv env;
  setUp(() async => env = await FlowEnv.open());
  tearDown(() => env.close());

  Future<void> insertFeed(WidgetTester tester, {required String type, required DateTime at, int? ml, int? left, int? right}) =>
      env.exec(
        tester,
        'INSERT INTO feeds (id, family_id, baby_id, type, started_at, amount_ml, left_seconds, right_seconds) '
        'VALUES (uuid(), ?, ?, ?, ?, ?, ?, ?)',
        [env.familyId, env.babyId, type, utcTimestamp(at), ml, left, right],
      );

  group('feeds', () {
    flowTest('a breastfeed with left and right minutes is saved with both sides', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, barButton(en.logFeed));
      await enterField(tester, en.leftMinutes, '7');
      await enterField(tester, en.rightMinutes, '5');
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      expectNoErrors(tester);

      final feed = (await env.rows(tester, 'SELECT * FROM feeds')).single;
      expect(feed['type'], 'breast');
      expect(feed['left_seconds'], 420);
      expect(feed['right_seconds'], 300);
      expect(feed['ended_at'], isNotNull);
      // Started 12 minutes before it ended.
      expect(parseUtc(feed['ended_at']).difference(parseUtc(feed['started_at'])), const Duration(minutes: 12));
      expect(find.byType(BottomSheet), findsNothing);
      expect(timelineTexts(tester).single, contains(en.sideLeft));
    });

    flowTest('expressed milk and formula feeds store their amount', (tester) async {
      await env.pumpApp(tester);
      for (final (label, type, ml) in [
        (en.feedTypeBottleBreastMilk, 'bottle_breast_milk', '90'),
        (en.feedTypeFormula, 'bottle_formula', '120'),
      ]) {
        await tapAndSettle(tester, barButton(en.logFeed));
        await tapAndSettle(tester, inSheet(find.text(label)));
        await enterField(tester, en.amountMl, ml);
        await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
        final row = (await env.rows(tester, 'SELECT type, amount_ml, left_seconds FROM feeds WHERE type = ?', [type])).single;
        expect(row['amount_ml'], int.parse(ml), reason: type);
        expect(row['left_seconds'], isNull, reason: type);
      }
      expectNoErrors(tester);
      expect(find.textContaining('120 ml'), findsWidgets);
    });

    flowTest('a bottle without a valid amount is not saved', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, barButton(en.logFeed));
      await tapAndSettle(tester, inSheet(find.text(en.feedTypeFormula)));
      for (final bad in ['', '0', '5000']) {
        await enterField(tester, en.amountMl, bad);
        await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
        expect(find.text(en.invalidAmount), findsOneWidget, reason: '"$bad"');
      }
      expect(await env.rows(tester, 'SELECT id FROM feeds'), isEmpty);
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    flowTest('breast minutes outside 1-180 are refused', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, barButton(en.logFeed));
      await enterField(tester, en.leftMinutes, '200');
      await enterField(tester, en.rightMinutes, '0');
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      expect(find.text(en.invalidMinutes), findsNWidgets(2));
      expect(await env.rows(tester, 'SELECT id FROM feeds'), isEmpty);
    });

    flowTest('a new feed starts as the last feed: same type and bottle amount', (tester) async {
      await insertFeed(tester, type: 'bottle_formula', at: todayAt(0.5), ml: 140);
      await env.pumpApp(tester);
      await tapAndSettle(tester, barButton(en.logFeed));
      final amount = tester.widget<TextFormField>(inSheet(find.widgetWithText(TextFormField, en.amountMl)));
      expect(amount.controller!.text, '140');
      // So a repeat bottle is just Feed > Save.
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      final rows = await env.rows(tester, 'SELECT type, amount_ml FROM feeds');
      expect(rows, hasLength(2));
      expect(rows.every((r) => r['type'] == 'bottle_formula' && r['amount_ml'] == 140), isTrue);
    });

    flowTest('a past feed can be put on yesterday with the day button', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.pastFeedShort));
      expect(inSheet(find.text(en.addPastFeed)), findsOneWidget);
      // A past feed has no timer buttons.
      expect(inSheet(find.text(en.startFeedTimer)), findsNothing);
      await tapAndSettle(tester, inSheet(find.text(en.feedTypeFormula)));
      await enterField(tester, en.amountMl, '100');
      await pickYesterday(tester);
      expect(inSheet(find.widgetWithText(OutlinedButton, en.yesterday)), findsOneWidget);
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));

      final started = parseUtc((await env.rows(tester, 'SELECT started_at FROM feeds')).single['started_at']);
      final now = DateTime.now();
      expect(DateTime(started.year, started.month, started.day), DateTime(now.year, now.month, now.day - 1));
      // Not on Today.
      expect(find.text(en.nothingLoggedToday), findsOneWidget);
    });

    flowTest('tapping a feed in the timeline edits it', (tester) async {
      await insertFeed(tester, type: 'bottle_formula', at: todayAt(0.5), ml: 120);
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile)));
      expect(inSheet(find.text(en.editFeed)), findsOneWidget);
      await enterField(tester, en.amountMl, '150');
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));

      final rows = await env.rows(tester, 'SELECT amount_ml FROM feeds');
      expect(rows.single['amount_ml'], 150, reason: 'updated, not added');
      expect(timelineTexts(tester).single, contains('150 ml'));
    });

    flowTest('deleting a feed hides it everywhere but keeps the row for sync', (tester) async {
      await insertFeed(tester, type: 'bottle_formula', at: todayAt(0.5), ml: 120);
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile)));
      await tapAndSettle(tester, inSheet(find.widgetWithText(TextButton, en.deleteButton)));
      // Asks first.
      expect(find.text(en.deleteConfirmTitle), findsOneWidget);
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));

      expect((await env.rows(tester, 'SELECT deleted_at FROM feeds')).single['deleted_at'], isNotNull);
      expect(find.text(en.nothingLoggedToday), findsOneWidget);
      expectNoErrors(tester);
    });

    flowTest('cancelling the delete keeps the feed', (tester) async {
      await insertFeed(tester, type: 'bottle_formula', at: todayAt(0.5), ml: 120);
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile)));
      await tapAndSettle(tester, inSheet(find.widgetWithText(TextButton, en.deleteButton)));
      await tapAndSettle(tester, find.text(en.cancelButton));
      expect((await env.rows(tester, 'SELECT deleted_at FROM feeds')).single['deleted_at'], isNull);
    });
  });

  group('diapers', () {
    flowTest('Wet, Dirty and Both each save straight away, and Today counts them', (tester) async {
      await env.pumpApp(tester);
      for (final label in [en.diaperWet, en.diaperDirty, en.diaperBoth]) {
        await tapAndSettle(tester, barButton(en.logDiaper));
        // No Save button: the kind is the save.
        expect(inSheet(find.widgetWithText(FilledButton, en.saveButton)), findsNothing);
        await tapAndSettle(tester, inSheet(find.text(label)));
        expect(find.byType(BottomSheet), findsNothing, reason: label);
      }
      final rows = await env.rows(tester, 'SELECT is_wet, is_dirty FROM diapers ORDER BY julianday(occurred_at)');
      expect(rows, [
        {'is_wet': 1, 'is_dirty': 0},
        {'is_wet': 0, 'is_dirty': 1},
        {'is_wet': 1, 'is_dirty': 1},
      ]);
      expect(find.text(en.diaperCounts(2, 2)), findsOneWidget);
      expectNoErrors(tester);
    });

    flowTest('Past diaper from the card saves an earlier diaper', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.pastDiaperShort));
      expect(inSheet(find.text(en.addPastDiaper)), findsOneWidget);
      await pickYesterday(tester);
      await tapAndSettle(tester, inSheet(find.text(en.diaperWet)));
      final at = parseUtc((await env.rows(tester, 'SELECT occurred_at FROM diapers')).single['occurred_at']);
      final now = DateTime.now();
      expect(DateTime(at.year, at.month, at.day), DateTime(now.year, now.month, now.day - 1));
    });

    flowTest('editing a diaper changes its kind; deleting hides it', (tester) async {
      await env.exec(
        tester,
        'INSERT INTO diapers (id, family_id, baby_id, occurred_at, is_wet, is_dirty) VALUES (uuid(), ?, ?, ?, 1, 0)',
        [env.familyId, env.babyId, utcTimestamp(todayAt(0.5))],
      );
      await env.pumpApp(tester);
      expect(find.text(en.diaperCounts(1, 0)), findsOneWidget);
      await tapAndSettle(tester, find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile)));
      expect(inSheet(find.text(en.editDiaper)), findsOneWidget);
      await tapAndSettle(tester, inSheet(find.text(en.diaperBoth)));
      expect((await env.rows(tester, 'SELECT is_wet, is_dirty FROM diapers')).single, {'is_wet': 1, 'is_dirty': 1});
      expect(find.text(en.diaperCounts(1, 1)), findsOneWidget);

      await tapAndSettle(tester, find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile)));
      await tapAndSettle(tester, inSheet(find.widgetWithText(TextButton, en.deleteButton)));
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));
      expect((await env.rows(tester, 'SELECT deleted_at FROM diapers')).single['deleted_at'], isNotNull);
      expect(find.text(en.nothingLoggedToday), findsOneWidget);
    });
  });

  group('sleep', () {
    flowTest('Sleep > Save starts a sleep; the card and the bar then offer Woke up, which ends it', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, barButton(en.startSleep));
      expect(inSheet(find.text(en.startSleepTitle)), findsOneWidget);
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));

      final sleep = (await env.rows(tester, 'SELECT kind, ended_at FROM sleeps')).single;
      expect(sleep['ended_at'], isNull);
      final asleep = sleep['kind'] == 'night' ? en.asleepNight : en.asleepNap;
      expect(find.text(asleep), findsOneWidget);
      // The bar's Sleep button became Woke up.
      expect(find.widgetWithText(FilledButton, en.endSleep), findsNWidgets(2));

      // The card's Woke up ends it at once.
      await tapAndSettle(
        tester,
        find.descendant(of: find.byType(SleepTimerCard), matching: find.widgetWithText(FilledButton, en.endSleep)),
      );
      expect((await env.rows(tester, 'SELECT ended_at FROM sleeps')).single['ended_at'], isNotNull);
      expect(find.text(asleep), findsNothing);
      expect(find.widgetWithText(FilledButton, en.startSleep), findsOneWidget);
      expectNoErrors(tester);
    });

    flowTest('Woke up on the bar opens the form with the wake time, and Save ends the sleep', (tester) async {
      await env.exec(
        tester,
        "INSERT INTO sleeps (id, family_id, baby_id, kind, started_at) VALUES (uuid(), ?, ?, 'nap', ?)",
        [env.familyId, env.babyId, utcTimestamp(todayAt(0.5))],
      );
      await env.pumpApp(tester);
      // The bar's button (the card has one too; the bar's is last).
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.endSleep).last);
      // Title and end time both read "Woke up"; the sleep is no longer "still asleep".
      expect(inSheet(find.text(en.endSleep)), findsWidgets);
      expect(tester.widget<SwitchListTile>(inSheet(find.byType(SwitchListTile))).value, isFalse);
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      final row = (await env.rows(tester, 'SELECT ended_at FROM sleeps')).single;
      expect(parseUtc(row['ended_at']).difference(DateTime.now()).inMinutes.abs(), lessThan(2));
    });

    flowTest('choosing Night stores a night sleep', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, barButton(en.startSleep));
      await tapAndSettle(tester, inSheet(find.text(en.sleepNight)));
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      expect((await env.rows(tester, 'SELECT kind FROM sleeps')).single['kind'], 'night');
      expect(find.text(en.asleepNight), findsOneWidget);
    });

    flowTest('turning off Still asleep saves a finished sleep', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, barButton(en.startSleep));
      expect(inSheet(find.text(en.sleepEndLabel)), findsNothing);
      await tapAndSettle(tester, inSheet(find.widgetWithText(SwitchListTile, en.stillAsleep)));
      expect(inSheet(find.text(en.sleepEndLabel)), findsOneWidget);
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      expect((await env.rows(tester, 'SELECT ended_at FROM sleeps')).single['ended_at'], isNotNull);
      expect(find.text(en.asleepNap), findsNothing);
      expect(find.text(en.asleepNight), findsNothing);
    });

    flowTest('Past sleep from the card saves the last hour, already over', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.pastSleepShort));
      expect(inSheet(find.text(en.addPastSleep)), findsOneWidget);
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      final row = (await env.rows(tester, 'SELECT started_at, ended_at FROM sleeps')).single;
      expect(parseUtc(row['ended_at']).difference(parseUtc(row['started_at'])).inMinutes, inInclusiveRange(59, 61));
    });

    flowTest('while a sleep is going, another one cannot also be "still asleep"', (tester) async {
      await env.exec(
        tester,
        "INSERT INTO sleeps (id, family_id, baby_id, kind, started_at) VALUES (uuid(), ?, ?, 'nap', ?)",
        [env.familyId, env.babyId, utcTimestamp(todayAt(0.5))],
      );
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.pastSleepShort));
      expect(inSheet(find.text(en.stillAsleep)), findsNothing);
      expect(inSheet(find.text(en.sleepEndLabel)), findsOneWidget);
    });

    flowTest('editing a sleep from the timeline changes its kind; deleting hides it', (tester) async {
      final start = todayAt(0.3);
      await env.exec(
        tester,
        "INSERT INTO sleeps (id, family_id, baby_id, kind, started_at, ended_at) VALUES (uuid(), ?, ?, 'nap', ?, ?)",
        [env.familyId, env.babyId, utcTimestamp(start), utcTimestamp(todayAt(0.4))],
      );
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile)));
      expect(inSheet(find.text(en.editSleep)), findsOneWidget);
      await tapAndSettle(tester, inSheet(find.text(en.sleepNight)));
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, en.saveButton)));
      expect((await env.rows(tester, 'SELECT kind FROM sleeps')).single['kind'], 'night');
      expect(timelineTexts(tester).single, startsWith(en.sleepNight));

      await tapAndSettle(tester, find.descendant(of: find.byType(Timeline), matching: find.byType(ListTile)));
      await tapAndSettle(tester, inSheet(find.widgetWithText(TextButton, en.deleteButton)));
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));
      expect((await env.rows(tester, 'SELECT deleted_at FROM sleeps')).single['deleted_at'], isNotNull);
      expect(find.text(en.nothingLoggedToday), findsOneWidget);
    });
  });

  group('Today cards and timeline', () {
    flowTest('the cards count today only, and Feeds shows the last feed', (tester) async {
      final now = DateTime.now();
      // Yesterday's entries don't count on Today.
      await insertFeed(tester, type: 'bottle_formula', at: DateTime(now.year, now.month, now.day - 1, 12), ml: 100);
      await insertFeed(tester, type: 'bottle_formula', at: todayAt(0.2), ml: 100);
      await insertFeed(tester, type: 'bottle_formula', at: todayAt(0.4), ml: 60);
      await env.pumpApp(tester);
      expect(find.textContaining(en.bottleTotal(160)), findsOneWidget);
      expect(find.textContaining(en.lastFeed('').trim()), findsOneWidget);
      expect(timelineTexts(tester), hasLength(2));
    });

    flowTest('the timeline lists every kind of entry, newest first', (tester) async {
      await insertFeed(tester, type: 'bottle_formula', at: todayAt(0.2), ml: 100);
      await env.exec(
        tester,
        'INSERT INTO diapers (id, family_id, baby_id, occurred_at, is_wet, is_dirty) VALUES (uuid(), ?, ?, ?, 0, 1)',
        [env.familyId, env.babyId, utcTimestamp(todayAt(0.4))],
      );
      await env.exec(
        tester,
        "INSERT INTO sleeps (id, family_id, baby_id, kind, started_at, ended_at) VALUES (uuid(), ?, ?, 'nap', ?, ?)",
        [env.familyId, env.babyId, utcTimestamp(todayAt(0.6)), utcTimestamp(todayAt(0.7))],
      );
      await env.pumpApp(tester);
      final rows = timelineTexts(tester);
      expect(rows, hasLength(3));
      expect(rows[0], startsWith(en.sleepNap));
      expect(rows[1], diaperEntryText(en, Diaper(id: 'x', occurredAt: DateTime.now(), isWet: false, isDirty: true)));
      expect(rows[2], contains('100 ml'));
    });

    flowTest("tapping a card opens that report tab", (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.text(en.diapers));
      expect(find.byType(ReportsScreen), findsOneWidget);
      expect(find.text(en.chartDiapersPerDay), findsOneWidget);
      expectNoErrors(tester);
    });

    flowTest('a card\'s Past days opens the journal on yesterday with that kind chosen', (tester) async {
      await env.pumpApp(tester);
      // The Sleep card's Past days (the second card).
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.pastDays).at(1));
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text(en.yesterday), findsOneWidget);
      final chip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, en.sleep));
      expect(chip.selected, isTrue);
    });

    flowTest('the journal button opens the whole journal (All)', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.byTooltip(en.journalTitle));
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, en.categoryAll)).selected, isTrue);
    });
  });

  group('in Urdu', () {
    final ur = lookupAppLocalizations(const Locale('ur'));

    flowTest('a formula feed and a diaper are logged from the bar (right to left)', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await env.pumpApp(tester);
      expect(find.text(ur.tabToday), findsWidgets);

      await tapAndSettle(tester, barButton(ur.logFeed));
      await tapAndSettle(tester, inSheet(find.text(ur.feedTypeFormula)));
      await enterField(tester, ur.amountMl, '110');
      await tapAndSettle(tester, inSheet(find.widgetWithText(FilledButton, ur.saveButton)));
      await tapAndSettle(tester, barButton(ur.logDiaper));
      await tapAndSettle(tester, inSheet(find.text(ur.diaperWet)));
      expectNoErrors(tester);

      expect((await env.rows(tester, 'SELECT amount_ml FROM feeds')).single['amount_ml'], 110);
      expect(await env.rows(tester, 'SELECT id FROM diapers'), hasLength(1));
      expect(find.text(ur.diaperCounts(1, 0)), findsOneWidget);
    });
  });
}

// Journal and Reports on real rows in the database: the journal starts at
// yesterday, the arrows move between days, the chips filter by kind, and
// entries from every table (pumping, medicine doses, symptoms, growth,
// vaccines, foods, milestones, doctor's visits) appear under All. Reports
// show averages that match the logged days, for 7 and 30 days, on the
// Feeds, Sleep and Diapers tabs.

import 'dart:convert';
import 'dart:io';

import 'package:baby_app/core/baby_age.dart';
import 'package:baby_app/core/dates.dart';
import 'package:baby_app/data/content.dart';
import 'package:baby_app/features/health/doctor_summary.dart';
import 'package:baby_app/features/home/log_sheets.dart' show sideName;
import 'package:baby_app/data/models.dart' show BreastSide;
import 'package:baby_app/features/journal/journal_screen.dart';
import 'package:baby_app/features/reports/reports_screen.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));

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

/// A local time [daysAgo] days before today at [hour]:[minute].
DateTime dayAt(int daysAgo, int hour, [int minute = 0]) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - daysAgo, hour, minute);
}

/// Scrolls the journal day until [finder] is built, then checks it's there.
Future<void> expectInJournal(WidgetTester tester, Finder finder) async {
  final list = find.descendant(of: find.byType(JournalDayView), matching: find.byType(Scrollable)).first;
  await tester.scrollUntilVisible(finder.first, 150, scrollable: list);
  expect(finder, findsWidgets);
}

/// Yesterday's formula feed in the list (the totals chip also says "120 ml").
final formula120 = find.textContaining('${en.feedTypeFormula} · 120 ml');

void main() {
  setUpFlowTests();

  late FlowEnv env;
  setUp(() async => env = await FlowEnv.open());
  tearDown(() => env.close());

  /// Many inserts at once (real I/O), then lets the app see them.
  Future<void> seed(WidgetTester tester, List<(String, List<Object?>)> statements) async {
    await tester.runAsync(() => env.db.writeTransaction((tx) async {
          for (final (sql, params) in statements) {
            await tx.execute(sql, params);
          }
        }));
    await settle(tester);
  }

  (String, List<Object?>) feed(DateTime at, {String type = 'bottle_formula', int? ml = 100, int? left}) => (
        'INSERT INTO feeds (id, family_id, baby_id, type, started_at, ended_at, amount_ml, left_seconds, side) '
            'VALUES (uuid(), ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          env.familyId,
          env.babyId,
          type,
          utcTimestamp(at),
          left == null ? null : utcTimestamp(at.add(Duration(seconds: left))),
          type == 'breast' ? null : ml,
          left,
          left == null ? null : 'left',
        ],
      );
  (String, List<Object?>) diaper(DateTime at, {bool wet = true, bool dirty = false}) => (
        'INSERT INTO diapers (id, family_id, baby_id, occurred_at, is_wet, is_dirty) VALUES (uuid(), ?, ?, ?, ?, ?)',
        [env.familyId, env.babyId, utcTimestamp(at), wet ? 1 : 0, dirty ? 1 : 0],
      );
  (String, List<Object?>) sleep(DateTime from, DateTime to, {String kind = 'nap'}) => (
        'INSERT INTO sleeps (id, family_id, baby_id, kind, started_at, ended_at) VALUES (uuid(), ?, ?, ?, ?, ?)',
        [env.familyId, env.babyId, kind, utcTimestamp(from), utcTimestamp(to)],
      );

  group('journal', () {
    final foods = FoodGuide.fromJson(jsonDecode(File('assets/foods.json').readAsStringSync()) as Map<String, dynamic>);
    final milestones =
        MilestoneGuide.fromJson(jsonDecode(File('assets/milestones.json').readAsStringSync()) as Map<String, dynamic>);
    final egg = foods.food('egg')!;
    final milestone = milestones.ages.first.milestones.first;

    /// Yesterday: one of everything. Two days ago: one breastfeed.
    Future<void> seedDays(WidgetTester tester) => seed(tester, [
          feed(dayAt(1, 9), ml: 120),
          diaper(dayAt(1, 10)),
          sleep(dayAt(1, 13), dayAt(1, 14)),
          (
            "INSERT INTO pumping_sessions (id, family_id, baby_id, side, started_at, amount_ml) VALUES (uuid(), ?, ?, 'both', ?, 90)",
            [env.familyId, env.babyId, utcTimestamp(dayAt(1, 8))],
          ),
          (
            "INSERT INTO medications (id, family_id, baby_id, name, dose_times, as_needed, start_date) "
                "VALUES ('med', ?, ?, 'Paracetamol syrup', '[]', 1, ?)",
            [env.familyId, env.babyId, dateOnly(dayAt(5, 0))],
          ),
          (
            "INSERT INTO medication_doses (id, family_id, baby_id, medication_id, given_at, skipped) VALUES (uuid(), ?, ?, 'med', ?, 0)",
            [env.familyId, env.babyId, utcTimestamp(dayAt(1, 11))],
          ),
          (
            "INSERT INTO symptom_logs (id, family_id, baby_id, symptom, occurred_at, temperature_c) VALUES (uuid(), ?, ?, 'fever', ?, 38.1)",
            [env.familyId, env.babyId, utcTimestamp(dayAt(1, 12))],
          ),
          (
            'INSERT INTO growth_measurements (id, family_id, baby_id, measured_on, weight_g) VALUES (uuid(), ?, ?, ?, 7100)',
            [env.familyId, env.babyId, dateOnly(dayAt(1, 0))],
          ),
          (
            "INSERT INTO vaccinations (id, family_id, baby_id, vaccine_code, given_on) VALUES (uuid(), ?, ?, 'BCG', ?)",
            [env.familyId, env.babyId, dateOnly(dayAt(1, 0))],
          ),
          (
            "INSERT INTO food_tries (id, family_id, baby_id, food_id, tried_on, opinion, reaction) VALUES (uuid(), ?, ?, 'egg', ?, 'liked', 'none')",
            [env.familyId, env.babyId, dateOnly(dayAt(1, 0))],
          ),
          (
            'INSERT INTO milestone_checks (id, family_id, baby_id, milestone_id, achieved_on) VALUES (uuid(), ?, ?, ?, ?)',
            [env.familyId, env.babyId, milestone.id, dateOnly(dayAt(1, 0))],
          ),
          (
            "INSERT INTO doctor_visits (id, family_id, baby_id, visited_at, doctor) VALUES (uuid(), ?, ?, ?, 'Dr Amina')",
            [env.familyId, env.babyId, utcTimestamp(dayAt(1, 15))],
          ),
          feed(dayAt(2, 10), type: 'breast', left: 600),
        ]);

    Future<void> openJournal(WidgetTester tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.byTooltip(en.journalTitle));
      expect(find.byType(JournalScreen), findsOneWidget);
    }

    flowTest('All shows yesterday\'s entries from every table', (tester) async {
      await seedDays(tester);
      await openJournal(tester);
      expect(find.text(en.yesterday), findsOneWidget);
      expect(find.text(en.onThisDay), findsOneWidget);
      for (final text in [
        '120 ml',
        en.diaperWet,
        '${en.pumpingEntry} · ${sideName(en, BreastSide.both)} · 90 ml',
        'Paracetamol syrup · ${en.doseGiven}',
        symptomName(en, 'fever'),
        '${en.metricWeight} 7.10 kg',
        'BCG',
        egg.name.english,
        milestone.text.english,
        'Dr Amina',
      ]) {
        await expectInJournal(tester, find.textContaining(text));
      }
      expectNoErrors(tester);
    });

    flowTest('the chips show one kind at a time, and All brings everything back', (tester) async {
      await seedDays(tester);
      await openJournal(tester);
      Future<void> chip(String label) => tapAndSettle(tester, find.widgetWithText(ChoiceChip, label));

      await chip(en.feeds);
      expect(formula120, findsOneWidget);
      expect(find.textContaining(en.pumpingEntry), findsNothing);
      expect(find.text(en.onThisDay), findsNothing, reason: 'dated entries are under All only');
      expect(find.textContaining('${en.logDiaper} · '), findsNothing);

      await chip(en.diapers);
      expect(find.textContaining('${en.logDiaper} · '), findsOneWidget);
      expect(formula120, findsNothing);

      await chip(en.sleep);
      expect(find.textContaining('${en.sleepNap} · '), findsOneWidget);
      expect(find.textContaining('${en.logDiaper} · '), findsNothing);

      await chip(en.categoryAll);
      expect(find.text(en.onThisDay), findsOneWidget);
      expectNoErrors(tester);
    });

    flowTest('Day before goes back a day, Next day returns; the chip stays', (tester) async {
      await seedDays(tester);
      await openJournal(tester);
      final twoDaysAgo = dayAt(2, 0);
      // Yesterday has no newer day in the journal (today is on Today).
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right)).onPressed, isNull);

      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.feeds));
      await tapAndSettle(tester, find.byTooltip(en.olderDay));
      final dates = MaterialLocalizations.of(tester.element(find.byType(JournalScreen)));
      expect(find.text(dates.formatMediumDate(twoDaysAgo)), findsOneWidget);
      expect(find.textContaining(formatDuration(en, const Duration(minutes: 10))), findsWidgets);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, en.feeds)).selected, isTrue);

      await tapAndSettle(tester, find.byTooltip(en.newerDay));
      expect(find.text(en.yesterday), findsOneWidget);
      expect(formula120, findsOneWidget);
    });

    flowTest('a day with nothing logged says so', (tester) async {
      await openJournal(tester);
      expect(find.text(en.nothingOnDay), findsOneWidget);
    });

    flowTest('deleted entries are not in the journal', (tester) async {
      await seedDays(tester);
      await env.exec(tester, 'UPDATE feeds SET deleted_at = ? WHERE amount_ml = 120', [utcTimestamp(DateTime.now())]);
      await openJournal(tester);
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.feeds));
      expect(formula120, findsNothing);
    });

    flowTest('tapping a journal entry opens it for editing', (tester) async {
      await seedDays(tester);
      await openJournal(tester);
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.feeds));
      await tapAndSettle(tester, formula120);
      expect(find.text(en.editFeed), findsOneWidget);
      await enterField(tester, en.amountMl, '130');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expect(
        (await env.rows(tester, "SELECT amount_ml FROM feeds WHERE type = 'bottle_formula'")).single['amount_ml'],
        130,
      );
      // The journal refreshes from the database's change notification, which
      // can land after the screen has looked settled for a few rounds.
      await settle(tester, rounds: 20);
      expect(find.textContaining('${en.feedTypeFormula} · 130 ml'), findsOneWidget);
    });
  });

  group('reports', () {
    /// Yesterday: 6 bottles of 100 ml, 5 wet + 2 dirty diapers, 10h 30m of
    /// sleep. Three days ago: 7 bottles, 6 wet + 1 dirty, 10h of sleep.
    /// Twenty days ago (30-day view only): 9 bottles.
    Future<void> seedReports(WidgetTester tester) => seed(tester, [
          for (var i = 0; i < 6; i++) feed(dayAt(1, 7 + i * 2)),
          for (var i = 0; i < 7; i++) feed(dayAt(3, 7 + i * 2)),
          for (var i = 0; i < 9; i++) feed(dayAt(20, 7 + i)),
          for (var i = 0; i < 5; i++) diaper(dayAt(1, 8 + i)),
          for (var i = 0; i < 2; i++) diaper(dayAt(1, 14 + i), wet: false, dirty: true),
          for (var i = 0; i < 6; i++) diaper(dayAt(3, 8 + i)),
          diaper(dayAt(3, 16), wet: false, dirty: true),
          sleep(dayAt(1, 1), dayAt(1, 8), kind: 'night'),
          sleep(dayAt(1, 10), dayAt(1, 12)),
          sleep(dayAt(1, 14), dayAt(1, 15, 30)),
          sleep(dayAt(3, 1), dayAt(3, 9), kind: 'night'),
          sleep(dayAt(3, 13), dayAt(3, 15)),
        ]);

    Future<void> openReports(WidgetTester tester) async {
      await env.pumpApp(tester);
      // The Feeds card on Today opens Reports on its tab.
      await tapAndSettle(tester, find.text(en.feeds));
      expect(find.byType(ReportsScreen), findsOneWidget);
    }

    Future<void> openTab(WidgetTester tester, String tab) =>
        tapAndSettle(tester, find.descendant(of: find.byType(TabBar), matching: find.text(tab)));

    flowTest('Feeds: averages over the logged days, then over 30 days', (tester) async {
      await seedReports(tester);
      await openReports(tester);
      expect(find.text(en.feedsPerDay), findsOneWidget);
      expect(find.text('6.5'), findsOneWidget, reason: '(6 + 7) / 2 days');
      expect(find.text(en.bottlePerDay), findsOneWidget);
      expect(find.text('650 ml'), findsOneWidget);
      expect(find.text('100 ml'), findsOneWidget, reason: 'per bottle');

      await tapAndSettle(tester, find.text(en.periodDays(30)));
      expect(find.text('7.3'), findsOneWidget, reason: '(6 + 7 + 9) / 3 days');
      expect(find.text('6.5'), findsNothing);
      expectNoErrors(tester);
    });

    flowTest('Sleep: sleep a day and the longest sleep', (tester) async {
      await seedReports(tester);
      await openReports(tester);
      await openTab(tester, en.sleep);
      expect(find.text(en.sleepPerDay), findsOneWidget);
      expect(find.text(formatDuration(en, const Duration(hours: 10, minutes: 15))), findsOneWidget);
      expect(find.text(en.longestSleep), findsOneWidget);
      expect(find.text(formatDuration(en, const Duration(hours: 8))), findsOneWidget);
      expectNoErrors(tester);
    });

    flowTest('Diapers: wet and dirty a day', (tester) async {
      await seedReports(tester);
      await openReports(tester);
      await openTab(tester, en.diapers);
      expect(find.text(en.wetPerDay), findsOneWidget);
      expect(find.text('5.5'), findsOneWidget);
      expect(find.text(en.dirtyPerDay), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget);
    });

    flowTest('with nothing logged, no averages are shown', (tester) async {
      await openReports(tester);
      expect(find.text(en.feedsPerDay), findsNothing);
      expectNoErrors(tester);
    });

    flowTest('today\'s entries don\'t change the averages (only full days count)', (tester) async {
      await seedReports(tester);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await seed(tester, [for (var i = 0; i < 3; i++) feed(today.add(Duration(seconds: 1 + i)))]);
      await openReports(tester);
      expect(find.text('6.5'), findsOneWidget);
    });

    flowTest('in Urdu, the reports build with real data on every tab', (tester) async {
      final ur = lookupAppLocalizations(const Locale('ur'));
      await seedReports(tester);
      await tester.runAsync(() => env.setting('locale', 'ur'));
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.text(ur.feeds));
      expect(find.text(ur.feedsPerDay), findsOneWidget);
      for (final tab in [ur.sleep, ur.diapers]) {
        await openTab(tester, tab);
        expectNoErrors(tester);
      }
      expect(find.text(ur.wetPerDay), findsOneWidget);
    });
  });
}

// Breastfeeding timer flows on the real app and database: starting from the
// feed form, the "Feeding now" card on Today, switching sides, pausing and
// resuming, finishing (times per side stored) and discarding, and the form
// refusing a second timer. The sleep timer card is in today_flow_test.dart.

import 'package:baby_app/core/dates.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/features/home/live_timers.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));

Finder inSheet(Finder f) => find.descendant(of: find.byType(BottomSheet), matching: f);
Finder onCard(Finder f) => find.descendant(of: find.byType(FeedTimerCard), matching: f);

DateTime parseUtc(Object? v) => DateTime.parse(v! as String).toLocal();

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

  /// A timer that has been running on [side] for [running], with [left] /
  /// [right] seconds already banked.
  Future<void> runningTimer(
    WidgetTester tester, {
    String side = 'left',
    Duration running = const Duration(minutes: 3),
    int left = 0,
    int right = 0,
    bool paused = false,
  }) {
    final now = DateTime.now();
    final started = now.subtract(running).subtract(Duration(seconds: left + right));
    return env.exec(
      tester,
      "INSERT INTO feeds (id, family_id, baby_id, type, started_at, left_seconds, right_seconds, timer_side, timer_started_at) "
      "VALUES ('timer', ?, ?, 'breast', ?, ?, ?, ?, ?)",
      [
        env.familyId,
        env.babyId,
        utcTimestamp(started),
        left,
        right,
        side,
        paused ? null : utcTimestamp(now.subtract(running)),
      ],
    );
  }

  Future<Map<String, Object?>> timerRow(WidgetTester tester) async =>
      (await env.rows(tester, "SELECT * FROM feeds WHERE id = 'timer'")).single;

  flowTest('Feed > Left starts a timer: Today shows "Feeding now" and the timeline says so', (tester) async {
    await env.pumpApp(tester);
    await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logFeed).first);
    expect(inSheet(find.text(en.startFeedTimer)), findsOneWidget);
    await tapAndSettle(tester, inSheet(find.text(en.sideLeft)));
    expectNoErrors(tester);

    final row = (await env.rows(tester, 'SELECT type, timer_side, timer_started_at, ended_at FROM feeds')).single;
    expect(row['type'], 'breast');
    expect(row['timer_side'], 'left');
    expect(row['timer_started_at'], isNotNull);
    expect(row['ended_at'], isNull);
    expect(find.byType(BottomSheet), findsNothing);
    expect(onCard(find.text(en.feedingNowTitle)), findsOneWidget);
    expect(find.textContaining(en.feedingNow), findsWidgets);
  });

  flowTest('tapping the other side switches and banks the time on the first side', (tester) async {
    await runningTimer(tester, side: 'left', running: const Duration(minutes: 3));
    await env.pumpApp(tester);
    await tapAndSettle(tester, onCard(find.text(en.sideRight)));

    final row = await timerRow(tester);
    expect(row['timer_side'], 'right');
    expect(row['left_seconds'] as int, inInclusiveRange(178, 200));
    expect(parseUtc(row['timer_started_at']).difference(DateTime.now()).inSeconds.abs(), lessThan(30));
  });

  flowTest('tapping the running side pauses; tapping it again resumes', (tester) async {
    await runningTimer(tester, side: 'left', running: const Duration(minutes: 2));
    await env.pumpApp(tester);
    await tapAndSettle(tester, onCard(find.text(en.sideLeft)));
    var row = await timerRow(tester);
    expect(row['timer_started_at'], isNull, reason: 'paused');
    expect(row['timer_side'], 'left', reason: 'still this feed\'s timer');
    expect(row['left_seconds'] as int, inInclusiveRange(118, 140));
    expect(onCard(find.text(en.feedTimerPaused)), findsOneWidget);

    await tapAndSettle(tester, onCard(find.text(en.sideLeft)));
    row = await timerRow(tester);
    expect(row['timer_started_at'], isNotNull, reason: 'running again');
    expect(onCard(find.text(en.feedingNowTitle)), findsOneWidget);
  });

  flowTest('Finish saves the feed with the time on each side and ends the timer', (tester) async {
    await runningTimer(tester, side: 'right', running: const Duration(minutes: 4), left: 300);
    await env.pumpApp(tester);
    await tapAndSettle(tester, onCard(find.text(en.finishFeed)));
    expectNoErrors(tester);

    final row = await timerRow(tester);
    expect(row['timer_side'], isNull);
    expect(row['timer_started_at'], isNull);
    expect(row['ended_at'], isNotNull);
    expect(row['left_seconds'], 300);
    expect(row['right_seconds'] as int, inInclusiveRange(238, 260));
    expect(row['side'], 'both');
    expect(find.byType(FeedTimerCard), findsNothing);
    // The timeline shows both sides.
    expect(find.textContaining('${en.sideLeft} '), findsWidgets);
  });

  flowTest('Discard asks, then deletes the timer feed', (tester) async {
    await runningTimer(tester);
    await env.pumpApp(tester);
    await tapAndSettle(tester, onCard(find.text(en.discardButton)));
    expect(find.text(en.discardFeedConfirm), findsOneWidget);
    await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.discardButton)));

    expect((await timerRow(tester))['deleted_at'], isNotNull);
    expect(find.byType(FeedTimerCard), findsNothing);
    expect(find.text(en.nothingLoggedToday), findsOneWidget);
  });

  flowTest('cancelling Discard keeps the timer running', (tester) async {
    await runningTimer(tester);
    await env.pumpApp(tester);
    await tapAndSettle(tester, onCard(find.text(en.discardButton)));
    await tapAndSettle(tester, find.text(en.cancelButton));
    expect((await timerRow(tester))['deleted_at'], isNull);
    expect(find.byType(FeedTimerCard), findsOneWidget);
  });

  flowTest('with a timer going, the feed form offers no second timer', (tester) async {
    await runningTimer(tester);
    await env.pumpApp(tester);
    await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logFeed).first);
    expect(inSheet(find.text(en.feedTimerAlreadyRunning)), findsOneWidget);
    expect(inSheet(find.text(en.startFeedTimer)), findsNothing);
  });

  flowTest('a paused timer survives closing and reopening the app', (tester) async {
    await runningTimer(tester, left: 200, paused: true);
    await env.pumpApp(tester);
    expect(onCard(find.text(en.feedTimerPaused)), findsOneWidget);
    // 200 s banked on the left, shown as a clock.
    expect(onCard(find.text(clockText(const Duration(seconds: 200)))), findsWidgets);
  });

  flowTest('in Urdu: switch sides and finish', (tester) async {
    final ur = lookupAppLocalizations(const Locale('ur'));
    await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
    await runningTimer(tester, side: 'left', running: const Duration(minutes: 2));
    await env.pumpApp(tester);
    expect(onCard(find.text(ur.feedingNowTitle)), findsOneWidget);
    await tapAndSettle(tester, onCard(find.text(ur.sideRight)));
    await tapAndSettle(tester, onCard(find.text(ur.finishFeed)));
    expectNoErrors(tester);
    final row = await timerRow(tester);
    expect(row['ended_at'], isNotNull);
    expect(row['left_seconds'] as int, inInclusiveRange(118, 140));
  });
}

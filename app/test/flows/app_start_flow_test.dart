// The app from start: signed out > sign-in screen; signed in with no baby >
// add-baby form; with a baby > Today with the four tabs. Logging a feed from
// the bottom bar saves it, queues it for upload and shows it on Today.

import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  setUpFlowTests();

  group('with a baby', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('opens on Today with four tabs and the Feed / Diaper / Sleep bar', (tester) async {
      await env.pumpApp(tester);
      expectNoErrors(tester);
      expect(find.text('Aisha'), findsWidgets);
      for (final tab in ['Today', 'Feeding', 'Growth', 'Health']) {
        expect(find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)), findsOneWidget, reason: tab);
      }
      for (final button in ['Feed', 'Diaper', 'Sleep']) {
        expect(find.widgetWithText(FilledButton, button), findsOneWidget, reason: button);
      }
    });

    flowWidgets('Feed > Save logs a feed, shows it on Today and queues the upload', (tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Feed'));
      await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Save'));
      expectNoErrors(tester);

      final feeds = await env.rows(tester, 'SELECT baby_id, type FROM feeds');
      expect(feeds, [
        {'baby_id': env.babyId, 'type': 'breast'},
      ]);
      expect((await env.pendingUploads(tester)).where((c) => c.table == 'feeds'), hasLength(1));
      // Today's Feeds card counts it.
      expect(find.text('1'), findsWidgets);
    });

    flowWidgets('every tab opens without errors', (tester) async {
      await env.pumpApp(tester);
      for (final tab in ['Feeding', 'Growth', 'Health', 'Today']) {
        await tapAndSettle(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)));
        expectNoErrors(tester);
      }
    });
  });

  group('signed in, no baby yet', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open(baby: false));
    tearDown(() => env.close());

    flowWidgets('shows the add-baby form', (tester) async {
      await env.pumpApp(tester);
      expectNoErrors(tester);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.textContaining('Country'), findsWidgets);
    });
  });

  group('signed out', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open(signedIn: false, baby: false));
    tearDown(() => env.close());

    flowWidgets('shows the sign-in screen', (tester) async {
      await env.pumpApp(tester);
      expectNoErrors(tester);
      expect(find.byType(NavigationBar), findsNothing);
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.signInTitle), findsOneWidget);
      expect(find.widgetWithText(FilledButton, l10n.signInButton), findsOneWidget);
    });
  });
}

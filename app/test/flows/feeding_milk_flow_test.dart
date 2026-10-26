// Feeding tab, breast milk: which inner tab opens first, logging / editing /
// deleting pumping, adding stored milk, and the stored-milk bag menu (use
// for a feed, freeze, thaw, move, throw away), plus use-by warnings. Runs
// the real app on a real database and checks both the stored rows and the
// screen.

import 'package:baby_app/core/dates.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// Opens the app on the Feeding tab, then its Milk tab.
Future<void> openMilk(WidgetTester tester, FlowEnv env, {AppLocalizations? l10n}) async {
  final t = l10n ?? en;
  await env.pumpApp(tester);
  await tapAndSettle(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text(t.tabFeeding)));
  await tapAndSettle(tester, find.descendant(of: find.byType(TabBar), matching: find.text(t.tabMilk)));
}

/// The fridge / freezer total card showing [ml].
Finder totalCard(String location, int ml) =>
    find.descendant(of: find.widgetWithText(Card, location), matching: find.text(en.storedMilkTotal(ml)));

/// Picks [item] in the menu of the first stored-milk bag on screen.
Future<void> bagMenu(WidgetTester tester, String item) async {
  await tapAndSettle(tester, find.byType(PopupMenuButton<Object>));
  await tapAndSettle(tester, find.text(item));
  // "Use for a feed" is two writes (the feed, then the bag); settle can see
  // a quiet screen between them, so wait once more.
  await settle(tester);
}

/// Active (not used or thrown away) bags, oldest first.
Future<List<Map<String, Object?>>> activeBags(WidgetTester tester, FlowEnv env) => env.rows(
      tester,
      'SELECT amount_ml, location, frozen_at, thawed_at, pumping_session_id FROM milk_stash '
      'WHERE finished_at IS NULL AND deleted_at IS NULL ORDER BY julianday(pumped_at)',
    );

/// Fills in the Add stored milk form and saves.
Future<void> addStoredMilk(WidgetTester tester, int ml, String location) async {
  await tapAndSettle(tester, find.widgetWithText(FilledButton, en.addStoredMilk));
  await enterField(tester, en.amountMl, '$ml');
  await tapAndSettle(tester, find.widgetWithText(ChoiceChip, location));
  await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
}

void main() {
  setUpFlowTests();

  group('which tab opens first', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open(baby: false));
    tearDown(() => env.close());

    flowWidgets('a baby under 5 months opens on Milk, and Guides says solids come later', (tester) async {
      await tester.runAsync(() => env.seedBaby(name: 'Zara', birthDate: DateTime.now().subtract(const Duration(days: 70))));
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text(en.tabFeeding)));
      expectNoErrors(tester);
      expect(find.widgetWithText(FilledButton, en.logPumping), findsOneWidget);
      expect(find.text(en.solidsFoodsProgress(0, 36)), findsNothing);

      await tapAndSettle(tester, find.descendant(of: find.byType(TabBar), matching: find.text(en.solidsTabGuides)));
      expect(find.text(en.solidsTooYoung), findsOneWidget);
    });

    flowWidgets('an older baby opens on Foods', (tester) async {
      await tester.runAsync(() => env.seedBaby());
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text(en.tabFeeding)));
      expect(find.textContaining(en.solidsFoodsProgress(0, 36)), findsOneWidget);
      expect(find.widgetWithText(FilledButton, en.logPumping), findsNothing);
    });
  });

  group('pumping', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('Log pumping saves side, amount and duration, stores the milk in the fridge and shows today\'s total',
        (tester) async {
      await openMilk(tester, env);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logPumping));
      await tapAndSettle(tester, find.text(en.sideLeft));
      await enterField(tester, en.amountMl, '90');
      await enterField(tester, en.feedMinutes, '15');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expectNoErrors(tester);

      final sessions = await env.rows(tester, 'SELECT baby_id, side, amount_ml, started_at, ended_at FROM pumping_sessions');
      expect(sessions, hasLength(1));
      expect(sessions.single['baby_id'], env.babyId);
      expect(sessions.single['side'], 'left');
      expect(sessions.single['amount_ml'], 90);
      final started = DateTime.parse(sessions.single['started_at']! as String);
      final ended = DateTime.parse(sessions.single['ended_at']! as String);
      expect(ended.difference(started), const Duration(minutes: 15));

      // Fridge is the default place for the milk; the bag points at the session.
      final bags = await activeBags(tester, env);
      expect(bags, hasLength(1));
      expect(bags.single['location'], 'fridge');
      expect(bags.single['amount_ml'], 90);
      expect(bags.single['pumping_session_id'], isNotNull);

      expect(find.text(en.pumpedToday(90, 1)), findsOneWidget);
      expect(totalCard(en.locationFridge, 90), findsOneWidget);
    });

    flowWidgets('"Fed right away" logs the session without storing milk', (tester) async {
      await openMilk(tester, env);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logPumping));
      await enterField(tester, en.amountMl, '60');
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.notStored));
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));

      expect(await env.rows(tester, 'SELECT amount_ml FROM pumping_sessions'), [
        {'amount_ml': 60},
      ]);
      expect(await activeBags(tester, env), isEmpty);
      expect(find.text(en.noStoredMilk), findsOneWidget);
      expect(find.text(en.pumpedToday(60, 1)), findsOneWidget);
    });

    flowWidgets('storing milk needs an amount', (tester) async {
      await openMilk(tester, env);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logPumping));
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expect(find.text(en.invalidAmount), findsOneWidget);
      expect(await env.rows(tester, 'SELECT id FROM pumping_sessions'), isEmpty);
    });

    flowWidgets('a session can be edited and deleted', (tester) async {
      await openMilk(tester, env);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logPumping));
      await enterField(tester, en.amountMl, '80');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));

      // The session is listed below the stash; tap it to edit.
      await tapAndSettle(tester, find.widgetWithText(ListTile, '80 ml'));
      expect(find.text(en.editPumping), findsOneWidget);
      await tapAndSettle(tester, find.text(en.sideRight));
      await enterField(tester, en.amountMl, '100');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expect(await env.rows(tester, 'SELECT side, amount_ml FROM pumping_sessions WHERE deleted_at IS NULL'), [
        {'side': 'right', 'amount_ml': 100},
      ]);
      expect(find.text(en.pumpedToday(100, 1)), findsOneWidget);

      await tapAndSettle(tester, find.widgetWithText(ListTile, '100 ml'));
      await tapAndSettle(tester, find.text(en.deleteButton));
      expect(find.text(en.deleteConfirmTitle), findsOneWidget);
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));
      expectNoErrors(tester);
      expect(await env.rows(tester, 'SELECT id FROM pumping_sessions WHERE deleted_at IS NULL'), isEmpty);
      expect(await env.rows(tester, 'SELECT id FROM pumping_sessions WHERE deleted_at IS NOT NULL'), hasLength(1));
      expect(find.text(en.pumpedToday(0, 0)), findsOneWidget);
    });

    flowWidgets('Urdu: logging pumping works right-to-left', (tester) async {
      final ur = lookupAppLocalizations(const Locale('ur'));
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await openMilk(tester, env, l10n: ur);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, ur.logPumping));
      await enterField(tester, ur.amountMl, '۷۰'); // Urdu digits
      await tapAndSettle(tester, find.widgetWithText(FilledButton, ur.saveButton));
      expectNoErrors(tester);
      expect(await env.rows(tester, 'SELECT amount_ml FROM pumping_sessions'), [
        {'amount_ml': 70},
      ]);
      expect(Directionality.of(tester.element(find.widgetWithText(FilledButton, ur.logPumping))), TextDirection.rtl);
    });
  });

  group('stored milk', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('Add stored milk to the fridge and the freezer fills the two totals', (tester) async {
      await openMilk(tester, env);
      await addStoredMilk(tester, 120, en.locationFridge);
      await addStoredMilk(tester, 150, en.locationFreezer);
      expectNoErrors(tester);

      final bags = await activeBags(tester, env);
      expect(bags.map((b) => (b['amount_ml'], b['location'])), unorderedEquals([(120, 'fridge'), (150, 'freezer')]));
      // Milk going into the freezer gets a freezing time (its use-by counts from it).
      expect(bags.firstWhere((b) => b['location'] == 'freezer')['frozen_at'], isNotNull);
      expect(totalCard(en.locationFridge, 120), findsOneWidget);
      expect(totalCard(en.locationFreezer, 150), findsOneWidget);
      // Stored milk isn't a pumping session.
      expect(await env.rows(tester, 'SELECT id FROM pumping_sessions'), isEmpty);
    });

    flowWidgets('Use for a feed finishes the bag and logs a bottle of breast milk', (tester) async {
      await openMilk(tester, env);
      await addStoredMilk(tester, 120, en.locationFridge);
      await bagMenu(tester, en.useForFeed);
      expectNoErrors(tester);

      expect(await env.rows(tester, 'SELECT finished_reason FROM milk_stash'), [
        {'finished_reason': 'used'},
      ]);
      expect(await env.rows(tester, 'SELECT baby_id, type, amount_ml FROM feeds'), [
        {'baby_id': env.babyId, 'type': 'bottle_breast_milk', 'amount_ml': 120},
      ]);
      expect(find.text(en.noStoredMilk), findsOneWidget);
      expect(totalCard(en.locationFridge, 0), findsOneWidget);
    });

    flowWidgets('Throw away finishes the bag as discarded, without logging a feed', (tester) async {
      await openMilk(tester, env);
      await addStoredMilk(tester, 60, en.locationFridge);
      await bagMenu(tester, en.throwAway);

      expect(await env.rows(tester, 'SELECT finished_reason FROM milk_stash'), [
        {'finished_reason': 'discarded'},
      ]);
      expect(await env.rows(tester, 'SELECT id FROM feeds'), isEmpty);
      expect(find.text(en.noStoredMilk), findsOneWidget);
    });

    flowWidgets('fridge milk can be frozen, frozen milk thawed, and thawed milk never refrozen', (tester) async {
      await openMilk(tester, env);
      await addStoredMilk(tester, 100, en.locationFridge);

      await bagMenu(tester, en.moveToFreezer);
      var bag = (await activeBags(tester, env)).single;
      expect(bag['location'], 'freezer');
      expect(bag['frozen_at'], isNotNull);
      expect(totalCard(en.locationFreezer, 100), findsOneWidget);

      await bagMenu(tester, en.thawMilk);
      bag = (await activeBags(tester, env)).single;
      expect(bag['location'], 'thawed');
      expect(bag['thawed_at'], isNotNull);
      // Thawed milk counts towards the fridge and says not to refreeze.
      expect(totalCard(en.locationFridge, 100), findsOneWidget);
      expect(find.textContaining(en.noRefreeze), findsOneWidget);

      await tapAndSettle(tester, find.byType(PopupMenuButton<Object>));
      expect(find.text(en.moveToFreezer), findsNothing);
      expect(find.text(en.useForFeed), findsOneWidget);
      expect(find.text(en.throwAway), findsOneWidget);
    });

    flowWidgets('milk from a cooler or the room can move to the fridge', (tester) async {
      await openMilk(tester, env);
      await addStoredMilk(tester, 70, en.locationCooler);
      await bagMenu(tester, en.moveToFridge);
      expect((await activeBags(tester, env)).single['location'], 'fridge');

      await addStoredMilk(tester, 40, en.locationRoom);
      // Room milk sorts first (it lasts the shortest), so its menu is the first.
      await bagMenu(tester, en.moveToCooler);
      expect((await activeBags(tester, env)).map((b) => b['location']), unorderedEquals(['fridge', 'cooler']));
    });

    flowWidgets('expired milk is flagged, can only be thrown away, and the warning counts it', (tester) async {
      await tester.runAsync(
        () => env.db.execute(
          'INSERT INTO milk_stash (id, family_id, baby_id, pumped_at, amount_ml, location) VALUES (uuid(), ?, ?, ?, ?, ?)',
          [env.familyId, env.babyId, utcTimestamp(DateTime.now().subtract(const Duration(days: 5))), 90, 'fridge'],
        ),
      );
      await openMilk(tester, env);
      expectNoErrors(tester);
      expect(find.textContaining(en.milkExpired), findsOneWidget);
      expect(find.text(en.milkNeedsAttention(1)), findsOneWidget);

      await tapAndSettle(tester, find.byType(PopupMenuButton<Object>));
      expect(find.text(en.useForFeed), findsNothing);
      expect(find.text(en.moveToFreezer), findsNothing);
      await tapAndSettle(tester, find.text(en.throwAway));
      expect(find.text(en.milkNeedsAttention(1)), findsNothing);
      expect(find.text(en.noStoredMilk), findsOneWidget);
    });

    flowWidgets('fresh fridge milk shows its use-by time and no warning', (tester) async {
      await openMilk(tester, env);
      await addStoredMilk(tester, 50, en.locationFridge);
      expect(find.textContaining(en.useBy('').trim()), findsOneWidget);
      expect(find.textContaining(en.milkExpired), findsNothing);
      expect(find.text(en.milkNeedsAttention(1)), findsNothing);
    });

    flowWidgets('milk that expires within a day is flagged but can still be used', (tester) async {
      // Fridge milk lasts 4 days: pumped 3.5 days ago, 12 hours left.
      await tester.runAsync(
        () => env.db.execute(
          'INSERT INTO milk_stash (id, family_id, baby_id, pumped_at, amount_ml, location) VALUES (uuid(), ?, ?, ?, ?, ?)',
          [env.familyId, env.babyId, utcTimestamp(DateTime.now().subtract(const Duration(days: 3, hours: 12))), 80, 'fridge'],
        ),
      );
      await openMilk(tester, env);
      expect(find.text(en.milkNeedsAttention(1)), findsOneWidget);
      expect(find.textContaining(en.milkExpired), findsNothing);
      await tapAndSettle(tester, find.byType(PopupMenuButton<Object>));
      expect(find.text(en.useForFeed), findsOneWidget);
    });
  });
}

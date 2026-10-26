// Feeding tab, solids: logging a try of a food (opinion, reaction, notes),
// how that updates the progress, the allergen chips and the Tried / Not
// tried groups, the severe-reaction warning with the country's emergency
// number, editing and deleting a try, search and category filters, and
// logging a try from a recipe. Runs the real app on a real database.

import 'dart:convert';
import 'dart:io';

import 'package:baby_app/core/dates.dart';
import 'package:baby_app/core/emergency.dart';
import 'package:baby_app/data/content.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));
final guide = FoodGuide.fromJson(jsonDecode(File('assets/foods.json').readAsStringSync()) as Map<String, dynamic>);
int get foodCount => guide.foods.length;
int get allergenCount => guide.allergens.length;
String foodName(String id) => guide.food(id)!.name.english;

/// Opens the app on the Feeding tab (Foods, for a baby old enough).
Future<void> openFoods(WidgetTester tester, FlowEnv env, {AppLocalizations? l10n}) async {
  await env.pumpApp(tester);
  await tapAndSettle(
    tester,
    find.descendant(of: find.byType(NavigationBar), matching: find.text((l10n ?? en).tabFeeding)),
  );
}

/// Searches for [foodId] and opens its sheet.
Future<void> openFood(WidgetTester tester, String foodId) async {
  await tester.enterText(find.widgetWithText(TextField, en.searchFoods), foodName(foodId));
  await settle(tester);
  await tapAndSettle(tester, find.widgetWithText(ListTile, foodName(foodId)));
}

/// In the try form: picks an opinion / reaction, types notes, saves.
Future<void> fillTry(
  WidgetTester tester, {
  String? opinion,
  String? reaction,
  String? notes,
  AppLocalizations? l10n,
}) async {
  final t = l10n ?? en;
  if (opinion != null) await tapAndSettle(tester, find.text(opinion));
  if (reaction != null) await tapAndSettle(tester, find.text(reaction));
  if (notes != null) {
    await tester.enterText(find.widgetWithText(TextField, t.notesLabel), notes);
    await tester.pump();
  }
  await tapAndSettle(tester, find.widgetWithText(FilledButton, t.saveButton));
  // The try is saved after the sheet starts closing; let the lists catch up.
  await settle(tester);
}

/// Closes the sheet that shows [inside].
Future<void> closeSheet(WidgetTester tester, Finder inside) async {
  Navigator.of(tester.element(inside.first)).pop();
  await settle(tester);
}

Future<List<Map<String, Object?>>> tries(WidgetTester tester, FlowEnv env) => env.rows(
      tester,
      'SELECT baby_id, food_id, tried_on, opinion, reaction, notes FROM food_tries WHERE deleted_at IS NULL',
    );

/// The allergen chip for [allergen], found by its "name: status" label.
Finder allergenChip(String allergen, String status) => find.byTooltip('${guide.allergens[allergen]!.english}: $status');

void main() {
  setUpFlowTests();

  group('trying foods', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('Log a try saves the food, date, opinion and notes, and the food moves to Tried', (tester) async {
      await openFoods(tester, env);
      expect(find.text(en.solidsFoodsProgress(0, foodCount)), findsOneWidget);

      await openFood(tester, 'carrot');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logTry));
      await fillTry(tester, opinion: en.opinionLiked, notes: 'Loved it');
      expectNoErrors(tester);

      expect(await tries(tester, env), [
        {
          'baby_id': env.babyId,
          'food_id': 'carrot',
          'tried_on': dateOnly(DateTime.now()),
          'opinion': 'liked',
          'reaction': 'none',
          'notes': 'Loved it',
        },
      ]);
      // The food's sheet lists the try.
      expect(find.textContaining('Loved it'), findsOneWidget);

      await closeSheet(tester, find.widgetWithText(FilledButton, en.logTry));
      expect(find.text(en.solidsFoodsProgress(1, foodCount)), findsOneWidget);
      expect(find.text(en.foodsTried), findsOneWidget);
      expect(find.widgetWithText(ListTile, en.triedTimes(1)), findsOneWidget);
      // Carrot isn't an allergen.
      expect(find.text(en.solidsAllergensProgress(0, allergenCount)), findsOneWidget);
    });

    flowWidgets('a second try of the same food counts once in progress, twice on the food', (tester) async {
      await openFoods(tester, env);
      await openFood(tester, 'banana');
      for (var i = 0; i < 2; i++) {
        await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logTry));
        await fillTry(tester);
      }
      expect(await tries(tester, env), hasLength(2));
      await closeSheet(tester, find.widgetWithText(FilledButton, en.logTry));
      expect(find.text(en.solidsFoodsProgress(1, foodCount)), findsOneWidget);
      expect(find.widgetWithText(ListTile, en.triedTimes(2)), findsOneWidget);
    });

    flowWidgets('allergen chip goes from Not yet to Introduced, then Reaction after a mild reaction', (tester) async {
      await openFoods(tester, env);
      expect(allergenChip('egg', en.allergenNotYet), findsOneWidget);

      await openFood(tester, 'egg');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logTry));
      await fillTry(tester);
      await closeSheet(tester, find.widgetWithText(FilledButton, en.logTry));
      expect(allergenChip('egg', en.allergenIntroduced), findsOneWidget);
      expect(find.text(en.solidsAllergensProgress(1, allergenCount)), findsOneWidget);

      await openFood(tester, 'egg');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logTry));
      await fillTry(tester, reaction: en.reactionMild);
      // The food's sheet now warns before giving it again.
      expect(find.text(en.reactionWarning), findsOneWidget);
      await closeSheet(tester, find.widgetWithText(FilledButton, en.logTry));
      expect(allergenChip('egg', en.allergenReaction), findsOneWidget);
      expect((await tries(tester, env)).map((t) => t['reaction']), unorderedEquals(['none', 'mild']));
    });

    flowWidgets('choosing a severe reaction shows what to do, with Pakistan\'s emergency numbers', (tester) async {
      await openFoods(tester, env);
      await openFood(tester, 'peanut');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logTry));
      final warning = en.severeReactionNow(primaryEmergencyNumber('PK')!);
      expect(find.text(warning), findsNothing);
      await tapAndSettle(tester, find.text(en.reactionSevere));
      expect(find.text(warning), findsOneWidget);

      await fillTry(tester);
      expect((await tries(tester, env)).single['reaction'], 'severe');
      expect(find.text(en.reactionWarning), findsOneWidget);
    });

    flowWidgets('editing a try changes it, deleting it takes the food back to Not tried', (tester) async {
      await openFoods(tester, env);
      await openFood(tester, 'mango');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logTry));
      await fillTry(tester, opinion: en.opinionLiked);

      // Tap the try in the food's sheet to edit it.
      await tapAndSettle(tester, find.widgetWithText(ListTile, en.opinionLiked));
      expect(find.textContaining(en.editTry), findsOneWidget);
      await fillTry(tester, opinion: en.opinionDisliked, notes: 'Spat it out');
      expect(await tries(tester, env), [
        allOf(containsPair('opinion', 'disliked'), containsPair('notes', 'Spat it out')),
      ]);

      // Its line now reads "Disliked · Spat it out".
      await tapAndSettle(tester, find.ancestor(of: find.textContaining('Spat it out'), matching: find.byType(ListTile)));
      await tapAndSettle(tester, find.text(en.deleteButton));
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));
      expectNoErrors(tester);
      expect(await tries(tester, env), isEmpty);
      expect(await env.rows(tester, 'SELECT id FROM food_tries WHERE deleted_at IS NOT NULL'), hasLength(1));

      await closeSheet(tester, find.widgetWithText(FilledButton, en.logTry));
      expect(find.text(en.solidsFoodsProgress(0, foodCount)), findsOneWidget);
      expect(find.text(en.foodsTried), findsNothing);
    });

    flowWidgets('a try logged on another phone shows up on this one', (tester) async {
      await openFoods(tester, env);
      await env.exec(
        tester,
        "INSERT INTO food_tries (id, family_id, baby_id, food_id, tried_on, reaction) VALUES (uuid(), ?, ?, 'rice', ?, 'none')",
        [env.familyId, env.babyId, dateOnly(DateTime.now())],
      );
      expect(find.text(en.solidsFoodsProgress(1, foodCount)), findsOneWidget);
      expect(find.text(en.foodsTried), findsOneWidget);
    });

    flowWidgets('search finds a food by name and hides the rest', (tester) async {
      await openFoods(tester, env);
      await tester.enterText(find.widgetWithText(TextField, en.searchFoods), 'mang');
      await settle(tester);
      expect(find.widgetWithText(ListTile, foodName('mango')), findsOneWidget);
      expect(find.widgetWithText(ListTile, foodName('carrot')), findsNothing);
      expect(find.widgetWithText(ListTile, foodName('banana')), findsNothing);
    });

    flowWidgets('a category chip shows only that kind of food', (tester) async {
      await openFoods(tester, env);
      final list = find.byType(Scrollable).last;
      final vegetables = [for (final f in guide.foods) if (f.category == 'vegetable') f.name.english];
      final fruits = [for (final f in guide.foods) if (f.category == 'fruit') f.name.english];

      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.categoryFruit));
      await tester.scrollUntilVisible(find.widgetWithText(ListTile, fruits.last), 300, scrollable: list);
      for (final v in vegetables) {
        expect(find.widgetWithText(ListTile, v), findsNothing, reason: v);
      }
      for (final f in fruits) {
        await tester.scrollUntilVisible(find.widgetWithText(ListTile, f), -200, scrollable: list);
        expect(find.widgetWithText(ListTile, f), findsOneWidget, reason: f);
      }

      // Back to All: vegetables are listed again.
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.categoryAll));
      await tester.scrollUntilVisible(find.widgetWithText(ListTile, vegetables.first), 300, scrollable: list);
      expect(find.widgetWithText(ListTile, vegetables.first), findsOneWidget);
    });

    flowWidgets('Recipes: tapping a food under "Log a try" logs that food', (tester) async {
      await openFoods(tester, env);
      await tapAndSettle(tester, find.descendant(of: find.byType(TabBar), matching: find.text(en.solidsTabRecipes)));
      final recipe = guide.recipes.firstWhere((r) => r.foods.length > 1);
      await tapAndSettle(tester, find.text(recipe.name.english));
      final food = recipe.foods.last;
      await tapAndSettle(tester, find.widgetWithText(ActionChip, foodName(food)));
      expect(find.textContaining(foodName(food)), findsWidgets);
      await fillTry(tester, opinion: en.opinionNeutral);
      expectNoErrors(tester);
      expect(await tries(tester, env), [
        allOf(containsPair('food_id', food), containsPair('opinion', 'neutral')),
      ]);
    });

    flowWidgets('Urdu: logging a try works right-to-left', (tester) async {
      final ur = lookupAppLocalizations(const Locale('ur'));
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await openFoods(tester, env, l10n: ur);
      final carrot = guide.food('carrot')!.name.of(ur);
      await tester.enterText(find.widgetWithText(TextField, ur.searchFoods), carrot);
      await settle(tester);
      await tapAndSettle(tester, find.widgetWithText(ListTile, carrot));
      await tapAndSettle(tester, find.widgetWithText(FilledButton, ur.logTry));
      await fillTry(tester, opinion: ur.opinionLiked, reaction: ur.reactionSevere, l10n: ur);
      expectNoErrors(tester);
      expect(await tries(tester, env), [
        allOf(containsPair('food_id', 'carrot'), containsPair('opinion', 'liked'), containsPair('reaction', 'severe')),
      ]);
      expect(find.text(ur.reactionWarning), findsOneWidget);
    });
  });

  group('outside Pakistan', () {
    late FlowEnv env;
    setUp(() async {
      env = await FlowEnv.open(baby: false);
      await env.seedBaby(country: 'GB');
    });
    tearDown(() => env.close());

    flowWidgets('the severe-reaction warning uses the baby\'s country\'s number', (tester) async {
      await openFoods(tester, env);
      await openFood(tester, 'egg');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logTry));
      await tapAndSettle(tester, find.text(en.reactionSevere));
      final gb = primaryEmergencyNumber('GB')!;
      expect(gb, isNot(primaryEmergencyNumber('PK')));
      expect(find.text(en.severeReactionNow(gb)), findsOneWidget);
      expect(find.text(en.severeReactionNow(primaryEmergencyNumber('PK')!)), findsNothing);
    });
  });
}

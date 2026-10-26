// Babies and on-phone settings, through the real app and database:
// adding the first baby (validation, saved values, landing on Today, in
// English and Urdu), editing / adding / deleting babies in Settings,
// switching baby from Settings, the Today title and the other tabs' titles
// (remembered after a restart), language and appearance.

import 'package:baby_app/core/countries.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'baby_settings_flow_support.dart';
import 'harness.dart';

Finder _tab(String label) => find.descendant(of: find.byType(NavigationBar), matching: find.text(label));
Finder _inAppBar(Finder f) => find.descendant(of: find.byType(AppBar), matching: f);
Finder _inSheet(Finder f) => find.descendant(of: find.byType(BottomSheet), matching: f);

void main() {
  setUpFlowTests();
  fakePlugins();

  group('first baby', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open(baby: false));
    tearDown(() => env.close());

    flowWidgets('name, birth date and country are required', (tester) async {
      await pumpPalna(tester, env);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expectNoErrors(tester);
      expect(find.text(en.fieldRequired), findsNWidgets(3));
      expect(await babyRows(tester, env), isEmpty);
    });

    flowWidgets('birth measurements outside sane ranges are refused', (tester) async {
      await pumpPalna(tester, env);
      await enterField(tester, en.babyNameLabel, 'Zainab');
      await enterField(tester, en.birthWeightLabel, '9');
      await enterField(tester, en.birthLengthLabel, '5');
      await enterField(tester, en.birthHeadLabel, '80');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expect(find.text(en.invalidWeight), findsOneWidget);
      expect(find.text(en.invalidBirthLength), findsOneWidget);
      expect(find.text(en.invalidBirthHead), findsOneWidget);
      expect(await babyRows(tester, env), isEmpty);
    });

    flowWidgets('Save stores the baby in a new family, selects it and opens Today', (tester) async {
      final born = DateTime(DateTime.now().year, DateTime.now().month - 2, 15);
      await pumpPalna(tester, env);
      await enterField(tester, en.babyNameLabel, '  Zainab ');
      await pickBirthDate(tester, en.birthDateLabel, date: born);
      await pickCountry(tester, en.countryLabel, 'GB');
      await tapAndSettle(tester, find.text(en.sexFemale));
      await enterField(tester, en.birthWeightLabel, '3.25');
      await enterField(tester, en.birthLengthLabel, '50.5');
      await enterField(tester, en.birthHeadLabel, '34');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expectNoErrors(tester);

      final babies = await babyRows(tester, env);
      expect(babies, hasLength(1));
      expect(babies.single, {
        'id': isA<String>(),
        'family_id': isA<String>(),
        'name': 'Zainab',
        'birth_date': dateOnlyText(born),
        'sex': 'female',
        'birth_weight_g': 3250,
        'birth_length_mm': 505,
        'birth_head_mm': 340,
        'country_code': 'GB',
        'deleted_at': null,
      });
      final families = await query(tester, env, 'SELECT id FROM families');
      expect(families.map((f) => f['id']), [babies.single['family_id']]);
      expect(await settingValue(tester, env, SettingKeys.babyId), babies.single['id']);
      // Both rows wait to upload (the server makes the user the owner).
      expect(await pendingTables(tester, env), containsAll(['families', 'babies']));
      // The app moves on to Today with the baby's name.
      expect(_tab(en.tabToday), findsOneWidget);
      expect(_inAppBar(find.text('Zainab')), findsOneWidget);
    });

    flowWidgets('optional fields can stay empty', (tester) async {
      await pumpPalna(tester, env);
      await enterField(tester, en.babyNameLabel, 'Omar');
      await pickBirthDate(tester, en.birthDateLabel);
      await pickCountry(tester, en.countryLabel, 'PK');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      final baby = (await babyRows(tester, env)).single;
      expect(baby['sex'], isNull);
      expect(baby['birth_weight_g'], isNull);
      expect(baby['birth_length_mm'], isNull);
      expect(baby['birth_head_mm'], isNull);
      expect(baby['country_code'], 'PK');
      expect(_tab(en.tabToday), findsOneWidget);
    });

    flowWidgets('a country outside the main list can be found by search', (tester) async {
      await pumpPalna(tester, env);
      await enterField(tester, en.babyNameLabel, 'Yuki');
      await pickBirthDate(tester, en.birthDateLabel);
      await pickCountry(tester, en.countryLabel, 'JP');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expect((await babyRows(tester, env)).single['country_code'], 'JP');
    });

    flowWidgets('adding the first baby works in Urdu', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await pumpPalna(tester, env);
      expect(find.text(ur.addBabyTitle), findsOneWidget);
      expect(Directionality.of(tester.element(find.text(ur.addBabyTitle))), TextDirection.rtl);
      await enterField(tester, ur.babyNameLabel, 'زینب');
      await pickBirthDate(tester, ur.birthDateLabel);
      await pickCountry(tester, ur.countryLabel, 'PK', language: 'ur');
      await tapAndSettle(tester, find.text(ur.sexFemale));
      await tapAndSettle(tester, find.widgetWithText(FilledButton, ur.saveButton));
      expectNoErrors(tester);
      final baby = (await babyRows(tester, env)).single;
      expect(baby['name'], 'زینب');
      expect(baby['country_code'], 'PK');
      expect(_tab(ur.tabToday), findsOneWidget);
    });
  });

  group('Settings > babies', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('edit a baby: name, birth date, country and sex are saved', (tester) async {
      final born = DateTime(DateTime.now().year, DateTime.now().month - 3, 2);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.byIcon(Icons.edit_outlined));
      expect(find.text(en.editBabyTitle), findsOneWidget);
      await enterField(tester, en.babyNameLabel, 'Aisha Khan');
      await pickBirthDate(tester, en.birthDateLabel, date: born);
      await pickCountry(tester, en.countryLabel, 'AE');
      await tapAndSettle(tester, find.text(en.sexMale));
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expectNoErrors(tester);

      final baby = (await babyRows(tester, env)).single;
      expect(baby['name'], 'Aisha Khan');
      expect(baby['birth_date'], dateOnlyText(born));
      expect(baby['country_code'], 'AE');
      expect(baby['sex'], 'male');
      // Back on Settings, which lists the new name.
      expect(find.text(en.settingsTitle), findsOneWidget);
      expect(find.text('Aisha Khan'), findsOneWidget);
    });

    flowWidgets('editing keeps the birth measurements that were there', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.byIcon(Icons.edit_outlined));
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      final baby = (await babyRows(tester, env)).single;
      expect(baby['birth_weight_g'], 3200);
      expect(baby['country_code'], 'PK');
      expect(baby['name'], 'Aisha');
    });

    flowWidgets('delete the only baby (after confirming): hidden, and the add-baby form comes back', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.byIcon(Icons.edit_outlined));
      await scrollAndTap(tester, find.widgetWithText(TextButton, en.deleteButton));
      expect(find.text(en.deleteConfirmTitle), findsOneWidget);
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));
      expectNoErrors(tester);

      final baby = (await babyRows(tester, env)).single;
      expect(baby['deleted_at'], isNotNull, reason: 'soft delete: the history stays, hidden');
      expect(find.text('Aisha'), findsNothing);
      // Leave Settings: with no baby left, the app asks for one.
      await tester.pageBack();
      await settle(tester);
      expect(find.text(en.addBabyTitle), findsOneWidget);
    });

    flowWidgets('cancelling the delete keeps the baby', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.byIcon(Icons.edit_outlined));
      await scrollAndTap(tester, find.widgetWithText(TextButton, en.deleteButton));
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.cancelButton)));
      expect((await babyRows(tester, env)).single['deleted_at'], isNull);
    });

    flowWidgets('Add another baby: same family, becomes the chosen baby', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.text(en.addAnotherBaby));
      // Pushed from Settings: no "join a family" button here.
      expect(find.text(en.joinFamilyPrompt), findsNothing);
      await enterField(tester, en.babyNameLabel, 'Bilal');
      await pickBirthDate(tester, en.birthDateLabel);
      await pickCountry(tester, en.countryLabel, 'PK');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton));
      expectNoErrors(tester);

      final babies = await babyRows(tester, env);
      expect(babies.map((b) => b['name']), ['Aisha', 'Bilal']);
      expect(babies.map((b) => b['family_id']).toSet(), {env.familyId});
      expect(await settingValue(tester, env, SettingKeys.babyId), babies.last['id']);
      expect(await query(tester, env, 'SELECT id FROM families'), hasLength(1));
      // Back on Settings; closing it shows Bilal on Today.
      await tester.pageBack();
      await settle(tester);
      expect(_inAppBar(find.text('Bilal')), findsOneWidget);
    });

    flowWidgets('deleting the chosen baby switches to the other one', (tester) async {
      final bilal = (await tester.runAsync(() => env.seedBaby(name: 'Bilal', sex: 'male')))!;
      await tester.runAsync(() => env.setting(SettingKeys.babyId, bilal));
      await pumpPalna(tester, env);
      expect(_inAppBar(find.text('Bilal')), findsOneWidget);
      await openSettings(tester);
      await tapAndSettle(tester, find.byIcon(Icons.edit_outlined).last);
      expect(find.widgetWithText(TextFormField, 'Bilal'), findsOneWidget);
      await scrollAndTap(tester, find.widgetWithText(TextButton, en.deleteButton));
      await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));
      await tester.pageBack();
      await settle(tester);
      expectNoErrors(tester);
      expect(_inAppBar(find.text('Aisha')), findsOneWidget);
    });
  });

  group('switching baby', () {
    late FlowEnv env;
    late String bilal;
    setUp(() async {
      env = await FlowEnv.open();
      bilal = await env.seedBaby(name: 'Bilal', sex: 'male', country: 'GB');
    });
    tearDown(() => env.close());

    flowWidgets('from Settings: tap a baby', (tester) async {
      await pumpPalna(tester, env);
      expect(_inAppBar(find.text('Aisha')), findsOneWidget, reason: 'the first baby is shown until one is chosen');
      await openSettings(tester);
      await tapAndSettle(tester, find.text('Bilal'));
      expect(await settingValue(tester, env, SettingKeys.babyId), bilal);
      await tester.pageBack();
      await settle(tester);
      expect(_inAppBar(find.text('Bilal')), findsOneWidget);
    });

    flowWidgets('from the Today title', (tester) async {
      await pumpPalna(tester, env);
      await tapAndSettle(tester, _inAppBar(find.text('Aisha')));
      expect(find.text(en.switchBaby), findsOneWidget);
      await tapAndSettle(tester, _inSheet(find.text('Bilal')));
      expect(await settingValue(tester, env, SettingKeys.babyId), bilal);
      expect(_inAppBar(find.text('Bilal')), findsOneWidget);
    });

    for (final tab in [en.tabFeeding, en.tabGrowth, en.tabHealth]) {
      flowWidgets('from the $tab title, and the tab follows the new baby', (tester) async {
        await pumpPalna(tester, env);
        await tapAndSettle(tester, _tab(tab));
        expect(_inAppBar(find.text('Aisha')), findsOneWidget);
        expect(_inAppBar(find.byIcon(Icons.arrow_drop_down)), findsOneWidget);
        await tapAndSettle(tester, _inAppBar(find.text('Aisha')));
        await tapAndSettle(tester, _inSheet(find.text('Bilal')));
        expectNoErrors(tester);
        expect(await settingValue(tester, env, SettingKeys.babyId), bilal);
        expect(_inAppBar(find.text('Bilal')), findsOneWidget);
        // Still on the same tab.
        expect(_inAppBar(find.text(tab)), findsOneWidget);
      });
    }

    flowWidgets('the chosen baby is remembered after a restart', (tester) async {
      await pumpPalna(tester, env);
      await tapAndSettle(tester, _inAppBar(find.text('Aisha')));
      await tapAndSettle(tester, _inSheet(find.text('Bilal')));
      await restartPalna(tester, env);
      expect(_inAppBar(find.text('Bilal')), findsOneWidget);
    });

    flowWidgets('the Help screen follows the chosen baby\'s country', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.babyId, bilal));
      await pumpPalna(tester, env);
      await tapAndSettle(tester, find.byTooltip(en.helpTitle));
      expect(find.text(en.emergencyNumbersIn(countryName('GB', 'en'))), findsOneWidget);
    });
  });

  group('one baby', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('tab titles show the name without a switcher', (tester) async {
      await pumpPalna(tester, env);
      for (final tab in [en.tabFeeding, en.tabGrowth, en.tabHealth]) {
        await tapAndSettle(tester, _tab(tab));
        expect(_inAppBar(find.text('Aisha')), findsOneWidget, reason: tab);
        expect(_inAppBar(find.byIcon(Icons.arrow_drop_down)), findsNothing, reason: tab);
        await tester.tap(_inAppBar(find.text('Aisha')));
        await settle(tester);
        expect(find.text(en.switchBaby), findsNothing, reason: tab);
      }
    });
  });

  group('language', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('Urdu: text and right-to-left layout, saved, and kept after a restart', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text('اردو'));
      expectNoErrors(tester);
      expect(await settingValue(tester, env, SettingKeys.locale), 'ur');
      final title = find.text(ur.settingsTitle);
      expect(title, findsOneWidget);
      expect(Directionality.of(tester.element(title)), TextDirection.rtl);

      await restartPalna(tester, env);
      expect(_tab(ur.tabToday), findsOneWidget);
      expect(Directionality.of(tester.element(_tab(ur.tabToday))), TextDirection.rtl);
    });

    flowWidgets('Roman Urdu: Latin text, left-to-right, saved', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text('Roman Urdu'));
      expect(await settingValue(tester, env, SettingKeys.locale), 'ur_Latn');
      final title = find.text(roman.settingsTitle);
      expect(title, findsOneWidget);
      expect(Directionality.of(tester.element(title)), TextDirection.ltr);
    });

    flowWidgets('back to English from Urdu', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await pumpPalna(tester, env);
      await openSettings(tester, ur);
      await scrollAndTap(tester, find.text('English'));
      expect(await settingValue(tester, env, SettingKeys.locale), 'en');
      expect(find.text(en.settingsTitle), findsOneWidget);
      expect(Directionality.of(tester.element(find.text(en.settingsTitle))), TextDirection.ltr);
    });
  });

  group('appearance', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    Brightness brightness(WidgetTester tester) => Theme.of(tester.element(find.text(en.settingsTitle))).brightness;

    flowWidgets('Dark and Light are saved and applied; kept after a restart', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      expect(brightness(tester), Brightness.light);
      await scrollAndTap(tester, find.text(en.themeDark));
      expect(await settingValue(tester, env, SettingKeys.themeMode), 'dark');
      expect(brightness(tester), Brightness.dark);
      await scrollAndTap(tester, find.text(en.themeLight));
      expect(await settingValue(tester, env, SettingKeys.themeMode), 'light');
      expect(brightness(tester), Brightness.light);

      await scrollAndTap(tester, find.text(en.themeDark));
      await restartPalna(tester, env);
      expect(Theme.of(tester.element(_tab(en.tabToday))).brightness, Brightness.dark);
    });

    flowWidgets('Phone follows the phone\'s setting', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.runAsync(() => env.setting(SettingKeys.themeMode, 'light'));
      await pumpPalna(tester, env);
      await openSettings(tester);
      expect(brightness(tester), Brightness.light);
      await scrollAndTap(tester, find.text(en.themeSystem));
      expect(await settingValue(tester, env, SettingKeys.themeMode), isNull);
      expect(brightness(tester), Brightness.dark);
    });
  });
}

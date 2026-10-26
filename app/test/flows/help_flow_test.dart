// Emergency & help (the red SOS button): the numbers follow the baby's
// country, tapping one opens the phone's dialer with that number, the
// hot-weather advice shows only where it applies, and a country without a
// list says to save the local number.

import 'package:baby_app/core/countries.dart';
import 'package:baby_app/core/emergency.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'baby_settings_flow_support.dart';
import 'harness.dart';

void main() {
  setUpFlowTests();
  final plugins = fakePlugins();

  Future<FlowEnv> openWith(String country) async {
    final env = await FlowEnv.open(baby: false);
    await env.seedBaby(country: country);
    return env;
  }

  Future<void> openHelp(WidgetTester tester, FlowEnv env) async {
    await pumpPalna(tester, env);
    await tapAndSettle(tester, find.byTooltip(en.helpTitle));
    expect(find.text(en.helpTitle), findsOneWidget);
    expectNoErrors(tester);
  }

  /// A number on the help screen (always written left to right).
  Finder number(String n) => find.descendant(of: find.byType(ListTile), matching: find.text(n));

  group('Pakistan', () {
    late FlowEnv env;
    setUp(() async => env = await openWith('PK'));
    tearDown(() => env.close());

    flowWidgets('lists Rescue 1122, Edhi, Chhipa, police and fire, with heat advice', (tester) async {
      await openHelp(tester, env);
      expect(find.text(en.emergencyNumbersIn(countryName('PK', 'en'))), findsOneWidget);
      for (final n in emergencyNumbers('PK')) {
        await tester.scrollUntilVisible(number(n.number), 200, scrollable: find.byType(Scrollable).first);
        expect(number(n.number), findsOneWidget, reason: n.number);
      }
      expect(find.text(en.numRescue), findsOneWidget);
      await tester.scrollUntilVisible(find.text(en.heatTitle), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text(en.heatTitle), findsOneWidget);
    });

    flowWidgets('tapping 1122 opens the dialer with tel:1122', (tester) async {
      await openHelp(tester, env);
      await tapAndSettle(tester, number('1122'));
      expect(plugins.launched, ['tel:1122']);
    });

    flowWidgets('the help screen works in Urdu', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await pumpPalna(tester, env);
      await tapAndSettle(tester, find.byTooltip(ur.helpTitle));
      expectNoErrors(tester);
      expect(find.text(ur.emergencyNumbersIn(countryName('PK', 'ur'))), findsOneWidget);
      expect(number('1122'), findsOneWidget);
      // Numbers read left to right even in Urdu.
      expect(tester.widget<Text>(number('1122')).textDirection, TextDirection.ltr);
    });
  });

  group('United Kingdom', () {
    late FlowEnv env;
    setUp(() async => env = await openWith('GB'));
    tearDown(() => env.close());

    flowWidgets('lists 999 and NHS 111, no Pakistan numbers, no heat advice', (tester) async {
      await openHelp(tester, env);
      expect(find.text(en.emergencyNumbersIn(countryName('GB', 'en'))), findsOneWidget);
      expect(number('999'), findsOneWidget);
      expect(number('111'), findsOneWidget);
      expect(find.text(en.numNhs111), findsOneWidget);
      expect(number('1122'), findsNothing);
      await tester.scrollUntilVisible(find.text(en.dehydrationTitle), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text(en.heatTitle), findsNothing);
    });
  });

  group('United States', () {
    late FlowEnv env;
    setUp(() async => env = await openWith('US'));
    tearDown(() => env.close());

    flowWidgets('the poison line is dialled without its dashes', (tester) async {
      await openHelp(tester, env);
      await tapAndSettle(tester, number('1-800-222-1222'));
      expect(plugins.launched, ['tel:18002221222']);
    });
  });

  group('an EU country', () {
    late FlowEnv env;
    setUp(() async => env = await openWith('FR'));
    tearDown(() => env.close());

    flowWidgets('shows 112', (tester) async {
      await openHelp(tester, env);
      expect(number('112'), findsOneWidget);
      expect(find.text(en.emergencyNumbersNote), findsOneWidget);
    });
  });

  group('a country without a list', () {
    late FlowEnv env;
    setUp(() async => env = await openWith('JP'));
    tearDown(() => env.close());

    flowWidgets('says to save the local number, and shows no numbers', (tester) async {
      await openHelp(tester, env);
      expect(find.text(en.noEmergencyNumbers), findsOneWidget);
      expect(find.byIcon(Icons.call), findsNothing);
      // The danger signs are still there.
      expect(find.text(en.callEmergencyWhen), findsOneWidget);
    });
  });
}

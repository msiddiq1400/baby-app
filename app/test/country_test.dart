// The baby's country: names, emergency numbers, and the screens that change
// with it (vaccines, emergency help, the required field on the baby form).

import 'package:baby_app/core/countries.dart';
import 'package:baby_app/core/emergency.dart';
import 'package:baby_app/data/baby_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/vaccine_repository.dart';
import 'package:baby_app/features/baby/add_baby_screen.dart';
import 'package:baby_app/features/health/vaccines_view.dart';
import 'package:baby_app/features/settings/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'test_app.dart';

final _now = DateTime.now();

Baby _baby(String country) => Baby(
      id: 'b1',
      familyId: 'f1',
      name: 'Aisha',
      birthDate: DateTime(_now.year, _now.month - 3, _now.day),
      countryCode: country,
    );

const _bcg = VaccineDose(code: 'BCG', name: 'BCG', dueAgeValue: 0, dueAgeUnit: 'day', sortOrder: 10);

Future<void> _pump(WidgetTester tester, Widget screen, {required String country, Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(1080, 2316);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final baby = _baby(country);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentBabyProvider.overrideWith((ref) => Stream.value(baby)),
        vaccineScheduleProvider.overrideWith((ref, c) => Stream.value(c == 'PK' ? const [_bcg] : const [])),
        vaccinationsProvider.overrideWith(
          (ref, id) => Stream.value([
            Vaccination(id: 'v1', vaccineCode: 'BCG', givenOn: baby.birthDate),
            Vaccination(
              id: 'v2',
              vaccineCode: Vaccination.otherCode,
              vaccineName: 'Typhoid (private)',
              givenOn: baby.birthDate.add(const Duration(days: 30)),
            ),
          ]),
        ),
      ],
      child: testApp(locale: locale, home: screen),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    await loadAppFonts();
  });

  group('countries', () {
    test('names follow the app language', () {
      expect(countryName('GB', 'en'), 'United Kingdom');
      expect(countryName('GB', 'ur'), 'برطانیہ');
      expect(countryName('GB', 'ur', scriptCode: 'Latn'), 'United Kingdom');
      expect(countryName('JP', 'ur'), 'Japan'); // no Urdu name: English
    });

    test('every featured country is in the full list, once', () {
      expect(allCountries.toSet().length, allCountries.length);
      for (final c in featuredCountries) {
        expect(allCountries, contains(c));
      }
      expect(allCountries, contains(defaultCountry));
    });

    test('search matches English and Urdu names and codes', () {
      expect(countryMatches('GB', 'king'), isTrue);
      expect(countryMatches('PK', 'پاک'), isTrue);
      expect(countryMatches('AE', 'ae'), isTrue);
      expect(countryMatches('US', 'saudi'), isFalse);
    });
  });

  group('emergency numbers', () {
    test('by country', () {
      expect(primaryEmergencyNumber('PK'), '1122 / 115');
      expect(primaryEmergencyNumber('GB'), '999');
      expect(primaryEmergencyNumber('US'), '911');
      expect(primaryEmergencyNumber('DE'), '112');
      expect(primaryEmergencyNumber('JP'), isNull);
      expect(emergencyNumbers('JP'), isEmpty);
    });
  });

  testWidgets('Vaccines in Pakistan show the schedule and vaccines added by name', (tester) async {
    await _pump(tester, Scaffold(body: VaccinesView(baby: _baby('PK'))), country: 'PK');
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Pakistan EPI'), findsOneWidget);
    expect(find.text('Other vaccines'), findsOneWidget);
    expect(find.text('Typhoid (private)'), findsOneWidget);
  });

  testWidgets('Vaccines in a country without a schedule never show Pakistan\'s', (tester) async {
    await _pump(tester, Scaffold(body: VaccinesView(baby: _baby('JP'))), country: 'JP');
    expect(tester.takeException(), isNull);
    expect(find.text('No built-in vaccine schedule for Japan yet'), findsOneWidget);
    expect(find.textContaining('BCG'), findsNothing);
    expect(find.text('Typhoid (private)'), findsOneWidget);
    await tester.tap(find.text('Add a vaccine'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Vaccine name'), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('ur')]) {
    testWidgets('Vaccines without a schedule build in $locale', (tester) async {
      await _pump(tester, Scaffold(body: VaccinesView(baby: _baby('JP'))), country: 'JP', locale: locale);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Help shows the numbers for the baby\'s country', (tester) async {
    await _pump(tester, const HelpScreen(), country: 'GB');
    expect(tester.takeException(), isNull);
    expect(find.text('999'), findsOneWidget);
    expect(find.text('1122'), findsNothing);
    expect(find.text('Emergency numbers (United Kingdom)'), findsOneWidget);
  });

  testWidgets('Help for a country we have no numbers for says so', (tester) async {
    await _pump(tester, const HelpScreen(), country: 'JP');
    expect(tester.takeException(), isNull);
    expect(find.textContaining("We don't have the numbers"), findsOneWidget);
    expect(find.text('1122'), findsNothing);
  });

  testWidgets('A new baby needs a country, picked from the list', (tester) async {
    await _pump(tester, const Scaffold(body: SizedBox()), country: 'PK');
    tester.state<NavigatorState>(find.byType(Navigator)).push(MaterialPageRoute(builder: (_) => const AddBabyScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Ali');
    await tester.tap(find.text('Save'));
    await tester.pump();
    // Birth date and country are both still required.
    expect(find.text('Required'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.public));
    await tester.pumpAndSettle();
    await tester.tap(find.text('United Kingdom'));
    await tester.pumpAndSettle();
    expect(find.text('United Kingdom'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget); // only the birth date now
  });
}

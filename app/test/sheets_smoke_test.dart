// Opens every entry form (bottom sheet) with sample data, in English and in
// Urdu, and fails on any exception or layout overflow.

import 'dart:convert';
import 'dart:io';

import 'package:baby_app/data/content.dart';
import 'package:baby_app/data/illness_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/growth/growth_sheet.dart';
import 'package:baby_app/features/health/illness_sheets.dart';
import 'package:baby_app/features/health/medicine_sheet.dart';
import 'package:baby_app/features/health/symptom_sheet.dart';
import 'package:baby_app/features/health/vaccination_sheet.dart';
import 'package:baby_app/features/home/log_sheets.dart';
import 'package:baby_app/features/milk/milk_sheets.dart';
import 'package:baby_app/features/settings/change_password_dialog.dart';
import 'package:baby_app/features/settings/delete_account_dialog.dart';
import 'package:baby_app/features/solids/food_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens_smoke_test.dart' show baby, medication, overrides;

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    await loadAppFonts();
  });

  final guide = FoodGuide.fromJson(
    jsonDecode(File('assets/foods.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final egg = guide.food('egg')!;
  final now = DateTime.now();
  const dose = VaccineDose(
    code: 'OPV-1',
    name: 'Oral Polio Vaccine',
    doseLabel: 'Dose 1',
    dueAgeValue: 6,
    dueAgeUnit: 'week',
    sortOrder: 20,
  );

  final sheets = <String, Future<void> Function(BuildContext)>{
    'new feed': (c) => showFeedSheet(c, baby),
    'edit feed': (c) => showFeedSheet(
      c,
      baby,
      existing: Feed(
        id: 'f',
        type: FeedType.bottleFormula,
        startedAt: now,
        amountMl: 120,
      ),
    ),
    'new diaper': (c) => showDiaperSheet(c, baby),
    'edit sleep': (c) => showSleepSheet(
      c,
      baby,
      Sleep(
        id: 's',
        kind: SleepKind.nap,
        startedAt: now.subtract(const Duration(hours: 1)),
        endedAt: now,
      ),
    ),
    'growth': (c) => showGrowthSheet(c, baby),
    'vaccination': (c) => showRecordVaccinationSheet(c, baby, [dose]),
    'new medicine': (c) => showMedicineSheet(c, baby),
    'edit medicine': (c) => showMedicineSheet(c, baby, existing: medication),
    'symptom': (c) => showSymptomSheet(c, baby),
    'pumping': (c) => showPumpingSheet(c, baby),
    'stored milk': (c) => showAddMilkSheet(c, baby),
    'food': (c) => showFoodSheet(c, baby, guide, egg),
    'food try': (c) => showTrySheet(c, baby, egg),
    'new illness': (c) => showIllnessSheet(c, baby),
    'edit illness': (c) => showIllnessSheet(
      c,
      baby,
      existing: Illness(id: 'i', name: 'Cold', startedAt: now.subtract(const Duration(days: 3)), recoveredAt: now),
    ),
    'doctor visit': (c) => showDoctorVisitSheet(c, baby),
  };

  for (final locale in const [Locale('en'), Locale('ur')]) {
    for (final MapEntry(key: name, value: open) in sheets.entries) {
      testWidgets('$name form opens without errors ($locale)', (tester) async {
        tester.view.physicalSize = const Size(1080, 2316);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: testApp(
              locale: locale,
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => open(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        for (var i = 0; i < 6; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump(const Duration(milliseconds: 150));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(BottomSheet), findsOneWidget);
      });
    }
  }

  for (final locale in const [
    Locale('en'),
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
  ]) {
    testWidgets('delete account needs DELETE typed ($locale)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2316);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: testApp(
            locale: locale,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showDeleteAccountDialog(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      FilledButton button() =>
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'delet');
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'delete');
      await tester.pump();
      expect(button().onPressed, isNotNull);
    });
  }

  testWidgets('change password needs matching passwords', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: testApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showChangePasswordDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextFormField).at(0), 'secret123');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret124');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text("The passwords don't match"), findsOneWidget);
  });
}

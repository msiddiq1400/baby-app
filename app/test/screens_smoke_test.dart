// Builds every main screen with realistic sample data, in English and in
// Urdu (right-to-left), on a phone-sized screen. Fails on any exception or
// layout overflow while building, so broken screens are caught without a
// phone.

import 'dart:convert';
import 'dart:io';

import 'package:baby_app/data/baby_repository.dart';
import 'package:baby_app/data/content.dart';
import 'package:baby_app/data/family_repository.dart';
import 'package:baby_app/data/growth_repository.dart';
import 'package:baby_app/data/illness_repository.dart';
import 'package:baby_app/data/journal_repository.dart';
import 'package:baby_app/data/medication_repository.dart';
import 'package:baby_app/data/milk_repository.dart';
import 'package:baby_app/data/photo_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/data/solids_repository.dart';
import 'package:baby_app/data/symptom_repository.dart';
import 'package:baby_app/data/tracking_repository.dart';
import 'package:baby_app/data/vaccine_repository.dart';
import 'package:baby_app/features/auth/reset_password_screen.dart';
import 'package:baby_app/features/auth/sign_in_screen.dart';
import 'package:baby_app/features/baby/add_baby_screen.dart';
import 'package:baby_app/features/growth/growth_screen.dart';
import 'package:baby_app/features/health/health_screen.dart';
import 'package:baby_app/features/health/illness_screen.dart';
import 'package:baby_app/features/home/dashboard.dart';
import 'package:baby_app/features/milk/milk_screen.dart';
import 'package:baby_app/features/journal/journal_screen.dart';
import 'package:baby_app/features/reports/reports_screen.dart';
import 'package:baby_app/features/settings/change_password_dialog.dart';
import 'package:baby_app/features/settings/help_screen.dart';
import 'package:baby_app/features/settings/settings_screen.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:baby_app/features/solids/recipes_screen.dart';
import 'package:baby_app/features/solids/solids_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';
import 'package:intl/date_symbol_data_local.dart';

final now = DateTime.now();
DateTime ago({int days = 0, int hours = 0, int minutes = 0}) =>
    now.subtract(Duration(days: days, hours: hours, minutes: minutes));

final baby = Baby(
  id: 'b1',
  familyId: 'f1',
  name: 'Aisha',
  birthDate: DateTime(now.year, now.month - 5, now.day - 20),
  sex: 'female',
  birthWeightG: 3200,
);

final feeds = [
  for (var d = 0; d < 3; d++)
    for (var h = 0; h < 7; h++)
      Feed(
        id: 'f$d$h',
        type: h.isEven ? FeedType.breast : FeedType.bottleBreastMilk,
        startedAt: ago(days: d, hours: 1 + h * 3),
        side: h.isEven ? BreastSide.left : null,
        amountMl: h.isEven ? null : 120,
      ),
];

final sleeps = [
  for (var d = 1; d <= 7; d++) ...[
    Sleep(
      id: 'n$d',
      kind: SleepKind.night,
      startedAt: ago(days: d, hours: 4),
      endedAt: ago(days: d - 1, hours: 14),
    ),
    Sleep(
      id: 's$d',
      kind: SleepKind.nap,
      startedAt: ago(days: d, hours: 8),
      endedAt: ago(days: d, hours: 6),
    ),
  ],
  Sleep(
    id: 'today',
    kind: SleepKind.nap,
    startedAt: ago(hours: 3),
    endedAt: ago(hours: 2),
  ),
];

final todayLog = TodayLog(
  dayStart: DateTime(now.year, now.month, now.day),
  feeds: feeds.where((f) => f.startedAt.day == now.day).toList(),
  diapers: [
    Diaper(id: 'd1', occurredAt: ago(hours: 1), isWet: true, isDirty: false),
    Diaper(id: 'd2', occurredAt: ago(hours: 4), isWet: true, isDirty: true),
  ],
  // Includes a long sleep, so long durations ("13 گھنٹے 20 منٹ") are always
  // on screen whatever time the tests run.
  sleeps: [
    ...sleeps.where((s) => s.endedAt!.day == now.day),
    Sleep(
      id: 'long',
      kind: SleepKind.night,
      startedAt: DateTime(now.year, now.month, now.day),
      endedAt: now,
    ),
  ],
);

/// Set by a test to show a running feed timer or sleep on the Today screen.
Feed? runningFeed;
Sleep? runningSleep;

/// Set by a test to replace the recent feeds (oldest first).
List<Feed>? recentFeeds;

final medication = Medication(
  id: 'm1',
  name: 'Paracetamol syrup',
  prescribedDose: '2.5 ml',
  // A dose every 2 hours, so whatever time the tests run there are missed,
  // due and upcoming doses on screen (layout bugs hid behind the clock).
  doseTimes: [for (var h = 0; h < 24; h += 2) DoseTime(h, 0)],
  asNeeded: false,
  startDate: DateTime(now.year, now.month, now.day - 1),
  endDate: DateTime(now.year, now.month, now.day + 3),
);

final overrides = [
  settingProvider.overrideWith((ref, key) => Stream.value(null)),
  babiesProvider.overrideWith((ref) => Stream.value([baby])),
  currentBabyProvider.overrideWith((ref) => Stream.value(baby)),
  todayLogProvider.overrideWith(
    (ref, id) => Stream.value(
      runningSleep == null
          ? todayLog
          : TodayLog(
              dayStart: todayLog.dayStart,
              feeds: todayLog.feeds,
              diapers: todayLog.diapers,
              sleeps: [runningSleep!, ...todayLog.sleeps],
            ),
    ),
  ),
  feedTimerProvider.overrideWith((ref, id) => Stream.value(runningFeed)),
  canChangePasswordProvider.overrideWithValue(true),
  illnessesProvider.overrideWith(
    (ref, id) => Stream.value([
      Illness(id: 'ill', name: 'Cold', startedAt: ago(days: 2, hours: 3)),
      Illness(id: 'old', name: 'Tummy bug', startedAt: ago(days: 40), recoveredAt: ago(days: 36)),
    ]),
  ),
  illnessEpisodeProvider.overrideWith(
    (ref, key) => Stream.value(
      IllnessEpisode(
        illness: Illness(id: key.illnessId, name: 'Cold', startedAt: ago(days: 2, hours: 3)),
        symptoms: [
          SymptomLog(id: 'x1', symptom: 'fever', occurredAt: ago(days: 2), temperatureC: 38.6, severity: 2),
          SymptomLog(id: 'x2', symptom: 'cough', occurredAt: ago(days: 1), notes: 'worse at night'),
          SymptomLog(id: 'x3', symptom: 'fever', occurredAt: ago(hours: 2), temperatureC: 37.9),
        ],
        doses: [
          (
            dose: MedicationDose(id: 'y1', medicationId: 'm1', givenAt: ago(hours: 1), skipped: false),
            medicine: 'Paracetamol syrup',
          ),
        ],
        visits: [
          DoctorVisit(id: 'v1', visitedAt: ago(days: 1, hours: 2), doctor: 'Dr Amina', diagnosis: 'Viral cold', advice: 'Fluids, rest'),
        ],
      ),
    ),
  ),
  journalDayProvider.overrideWith(
    (ref, key) => Stream.value(
      JournalDay(
        day: key.day,
        log: TodayLog(dayStart: key.day, feeds: feeds.take(6).toList(), diapers: todayLog.diapers, sleeps: sleeps.take(3).toList()),
        pumping: [PumpingSession(id: 'jp', startedAt: key.day.add(const Duration(hours: 9)), side: BreastSide.both, amountMl: 90)],
        doses: [
          (
            dose: MedicationDose(id: 'jd', medicationId: 'm1', givenAt: key.day.add(const Duration(hours: 8)), skipped: false),
            medicine: 'Paracetamol syrup',
          ),
        ],
        symptoms: [SymptomLog(id: 'js', symptom: 'fever', occurredAt: key.day.add(const Duration(hours: 10)), temperatureC: 38.1, severity: 2)],
        foodTries: [FoodTry(id: 'jf', foodId: 'egg', triedOn: key.day, reaction: 'mild', opinion: 'liked')],
        growth: [GrowthMeasurement(id: 'jg', measuredOn: key.day, weightG: 7100, lengthMm: 655, headMm: 425)],
        vaccinations: [Vaccination(id: 'jv', vaccineCode: 'BCG', givenOn: key.day)],
        milestones: [MilestoneCheck(id: 'jm', milestoneId: '6m-laughs', achievedOn: key.day)],
      ),
    ),
  ),
  reportFeedsProvider.overrideWith((ref, p) => Stream.value(feeds)),
  reportSleepsProvider.overrideWith((ref, p) => Stream.value(sleeps)),
  reportDiapersProvider.overrideWith(
    (ref, p) => Stream.value([
      for (var d = 0; d < 7; d++)
        for (var h = 0; h < 6; h++) Diaper(id: 'r$d$h', occurredAt: ago(days: d, hours: h * 3), isWet: true, isDirty: h == 2),
    ]),
  ),
  // Oldest first, like the database returns them.
  recentFeedsProvider.overrideWith((ref, id) => Stream.value(recentFeeds ?? feeds.reversed.toList())),
  recentSleepsProvider.overrideWith((ref, id) => Stream.value(sleeps)),
  vaccineScheduleProvider.overrideWith(
    (ref, country) => Stream.value([
      const VaccineDose(
        code: 'BCG',
        name: 'BCG',
        dueAgeValue: 0,
        dueAgeUnit: 'day',
        sortOrder: 10,
      ),
      const VaccineDose(
        code: 'OPV-1',
        name: 'Oral Polio Vaccine',
        doseLabel: 'Dose 1',
        dueAgeValue: 6,
        dueAgeUnit: 'week',
        sortOrder: 20,
      ),
      const VaccineDose(
        code: 'MR-1',
        name: 'Measles-Rubella',
        doseLabel: 'Dose 1',
        dueAgeValue: 9,
        dueAgeUnit: 'month',
        sortOrder: 50,
      ),
    ]),
  ),
  vaccinationsProvider.overrideWith(
    (ref, id) => Stream.value([
      Vaccination(
        id: 'v1',
        vaccineCode: 'BCG',
        givenOn: baby.birthDate,
        clinic: 'Civil Hospital',
      ),
    ]),
  ),
  medicationsProvider.overrideWith((ref, id) => Stream.value([medication])),
  recentDosesProvider.overrideWith(
    (ref, id) => Stream.value([
      MedicationDose(
        id: 'd1',
        medicationId: 'm1',
        givenAt: DateTime(now.year, now.month, now.day, 8, 5),
        skipped: false,
        scheduledFor: DateTime(now.year, now.month, now.day, 8),
      ),
    ]),
  ),
  growthMeasurementsProvider.overrideWith(
    (ref, id) => Stream.value([
      GrowthMeasurement(
        id: 'g1',
        measuredOn: ago(days: 60),
        weightG: 5100,
        lengthMm: 590,
        headMm: 395,
      ),
      // A month before the latest, so the weight-gain card shows.
      GrowthMeasurement(id: 'g15', measuredOn: ago(days: 40), weightG: 6700),
      GrowthMeasurement(
        id: 'g2',
        measuredOn: ago(days: 10),
        weightG: 7250,
        lengthMm: 655,
        headMm: 425,
      ),
    ]),
  ),
  milkBagsProvider.overrideWith(
    (ref, id) => Stream.value([
      MilkBag(
        id: 'k1',
        pumpedAt: ago(days: 1),
        amountMl: 120,
        location: MilkLocation.fridge,
      ),
      MilkBag(
        id: 'k2',
        pumpedAt: ago(days: 20),
        amountMl: 90,
        location: MilkLocation.freezer,
        frozenAt: ago(days: 20),
      ),
      MilkBag(
        id: 'k3',
        pumpedAt: ago(days: 5),
        amountMl: 60,
        location: MilkLocation.fridge,
      ),
    ]),
  ),
  pumpingTodayProvider.overrideWith(
    (ref, id) => Stream.value([
      PumpingSession(
        id: 'p1',
        startedAt: ago(hours: 2),
        side: BreastSide.both,
        amountMl: 110,
      ),
    ]),
  ),
  recentSymptomsProvider.overrideWith(
    (ref, id) => Stream.value([
      SymptomLog(
        id: 's1',
        symptom: 'fever',
        occurredAt: ago(hours: 5),
        temperatureC: 38.2,
        severity: 2,
        notes: 'fussy',
      ),
      SymptomLog(id: 's2', symptom: 'cough', occurredAt: ago(days: 1)),
    ]),
  ),
  foodTriesProvider.overrideWith(
    (ref, id) => Stream.value([
      FoodTry(
        id: 't1',
        foodId: 'banana',
        triedOn: ago(days: 2),
        opinion: 'liked',
        reaction: 'none',
      ),
      FoodTry(
        id: 't2',
        foodId: 'egg',
        triedOn: ago(days: 1),
        reaction: 'mild',
        notes: 'rash on cheek',
      ),
    ]),
  ),
  milestoneChecksProvider.overrideWith(
    (ref, id) => Stream.value({
      '6m-laughs': MilestoneCheck(
        id: 'c1',
        milestoneId: '6m-laughs',
        achievedOn: ago(days: 3),
      ),
    }),
  ),
  photosProvider.overrideWith(
    (ref, id) => Stream.value(const [
      Photo(id: 'p1', ageMonth: 0, caption: 'First day home'),
      Photo(id: 'p2', ageMonth: 2),
    ]),
  ),
  familyMembersProvider.overrideWith(
    (ref, id) async => const [
      FamilyMember(userId: 'u1', name: 'Sana', isOwner: true, isMe: true),
      FamilyMember(userId: 'u2', name: 'Ali', isOwner: false, isMe: false),
    ],
  ),
];

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen,
  Locale locale, {
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(1080, 2316); // the test phone
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: testApp(locale: locale, home: screen, brightness: brightness),
    ),
  );
  // Let streams, futures and asset loads settle (no pumpAndSettle: the
  // "now" ticker and spinners never settle).
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    await loadAppFonts();
  });
  // A cached asset load from an earlier test belongs to that test's fake
  // clock and never completes in the next one.
  setUp(rootBundle.clear);

  final screens = <String, Widget Function()>{
    'Today': () => Dashboard(baby: baby),
    'Milk': () => MilkScreen(baby: baby),
    'Solids': () => SolidsScreen(baby: baby),
    'Growth': () => GrowthScreen(baby: baby),
    'Health': () => HealthScreen(baby: baby),
    'Settings': () => const SettingsScreen(),
    'Help': () => const HelpScreen(),
    'Reports': () => ReportsScreen(baby: baby),
    'Journal': () => JournalScreen(baby: baby),
    'Illness': () => IllnessScreen(baby: baby, illnessId: 'ill'),
    'Sign in': () => const SignInScreen(),
    'Reset password': () => const ResetPasswordScreen(email: 'sana@example.com'),
    'Edit baby': () => AddBabyScreen(existing: baby),
  };

  for (final locale in const [
    Locale('en'),
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
  ]) {
    for (final MapEntry(key: name, value: build) in screens.entries) {
      testWidgets('$name builds without errors ($locale)', (tester) async {
        await pumpScreen(tester, build(), locale);
        expect(tester.takeException(), isNull);
        expect(find.byType(Scaffold), findsWidgets);
      });
    }
  }

  for (final locale in const [Locale('en'), Locale('ur')]) {
    for (final name in ['Today', 'Health', 'Reports', 'Settings', 'Journal', 'Illness']) {
      testWidgets('$name builds in dark mode ($locale)', (tester) async {
        await pumpScreen(tester, screens[name]!(), locale, brightness: Brightness.dark);
        expect(tester.takeException(), isNull);
        expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);
      });
    }
  }

  for (final (locale, label) in const [
    (Locale('en'), 'Continue with Apple'),
    (Locale('ur'), 'ایپل کے ساتھ جاری رکھیں'),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets('Sign in shows Sign in with Apple on iPhone ($locale, ${brightness.name})', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        try {
          await pumpScreen(tester, const SignInScreen(), locale, brightness: brightness);
          expect(tester.takeException(), isNull);
          expect(find.text(label), findsOneWidget);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  }

  testWidgets('Sign in has no Apple button on Android', (tester) async {
    await pumpScreen(tester, const SignInScreen(), const Locale('en'));
    expect(find.text('Continue with Apple'), findsNothing);
  });

  for (final locale in const [
    Locale('en'),
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
  ]) {
    testWidgets('Recipes build and open ($locale)', (tester) async {
      final guide = FoodGuide.fromJson(
        jsonDecode(File('assets/foods.json').readAsStringSync()) as Map<String, dynamic>,
      );
      await pumpScreen(tester, Scaffold(body: RecipesView(baby: baby, guide: guide)), locale);
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Solids: Foods tab shows progress and tried / not-tried groups, other tabs build', (tester) async {
    await pumpScreen(tester, SolidsScreen(baby: baby), const Locale('en'));
    expect(tester.takeException(), isNull);
    // The baby is over 5 months, so Solids opens on Foods.
    expect(find.textContaining('foods tried'), findsOneWidget);
    expect(find.textContaining('allergens introduced'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Not tried yet'), 300, scrollable: find.byType(Scrollable).last);
    expect(find.text('Not tried yet'), findsOneWidget);
    for (final (tab, expected) in [('Guides', 'Is my baby ready?'), ('Recipes', 'From 6 months')]) {
      await tester.tap(find.text(tab));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull, reason: tab);
      expect(find.text(expected), findsWidgets, reason: tab);
    }
  });

  testWidgets('Solids guides: opening one closes the other', (tester) async {
    final guide = FoodGuide.fromJson(
      jsonDecode(File('assets/foods.json').readAsStringSync()) as Map<String, dynamic>,
    );
    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    await pumpScreen(tester, SolidsScreen(baby: baby), const Locale('en'));
    await tester.tap(find.text('Guides'));
    await settle();
    // The allergic-reaction signs live on Foods only.
    expect(find.text('Signs of an allergic reaction'), findsNothing);
    final readiness = find.text(guide.readiness.english);
    final firstRule = find.text('• ${guide.rules.first.english}');

    await tester.tap(find.text('Is my baby ready?'));
    await settle();
    expect(readiness, findsOneWidget);

    await tester.tap(find.text('Important rules'));
    await settle();
    expect(firstRule, findsOneWidget);
    expect(readiness, findsNothing, reason: 'the first guide closes');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Health inner tabs (medicines, symptoms) build', (tester) async {
    await pumpScreen(tester, HealthScreen(baby: baby), const Locale('en'));
    for (final (tab, expected) in [
      ('Medicines', 'Paracetamol'),
      ('Symptoms', '· Cold'),
    ]) {
      await tester.tap(find.text(tab));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull, reason: tab);
      expect(find.textContaining(expected), findsWidgets, reason: tab);
    }
  });

  testWidgets('Growth shows weight gain against WHO', (tester) async {
    await pumpScreen(tester, GrowthScreen(baby: baby), const Locale('en'));
    expect(tester.takeException(), isNull);
    expect(find.text('Weight gain over the last month'), findsOneWidget);
    expect(find.text('Within the usual range for babies this age.'), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('ur')]) {
    testWidgets('Growth photos tab builds ($locale)', (tester) async {
      await pumpScreen(tester, GrowthScreen(baby: baby), locale);
      await tester.tap(find.text(lookupAppLocalizations(locale).tabPhotos));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull);
      // The baby is 5 months: newborn to 5 months, two with photos.
      expect(find.text(lookupAppLocalizations(locale).addPhoto), findsNWidgets(4));
    });
  }

  testWidgets('Growth milestones tab builds', (tester) async {
    await pumpScreen(tester, GrowthScreen(baby: baby), const Locale('en'));
    await tester.tap(find.text('Milestones'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
    expect(find.text('By 6 months'), findsOneWidget);
  });

  for (final locale in const [
    Locale('en'),
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
  ]) {
    for (final paused in [false, true]) {
      testWidgets('Today with a running feed timer and sleep ($locale, paused: $paused)', (tester) async {
        runningFeed = Feed(
          id: 'timer',
          type: FeedType.breast,
          startedAt: ago(minutes: 20),
          leftSeconds: 480,
          rightSeconds: 0,
          timerSide: BreastSide.right,
          timerStartedAt: paused ? null : ago(minutes: 5),
        );
        runningSleep = Sleep(id: 'zz', kind: SleepKind.nap, startedAt: ago(minutes: 40));
        addTearDown(() => runningFeed = runningSleep = null);

        await pumpScreen(tester, Dashboard(baby: baby), locale);
        expect(tester.takeException(), isNull);
        final l10n = lookupAppLocalizations(locale);
        expect(find.text(paused ? l10n.feedTimerPaused : l10n.feedingNowTitle), findsOneWidget);
        expect(find.text('08:00'), findsWidgets); // left side, banked (also the total when paused)
        expect(find.text(l10n.finishFeed), findsOneWidget);
        expect(find.text(l10n.asleepNap), findsOneWidget);
      });
    }
  }

  testWidgets('Journal shows every kind of entry and swipes to the day before', (tester) async {
    await pumpScreen(tester, JournalScreen(baby: baby), const Locale('en'));
    expect(tester.takeException(), isNull);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('On this day'), findsOneWidget);
    // The list is long and built lazily; scroll to each entry (their order
    // depends on the time of day the test runs).
    final list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
    for (final text in ['Weight 7.10 kg', 'Pumping · Both · 90 ml', 'Paracetamol syrup · Given']) {
      await tester.scrollUntilVisible(find.textContaining(text), 200, scrollable: list);
      expect(find.textContaining(text), findsOneWidget);
    }
    await tester.drag(list, const Offset(0, 3000));
    await tester.pump();

    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Yesterday'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Today shows patterns in the cards, and no "At a glance" (Health has that)', (tester) async {
    await pumpScreen(tester, Dashboard(baby: baby), const Locale('en'));
    expect(find.text('At a glance'), findsNothing);
    expect(find.textContaining('Next feed may be around'), findsOneWidget);
    expect(find.textContaining('Usually about'), findsOneWidget);
  });

  testWidgets('Today has one way into reports: the cards (no duplicate links)', (tester) async {
    await pumpScreen(tester, Dashboard(baby: baby), const Locale('en'));
    expect(find.byIcon(Icons.insights_outlined), findsNothing);
    expect(find.text('Reports and trends'), findsNothing);
    // Help and Settings are buttons, not hidden in a language menu.
    expect(find.byTooltip('Emergency & help'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Journal'), findsOneWidget); // the full journal
    // Small labelled buttons on each card.
    expect(find.text('Past feed'), findsOneWidget);
    expect(find.text('Past sleep'), findsOneWidget);
    expect(find.text('Past diaper'), findsOneWidget);
    // "Past days" sits on each card, not next to today's timeline.
    expect(find.text('Past days'), findsNWidgets(3));

    await tester.tap(find.text('Diapers'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
    expect(find.byType(ReportsScreen), findsOneWidget);
    expect(find.text('Wet a day'), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('ur')]) {
    testWidgets('Reports has a tab each for feeds, sleep and diapers ($locale)', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      await pumpScreen(tester, ReportsScreen(baby: baby), locale);
      expect(find.text(l10n.feedsPerDay), findsOneWidget);
      expect(find.text(l10n.sleepPerDay), findsNothing);

      for (final (tab, shown, hidden) in [
        (l10n.sleep, l10n.sleepPerDay, l10n.feedsPerDay),
        (l10n.diapers, l10n.wetPerDay, l10n.sleepPerDay),
      ]) {
        await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text(tab)));
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(tester.takeException(), isNull, reason: tab);
        expect(find.text(shown), findsOneWidget, reason: tab);
        expect(find.text(hidden), findsNothing, reason: tab);
      }
    });
  }

  testWidgets('Past days from the Feeds card shows only feeds', (tester) async {
    await pumpScreen(tester, JournalScreen(baby: baby, only: TrackedTable.feeds), const Locale('en'));
    expect(tester.takeException(), isNull);
    expect(find.text('Feeds'), findsOneWidget); // the title
    expect(find.byIcon(Icons.local_drink_outlined), findsWidgets);
    expect(find.byIcon(Icons.bedtime_outlined), findsNothing);
    expect(find.byIcon(Icons.baby_changing_station_outlined), findsNothing);
    expect(find.textContaining('Pumping'), findsNothing);
    expect(find.text('On this day'), findsNothing);
  });

  final en = lookupAppLocalizations(const Locale('en'));
  for (final (tab, titles) in [
    (ReportTab.feeds, [en.chartFeedsPerDay, en.chartFeedTimes, en.chartBottleMl]),
    (ReportTab.sleep, [en.chartSleepPerDay, en.chartSleepPattern, en.chartLongestSleep]),
    (ReportTab.diapers, [en.chartDiapersPerDay, en.chartDiaperTimes]),
  ]) {
    testWidgets('Reports ${tab.name} tab has all its charts', (tester) async {
      await pumpScreen(tester, ReportsScreen(baby: baby, initialTab: tab), const Locale('en'));
      // A very tall screen, so every chart on the tab is built.
      tester.view.physicalSize = const Size(1080, 12000);
      await tester.pump();
      for (final title in titles) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('30-day reports build in Urdu', (tester) async {
    await pumpScreen(tester, ReportsScreen(baby: baby, initialTab: ReportTab.sleep), const Locale('ur'));
    await tester.tap(find.text(lookupAppLocalizations(const Locale('ur')).periodDays(30)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reports opens on the tab asked for', (tester) async {
    await pumpScreen(tester, ReportsScreen(baby: baby, initialTab: ReportTab.sleep), const Locale('en'));
    expect(find.text('Sleep a day'), findsOneWidget);
    expect(find.text('Feeds a day'), findsNothing);
  });
}

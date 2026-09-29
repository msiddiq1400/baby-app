// Renders real app screens (real fonts, realistic sample data) to PNGs for
// the website and store listings:
//
//   cd app
//   flutter test tool/screenshots --update-goldens
//
// Output: tool/screenshots/out/<screen>_<locale>.png at the test phone's
// resolution (1080 x 2316). Not part of the normal test run. The data is a
// believable day for a 5-month-old.

import 'package:baby_app/core/providers.dart';
import 'package:baby_app/data/baby_repository.dart';
import 'package:baby_app/data/family_repository.dart';
import 'package:baby_app/data/growth_repository.dart';
import 'package:baby_app/data/journal_repository.dart';
import 'package:baby_app/data/medication_repository.dart';
import 'package:baby_app/data/milk_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/data/solids_repository.dart';
import 'package:baby_app/data/symptom_repository.dart';
import 'package:baby_app/data/tracking_repository.dart';
import 'package:baby_app/data/vaccine_repository.dart';
import 'package:baby_app/features/growth/growth_screen.dart';
import 'package:baby_app/features/health/health_screen.dart';
import 'package:baby_app/features/home/dashboard.dart';
import 'package:baby_app/features/journal/journal_screen.dart';
import 'package:baby_app/features/milk/milk_screen.dart';
import 'package:baby_app/features/reports/reports_screen.dart';
import 'package:baby_app/features/solids/solids_screen.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../test/test_app.dart';

// The screens' clock (nowProvider) reads 3:40 PM today, whatever time this
// runs, so insights like "awake for" and "next feed" look like an afternoon.
final _real = DateTime.now();
final now = DateTime(_real.year, _real.month, _real.day, 15, 40);
final today = DateTime(now.year, now.month, now.day);
DateTime at(int daysAgo, int hour, [int minute = 0]) =>
    DateTime(now.year, now.month, now.day - daysAgo, hour, minute);
bool past(DateTime t) => t.isBefore(now);

final baby = Baby(
  id: 'b1',
  familyId: 'f1',
  name: 'Aisha',
  birthDate: DateTime(now.year, now.month - 5, now.day - 20),
  sex: 'female',
  birthWeightG: 3200,
  birthLengthMm: 495,
  birthHeadMm: 340,
);
DateTime ageDays(int d) => baby.birthDate.add(Duration(days: d));

// Feeds about every 3 hours, alternating breast and a bottle of expressed milk.
final feeds = [
  for (var d = 0; d < 4; d++)
    for (final (i, (h, m)) in const [(0, 30), (4, 0), (7, 10), (10, 20), (13, 30), (16, 40), (19, 45), (22, 30)].indexed)
      if (past(at(d, h, m)))
        Feed(
          id: 'f$d-$i',
          type: i.isEven ? FeedType.breast : FeedType.bottleBreastMilk,
          startedAt: at(d, h, m),
          endedAt: i.isEven ? at(d, h, m + 18) : null,
          side: i.isEven ? (i % 4 == 0 ? BreastSide.left : BreastSide.right) : null,
          amountMl: i.isEven ? null : 120,
        ),
];

// A week of feeds and diapers for the reports, varying a little by day.
final weekFeeds = [
  for (var d = 0; d < 8; d++)
    for (final (i, (h, m)) in const [(0, 30), (4, 0), (7, 10), (10, 20), (13, 30), (16, 40), (19, 45), (22, 30)].indexed)
      if (past(at(d, h, m)) && !(d.isOdd && i == 3))
        Feed(
          id: 'w$d-$i',
          type: i.isEven ? FeedType.breast : FeedType.bottleBreastMilk,
          startedAt: at(d, h, m),
          endedAt: i.isEven ? at(d, h, m + 14 + d % 3 * 2) : null,
          leftSeconds: i.isEven ? (i % 4 == 0 ? 9 : 6) * 60 : null,
          rightSeconds: i.isEven ? (i % 4 == 0 ? 6 : 9) * 60 + d * 20 : null,
          side: i.isEven ? BreastSide.both : null,
          amountMl: i.isEven ? null : 110 + d % 3 * 10,
        ),
];
final weekDiapers = [
  for (var d = 0; d < 8; d++)
    for (final (i, h) in const [6, 9, 12, 15, 18, 21, 23].indexed)
      if (past(at(d, h, 50)) && !(d % 3 == 0 && i == 6))
        Diaper(id: 'wd$d-$i', occurredAt: at(d, h, 50), isWet: true, isDirty: i == 1 || (i == 4 && d.isEven)),
];

final sleeps = [
  for (var d = 1; d <= 8; d++) ...[
    Sleep(id: 'n$d', kind: SleepKind.night, startedAt: at(d, 20, 30), endedAt: at(d - 1, 6, 40)),
    Sleep(id: 'a$d', kind: SleepKind.nap, startedAt: at(d, 9, 30), endedAt: at(d, 10, 50)),
    Sleep(id: 'b$d', kind: SleepKind.nap, startedAt: at(d, 13, 0), endedAt: at(d, 14, 30)),
    Sleep(id: 'c$d', kind: SleepKind.nap, startedAt: at(d, 17, 0), endedAt: at(d, 17, 40)),
  ],
  for (final s in [
    Sleep(id: 'a0', kind: SleepKind.nap, startedAt: at(0, 9, 30), endedAt: at(0, 10, 45)),
    Sleep(id: 'b0', kind: SleepKind.nap, startedAt: at(0, 13, 10), endedAt: at(0, 14, 35)),
    Sleep(id: 'c0', kind: SleepKind.nap, startedAt: at(0, 17, 0), endedAt: at(0, 17, 35)),
  ])
    if (past(s.endedAt!)) s,
];

final todayLog = TodayLog(
  dayStart: today,
  feeds: feeds.where((f) => !f.startedAt.isBefore(today)).toList(),
  diapers: [
    for (final (i, (h, dirty)) in const [(6, false), (9, true), (12, false), (15, false), (18, true), (21, false)].indexed)
      if (past(at(0, h, 50))) Diaper(id: 'd$i', occurredAt: at(0, h, 50), isWet: true, isDirty: dirty),
  ],
  sleeps: sleeps.where((s) => s.endedAt!.isAfter(today)).toList(),
);

final schedule = [
  VaccineDose(code: 'BCG', name: 'BCG', dueAgeValue: 0, dueAgeUnit: 'day', sortOrder: 10),
  VaccineDose(code: 'OPV-0', name: 'Oral Polio Vaccine', doseLabel: 'Dose 0', dueAgeValue: 0, dueAgeUnit: 'day', sortOrder: 11),
  VaccineDose(code: 'HEPB-0', name: 'Hepatitis B', doseLabel: 'Birth', dueAgeValue: 0, dueAgeUnit: 'day', sortOrder: 12),
  for (final (w, n, o) in [(6, 1, 20), (10, 2, 30), (14, 3, 40)]) ...[
    VaccineDose(code: 'OPV-$n', name: 'Oral Polio Vaccine', doseLabel: 'Dose $n', dueAgeValue: w, dueAgeUnit: 'week', sortOrder: o),
    VaccineDose(code: 'PENTA-$n', name: 'Pentavalent (DTP-HepB-Hib)', doseLabel: 'Dose $n', dueAgeValue: w, dueAgeUnit: 'week', sortOrder: o + 1),
    VaccineDose(code: 'PCV-$n', name: 'Pneumococcal (PCV)', doseLabel: 'Dose $n', dueAgeValue: w, dueAgeUnit: 'week', sortOrder: o + 2),
  ],
  VaccineDose(code: 'ROTA-1', name: 'Rotavirus', doseLabel: 'Dose 1', dueAgeValue: 6, dueAgeUnit: 'week', sortOrder: 23),
  VaccineDose(code: 'ROTA-2', name: 'Rotavirus', doseLabel: 'Dose 2', dueAgeValue: 10, dueAgeUnit: 'week', sortOrder: 33),
  VaccineDose(code: 'IPV-1', name: 'Inactivated Polio Vaccine', doseLabel: 'Dose 1', dueAgeValue: 14, dueAgeUnit: 'week', sortOrder: 43),
  VaccineDose(code: 'MR-1', name: 'Measles-Rubella', doseLabel: 'Dose 1', dueAgeValue: 9, dueAgeUnit: 'month', sortOrder: 50),
  VaccineDose(code: 'TCV', name: 'Typhoid Conjugate', dueAgeValue: 9, dueAgeUnit: 'month', sortOrder: 51),
  VaccineDose(code: 'IPV-2', name: 'Inactivated Polio Vaccine', doseLabel: 'Dose 2', dueAgeValue: 9, dueAgeUnit: 'month', sortOrder: 52),
  VaccineDose(code: 'MR-2', name: 'Measles-Rubella', doseLabel: 'Dose 2', dueAgeValue: 15, dueAgeUnit: 'month', sortOrder: 60),
];

// Everything up to 14 weeks given on time.
final vaccinations = [
  for (final d in schedule)
    if (d.dueAgeUnit != 'month')
      Vaccination(
        id: d.code,
        vaccineCode: d.code,
        givenOn: ageDays(d.dueAgeUnit == 'week' ? d.dueAgeValue * 7 : 1),
        clinic: 'Civil Hospital',
      ),
];

final vitaminD = Medication(
  id: 'm1',
  name: 'Vitamin D drops',
  prescribedDose: '400 IU',
  doseTimes: const [DoseTime(9, 0)],
  asNeeded: false,
  startDate: baby.birthDate,
);

final overrides = [
  settingProvider.overrideWith((ref, key) => Stream.value(null)),
  babiesProvider.overrideWith((ref) => Stream.value([baby])),
  currentBabyProvider.overrideWith((ref) => Stream.value(baby)),
  todayLogProvider.overrideWith((ref, id) => Stream.value(todayLog)),
  recentFeedsProvider.overrideWith((ref, id) => Stream.value(feeds)),
  reportFeedsProvider.overrideWith((ref, p) => Stream.value(weekFeeds)),
  reportSleepsProvider.overrideWith((ref, p) => Stream.value(sleeps)),
  reportDiapersProvider.overrideWith((ref, p) => Stream.value(weekDiapers)),
  journalDayProvider.overrideWith(
    (ref, key) => Stream.value(
      JournalDay(
        day: key.day,
        log: todayLog,
        pumping: [PumpingSession(id: 'p1', startedAt: at(0, 7, 15), endedAt: at(0, 7, 35), side: BreastSide.both, amountMl: 110)],
        doses: [(dose: MedicationDose(id: 'dz', medicationId: 'm1', givenAt: at(0, 9, 5), skipped: false), medicine: 'Vitamin D drops')],
        foodTries: [FoodTry(id: 'tk', foodId: 'khichdi', triedOn: key.day, opinion: 'liked', reaction: 'none')],
        growth: [GrowthMeasurement(id: 'gz', measuredOn: key.day, weightG: 6950, lengthMm: 648, headMm: 418)],
      ),
    ),
  ),
  recentSleepsProvider.overrideWith((ref, id) => Stream.value(sleeps)),
  vaccineScheduleProvider.overrideWith((ref) => Stream.value(schedule)),
  vaccinationsProvider.overrideWith((ref, id) => Stream.value(vaccinations)),
  medicationsProvider.overrideWith((ref, id) => Stream.value([vitaminD])),
  recentDosesProvider.overrideWith(
    (ref, id) => Stream.value([
      for (var d = 0; d < 7; d++)
        if (past(at(d, 9, 5)))
          MedicationDose(id: 'dose$d', medicationId: 'm1', givenAt: at(d, 9, 5), skipped: false, scheduledFor: at(d, 9)),
    ]),
  ),
  growthMeasurementsProvider.overrideWith(
    (ref, id) => Stream.value([
      // Close to the WHO median for girls.
      GrowthMeasurement(id: 'g1', measuredOn: ageDays(30), weightG: 4150, lengthMm: 538, headMm: 364),
      GrowthMeasurement(id: 'g2', measuredOn: ageDays(61), weightG: 5100, lengthMm: 574, headMm: 381),
      GrowthMeasurement(id: 'g3', measuredOn: ageDays(122), weightG: 6350, lengthMm: 623, headMm: 405),
      GrowthMeasurement(id: 'g4', measuredOn: ageDays(160), weightG: 6950, lengthMm: 648, headMm: 418),
    ]),
  ),
  milkBagsProvider.overrideWith(
    (ref, id) => Stream.value([
      MilkBag(id: 'k1', pumpedAt: at(0, 7, 30), amountMl: 110, location: MilkLocation.fridge),
      MilkBag(id: 'k2', pumpedAt: at(1, 21), amountMl: 90, location: MilkLocation.fridge),
      MilkBag(id: 'k3', pumpedAt: at(12, 8), amountMl: 120, location: MilkLocation.freezer, frozenAt: at(12, 9)),
      MilkBag(id: 'k4', pumpedAt: at(18, 8), amountMl: 100, location: MilkLocation.freezer, frozenAt: at(18, 9)),
    ]),
  ),
  pumpingTodayProvider.overrideWith(
    (ref, id) => Stream.value([
      PumpingSession(id: 'p1', startedAt: at(0, 7, 15), endedAt: at(0, 7, 35), side: BreastSide.both, amountMl: 110),
    ]),
  ),
  recentSymptomsProvider.overrideWith((ref, id) => Stream.value(const <SymptomLog>[])),
  foodTriesProvider.overrideWith(
    (ref, id) => Stream.value([
      FoodTry(id: 't1', foodId: 'banana', triedOn: at(4, 12), opinion: 'liked', reaction: 'none'),
      FoodTry(id: 't2', foodId: 'egg', triedOn: at(2, 12), opinion: 'okay', reaction: 'none'),
      FoodTry(id: 't3', foodId: 'khichdi', triedOn: at(1, 12), opinion: 'liked', reaction: 'none'),
    ]),
  ),
  milestoneChecksProvider.overrideWith(
    (ref, id) => Stream.value({
      for (final m in ['4m-smiles', '4m-chuckles', '4m-coos', '6m-laughs'])
        m: MilestoneCheck(id: m, milestoneId: m, achievedOn: at(20, 10)),
    }),
  ),
  familyMembersProvider.overrideWith(
    (ref, id) async => const [
      FamilyMember(userId: 'u1', name: 'Sana', isOwner: true, isMe: true),
      FamilyMember(userId: 'u2', name: 'Ali', isOwner: false, isMe: false),
    ],
  ),
];

/// The screen inside the app's bottom tab bar, as on the phone.
class _Shell extends StatelessWidget {
  const _Shell({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.today_outlined), selectedIcon: const Icon(Icons.today), label: l10n.tabToday),
          NavigationDestination(icon: const Icon(Icons.water_drop_outlined), selectedIcon: const Icon(Icons.water_drop), label: l10n.tabMilk),
          NavigationDestination(icon: const Icon(Icons.restaurant_outlined), selectedIcon: const Icon(Icons.restaurant), label: l10n.tabSolids),
          NavigationDestination(icon: const Icon(Icons.show_chart), label: l10n.tabGrowth),
          NavigationDestination(icon: const Icon(Icons.vaccines_outlined), selectedIcon: const Icon(Icons.vaccines), label: l10n.tabHealth),
        ],
      ),
    );
  }
}

final _root = GlobalKey();

/// Pumps until the content files (foods, WHO data, milestones) have loaded
/// and no spinner is left, or about 10 seconds have passed.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 100));
    if (i >= 5 && find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
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

  // name -> (tab index, screen, a tab inside the screen to open first)
  final shots = <String, (int, Widget, String?)>{
    'today': (0, Dashboard(baby: baby), null),
    'timer': (0, Dashboard(baby: baby), null),
    'milk': (1, MilkScreen(baby: baby), null),
    'solids': (2, SolidsScreen(baby: baby), null),
    'growth': (3, GrowthScreen(baby: baby), null),
    'milestones': (3, GrowthScreen(baby: baby), 'milestones'),
    'vaccines': (4, HealthScreen(baby: baby), null),
    'reports': (0, ReportsScreen(baby: baby), null),
    'journal': (0, JournalScreen(baby: baby), null),
    'reports2': (0, ReportsScreen(baby: baby), 'scroll'),
  };

  for (final (locale, tag) in const [
    (Locale('en'), 'en'),
    (Locale('ur'), 'ur'),
    (Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'), 'roman'),
  ]) {
    for (final MapEntry(key: name, value: (tab, screen, inner)) in shots.entries) {
      testWidgets('screenshot $name $tag', (tester) async {
        tester.view.physicalSize = const Size(1080, 2316);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          RepaintBoundary(
            key: _root,
            child: ProviderScope(
              overrides: [
                ...overrides,
                nowProvider.overrideWith((ref) => Stream.value(now)),
                // The timer card ticks on the real clock, so its times are
                // relative to the real time.
                feedTimerProvider.overrideWith(
                  (ref, id) => Stream.value(
                    name != 'timer'
                        ? null
                        : Feed(
                            id: 'timer',
                            type: FeedType.breast,
                            startedAt: _real.subtract(const Duration(minutes: 12)),
                            leftSeconds: 7 * 60 + 42,
                            rightSeconds: 0,
                            timerSide: BreastSide.right,
                            timerStartedAt: _real.subtract(const Duration(minutes: 4, seconds: 18)),
                          ),
                  ),
                ),
              ],
              child: testApp(locale: locale, home: _Shell(index: tab, child: screen)),
            ),
          ),
        );
        await _settle(tester);
        if (inner == 'scroll') {
          await tester.drag(find.byType(ListView).first, const Offset(0, -700));
          await _settle(tester);
        }
        if (inner == 'milestones') {
          final l10n = lookupAppLocalizations(locale);
          await tester.tap(find.text(l10n.tabMilestones));
          await _settle(tester);
        }
        await expectLater(find.byKey(_root), matchesGoldenFile('out/${name}_$tag.png'));
      });
    }
  }
}

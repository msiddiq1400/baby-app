import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/health/vaccine_plan.dart';
import 'package:baby_app/features/home/home_widget_sync.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(initializeDateFormatting);
  final l10n = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 9, 30, 15, 40);
  final baby = Baby(id: 'b', familyId: 'f', name: 'Aisha', birthDate: DateTime(2026, 4, 10));
  String ms(DateTime t) => '${t.millisecondsSinceEpoch}';

  test('no baby yet: just the name placeholder', () {
    final v = widgetValues(l10n: l10n, now: now);
    expect(v['baby_name'], isNull);
    expect(v['feed_since'], isNull);
    expect(v['label_empty'], 'Tap to open Palna');
  });

  test('last feed, and awake since the last sleep ended', () {
    final feeds = [
      Feed(id: '1', type: FeedType.bottleFormula, startedAt: DateTime(2026, 9, 30, 10), amountMl: 120),
      Feed(
        id: '2',
        type: FeedType.breast,
        startedAt: DateTime(2026, 9, 30, 13, 30),
        endedAt: DateTime(2026, 9, 30, 13, 48),
        side: BreastSide.left,
      ),
    ];
    final sleeps = [
      Sleep(id: 's', kind: SleepKind.nap, startedAt: DateTime(2026, 9, 30, 13, 50), endedAt: DateTime(2026, 9, 30, 14, 35)),
    ];
    final v = widgetValues(l10n: l10n, now: now, baby: baby, recentFeeds: feeds, recentSleeps: sleeps);
    expect(v['baby_name'], 'Aisha');
    expect(v['feed_label'], 'Last feed');
    // Counted from when the last feed ended.
    expect(v['feed_since'], ms(DateTime(2026, 9, 30, 13, 48)));
    expect(v['feed_detail'], contains('Breast'));
    expect(v['sleep_label'], 'Awake');
    expect(v['sleep_since'], ms(DateTime(2026, 9, 30, 14, 35)));
    expect(v['vaccine'], isNull);
  });

  test('a running feed timer and an ongoing sleep take priority', () {
    final timer = Feed(
      id: 't',
      type: FeedType.breast,
      startedAt: DateTime(2026, 9, 30, 15, 30),
      leftSeconds: 0,
      rightSeconds: 0,
      timerSide: BreastSide.right,
      timerStartedAt: DateTime(2026, 9, 30, 15, 30),
    );
    final v = widgetValues(
      l10n: l10n,
      now: now,
      baby: baby,
      feedTimer: timer,
      ongoingSleep: Sleep(id: 'z', kind: SleepKind.nap, startedAt: DateTime(2026, 9, 30, 15)),
    );
    expect(v['feed_label'], 'Feeding now');
    expect(v['feed_detail'], 'Right');
    expect(v['sleep_label'], 'Asleep');
    expect(v['sleep_since'], ms(DateTime(2026, 9, 30, 15)));
  });

  test('awake is hidden when the last sleep ended long ago (sleep probably not logged)', () {
    final v = widgetValues(
      l10n: l10n,
      now: now,
      baby: baby,
      recentSleeps: [
        Sleep(id: 'old', kind: SleepKind.night, startedAt: DateTime(2026, 9, 28, 21), endedAt: DateTime(2026, 9, 29, 6)),
      ],
    );
    expect(v['sleep_since'], isNull);
  });

  test('next vaccines', () {
    final visit = planVisits(baby.birthDate, const [
      VaccineDose(code: 'MR-1', name: 'Measles-Rubella', dueAgeValue: 9, dueAgeUnit: 'month', sortOrder: 50),
    ], []).single;
    final v = widgetValues(l10n: l10n, now: now, baby: baby, nextVisit: visit);
    expect(v['vaccine'], startsWith('Next vaccines ('));
    expect(v['vaccine'], endsWith('Jan 10'));
  });
}

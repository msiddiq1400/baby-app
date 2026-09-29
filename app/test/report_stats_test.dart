import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/reports/report_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // "Now" is 3 pm on 30 Sep; the 7-day period is 24-30 Sep.
  final now = DateTime(2026, 9, 30, 15);
  DateTime at(int daysAgo, int hour, [int minute = 0]) => DateTime(2026, 9, 30 - daysAgo, hour, minute);

  final feeds = [
    // Two full days of feeds: 3 on the 29th, 5 on the 28th.
    for (final h in [6, 10, 14]) Feed(id: 'a$h', type: FeedType.bottleFormula, startedAt: at(1, h), amountMl: 120),
    for (final h in [5, 8, 11, 14, 17])
      Feed(
        id: 'b$h',
        type: FeedType.breast,
        startedAt: at(2, h),
        endedAt: at(2, h, 15),
        leftSeconds: 600,
        rightSeconds: 300,
        side: BreastSide.both,
      ),
    // Today doesn't count towards averages.
    Feed(id: 'today', type: FeedType.bottleFormula, startedAt: at(0, 9), amountMl: 90),
  ];
  final diapers = [
    for (final h in [6, 9, 12, 15]) Diaper(id: 'w$h', occurredAt: at(1, h), isWet: true, isDirty: h == 9),
    for (final h in [7, 13]) Diaper(id: 'x$h', occurredAt: at(2, h), isWet: true, isDirty: true),
  ];
  final sleeps = [
    // Night from 9 pm on the 28th to 6 am on the 29th: 3h on the 28th, 6h on the 29th.
    Sleep(id: 'n1', kind: SleepKind.night, startedAt: at(2, 21), endedAt: at(1, 6)),
    Sleep(id: 'n2', kind: SleepKind.night, startedAt: at(1, 20), endedAt: at(0, 7)),
    Sleep(id: 'n3', kind: SleepKind.night, startedAt: at(3, 22), endedAt: at(2, 6)),
    Sleep(id: 'p1', kind: SleepKind.nap, startedAt: at(1, 10), endedAt: at(1, 12)),
    Sleep(id: 'p2', kind: SleepKind.nap, startedAt: at(1, 14), endedAt: at(1, 15)),
  ];

  final days = dailyStats(feeds: feeds, diapers: diapers, sleeps: sleeps, days: 7, now: now);

  test('one entry per day, oldest first, ending today', () {
    expect(days.length, 7);
    expect(days.first.day, DateTime(2026, 9, 24));
    expect(days.last.day, DateTime(2026, 9, 30));
  });

  test('daily totals', () {
    final d29 = days[5], d28 = days[4];
    expect(d29.feeds, 3);
    expect(d29.bottles, 3);
    expect(d29.bottleMl, 360);
    expect(d28.feeds, 5);
    expect(d28.nursingSeconds, 5 * 900);
    expect(d28.leftSeconds, 3000);
    expect(d29.wet, 4);
    expect(d29.dirty, 1);
    // Night sleep crossing midnight is split between the days.
    expect(d28.night, const Duration(hours: 3 + 6));
    expect(d29.night, const Duration(hours: 6 + 4));
    expect(d29.naps, const Duration(hours: 3));
    expect(d29.napCount, 2);
  });

  test('averages use only full days that have that kind of entry', () {
    final sum = summarize(days: days, feeds: feeds, sleeps: sleeps, now: now);
    expect(sum.feedsPerDay, 4); // (3 + 5) / 2; today and empty days ignored
    expect(sum.bottleMlPerDay, 360);
    expect(sum.mlPerBottle, 120);
    expect(sum.nursingPerDay, const Duration(minutes: 75));
    expect(sum.nursingPerFeed, const Duration(minutes: 15));
    expect(sum.leftShare, closeTo(2 / 3, 0.001));
    expect(sum.wetPerDay, 3); // (4 + 2) / 2
    expect(sum.dirtyPerDay, 1.5);
    // Sleep days need 8h+ logged: the 28th (9h) and the 29th (13h).
    expect(sum.sleepPerDay, const Duration(hours: 11));
    expect(sum.napsPerDay, 1);
    expect(sum.longestSleep, const Duration(hours: 11));
  });

  test('bedtime and wake-up are medians of night sleeps; late bedtimes average sensibly', () {
    final sum = summarize(days: days, feeds: feeds, sleeps: sleeps, now: now);
    expect(sum.bedtime, 21 * 60); // 8 pm, 9 pm, 10 pm
    expect(sum.wakeUp, 6 * 60);

    final late = [
      for (final (i, (h, m)) in const [(23, 30), (0, 30), (23, 50)].indexed)
        Sleep(
          id: 'l$i',
          kind: SleepKind.night,
          startedAt: at(i + 2, h, m).add(Duration(days: h < 12 ? 1 : 0)),
          endedAt: at(i + 1, 6),
        ),
    ];
    final lateSum = summarize(days: days, feeds: const [], sleeps: late, now: now);
    expect(lateSum.bedtime! % (24 * 60), 23 * 60 + 50); // not 12:30 pm
  });

  test('typical sleep by age (NSF under 4 months, AASM after)', () {
    expect(typicalSleepHours(30), (from: 14, to: 17));
    expect(typicalSleepHours(170), (from: 12, to: 16));
    expect(typicalSleepHours(400), (from: 11, to: 14));
  });

  test('NHS guides only show at the ages they apply to', () {
    expect(showNewbornFeeds(20), isTrue);
    expect(showNewbornFeeds(70), isFalse);
    expect(showWetGuide(3), isFalse);
    expect(showWetGuide(10), isTrue);
    expect(showDirtyGuide(50), isFalse);
  });
}

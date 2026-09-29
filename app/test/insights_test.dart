import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/home/insights.dart';
import 'package:flutter_test/flutter_test.dart';

Feed feed(DateTime at) => Feed(id: '$at', type: FeedType.breast, startedAt: at);
Sleep sleep(DateTime from, DateTime? to, {SleepKind kind = SleepKind.nap}) =>
    Sleep(id: '$from', kind: kind, startedAt: from, endedAt: to);

void main() {
  group('hunger estimate', () {
    test('needs enough history', () {
      expect(
        hungerEstimate([
          feed(DateTime(2026, 9, 29, 8)),
          feed(DateTime(2026, 9, 29, 11)),
        ]),
        isNull,
      );
    });

    test('median gap, ignoring long night gaps', () {
      final feeds = [
        for (final h in [6, 9, 12, 15, 18, 21])
          feed(DateTime(2026, 9, 28, h)), // 3 h gaps
        feed(DateTime(2026, 9, 29, 7)), // 10 h night gap: ignored
        feed(DateTime(2026, 9, 29, 9, 30)), // 2.5 h
        feed(DateTime(2026, 9, 29, 11)), // 1.5 h
      ];
      final estimate = hungerEstimate(feeds)!;
      expect(estimate.usualGap, const Duration(hours: 3));
      expect(estimate.nextAround, DateTime(2026, 9, 29, 14));
    });
  });

  group('sleep', () {
    final now = DateTime(2026, 9, 29, 15);

    test('a sleep across midnight is split between the days', () {
      final night = sleep(
        DateTime(2026, 9, 27, 20),
        DateTime(2026, 9, 28, 6),
        kind: SleepKind.night,
      );
      expect(
        sleepOnDay([night], DateTime(2026, 9, 27), now),
        const Duration(hours: 4),
      );
      expect(
        sleepOnDay([night], DateTime(2026, 9, 28), now),
        const Duration(hours: 6),
      );
    });

    test('usual daily sleep skips days with little logged', () {
      final sleeps = [
        for (var d = 22; d <= 28; d++) ...[
          sleep(DateTime(2026, 9, d, 0), DateTime(2026, 9, d, 7)), // 7 h
          if (d != 25)
            sleep(
              DateTime(2026, 9, d, 13),
              DateTime(2026, 9, d, 13 + (d.isEven ? 6 : 5)),
            ),
        ],
      ];
      // Days: 12/13 h alternating, except the 25th (7 h, not counted).
      expect(usualDailySleep(sleeps, now), const Duration(hours: 13));
      expect(usualDailySleep(sleeps.take(2).toList(), now), isNull);
    });

    test('wake window: awake since the last sleep, and usual gap', () {
      final sleeps = [
        sleep(DateTime(2026, 9, 29, 7), DateTime(2026, 9, 29, 8)),
        sleep(
          DateTime(2026, 9, 29, 10),
          DateTime(2026, 9, 29, 11),
        ), // 2 h awake before
        sleep(DateTime(2026, 9, 29, 13), DateTime(2026, 9, 29, 14)), // 2 h
        sleep(
          DateTime(2026, 9, 29, 16, 30),
          DateTime(2026, 9, 29, 17),
        ), // 2.5 h
      ];
      final w = wakeWindow(sleeps, DateTime(2026, 9, 29, 18, 20));
      expect(w.awakeFor, const Duration(hours: 1, minutes: 20));
      expect(w.usualAwake, const Duration(hours: 2));
    });

    test('no wake window while asleep', () {
      final w = wakeWindow([sleep(DateTime(2026, 9, 29, 13), null)], now);
      expect(w.awakeFor, isNull);
    });
  });
}

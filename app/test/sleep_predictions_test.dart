import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/home/sleep_predictions.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;
Sleep nap(DateTime start, DateTime end) => Sleep(id: '${_id++}', kind: SleepKind.nap, startedAt: start, endedAt: end);
Sleep night(DateTime start, DateTime? end) =>
    Sleep(id: '${_id++}', kind: SleepKind.night, startedAt: start, endedAt: end);

DateTime at(DateTime day, int h, [int m = 0]) => DateTime(day.year, day.month, day.day, h, m);

void main() {
  final today = DateTime(2026, 10, 28);
  // A 5-month-old: typical awake time 105-150 min.
  final birth = DateTime(2026, 5, 20);

  /// A week of a steady routine: night 19:30-6:30, naps after 2 h, 2.5 h
  /// and 3 h awake, then bed.
  List<Sleep> routineWeek() => [
        for (var i = 7; i >= 1; i--) ...() {
          final d = DateTime(today.year, today.month, today.day - i);
          return [
            night(at(d, 19, 30).subtract(const Duration(days: 1)), at(d, 6, 30)),
            nap(at(d, 8, 30), at(d, 9, 30)), // 2 h after waking
            nap(at(d, 12), at(d, 13)), // 2.5 h
            nap(at(d, 16), at(d, 16, 45)), // 3 h
          ];
        }(),
        night(at(today, 19, 30).subtract(const Duration(days: 1)), at(today, 6, 30)),
      ];

  test('typical awake times grow with age', () {
    expect(typicalAwakeMinutes(0), (min: 35, max: 60));
    expect(typicalAwakeMinutes(5), (min: 105, max: 150));
    expect(typicalAwakeMinutes(12).min, greaterThan(typicalAwakeMinutes(6).min));
    expect(typicalAwakeMinutes(30), (min: 300, max: 360));
  });

  test("the first nap comes from the baby's own first awake time of the day", () {
    final p = predictNextSleep(birthDate: birth, sleeps: routineWeek(), now: at(today, 7, 15))!;
    expect(p.kind, SleepPredictionKind.nap);
    expect(p.personal, isTrue);
    // Woke 6:30 + usual 2 h for the first nap = 8:30, give or take 15 min.
    expect(p.from, at(today, 8, 15));
    expect(p.to, at(today, 8, 45));
  });

  test('the second nap uses the second awake time (longer than the first)', () {
    final sleeps = [...routineWeek(), nap(at(today, 8, 30), at(today, 9, 30))];
    final p = predictNextSleep(birthDate: birth, sleeps: sleeps, now: at(today, 10))!;
    expect(p.from, at(today, 11, 45)); // 9:30 + 2.5 h - 15 min
  });

  test('when the next nap would be close to the usual bedtime, bedtime is predicted', () {
    final sleeps = [
      ...routineWeek(),
      nap(at(today, 8, 30), at(today, 9, 30)),
      nap(at(today, 12), at(today, 13)),
      nap(at(today, 16), at(today, 17, 30)), // a late, long last nap
    ];
    final p = predictNextSleep(birthDate: birth, sleeps: sleeps, now: at(today, 18))!;
    expect(p.kind, SleepPredictionKind.bedtime);
    expect(p.from, at(today, 19, 15));
    expect(p.to, at(today, 19, 45));
  });

  test("without a week of the baby's own sleep, typical awake times for the age are used", () {
    final sleeps = [night(at(today, 19).subtract(const Duration(days: 1)), at(today, 6))];
    final p = predictNextSleep(birthDate: birth, sleeps: sleeps, now: at(today, 6, 30))!;
    expect(p.personal, isFalse);
    // 6:00 + the middle of 105-150 min (2 h 7 min).
    final center = at(today, 6).add(const Duration(minutes: 127));
    expect(p.from, center.subtract(const Duration(minutes: 15)));
  });

  test("the baby's own pattern is kept within a sensible range for the age", () {
    // Gaps of 6 h (naps missed in the log) would predict far too late.
    final sleeps = <Sleep>[];
    for (var i = 5; i >= 1; i--) {
      final d = DateTime(today.year, today.month, today.day - i);
      sleeps
        ..add(night(at(d, 20).subtract(const Duration(days: 1)), at(d, 6)))
        ..add(nap(at(d, 12), at(d, 13)));
    }
    sleeps.add(night(at(today, 20).subtract(const Duration(days: 1)), at(today, 6)));
    final p = predictNextSleep(birthDate: birth, sleeps: sleeps, now: at(today, 7))!;
    // At most 150 min x 1.25 = 188 min (rounded) after waking at 6:00.
    expect(p.to, at(today, 6).add(const Duration(minutes: 188 + 15)));
  });

  test('no prediction while asleep, with nothing logged, for newborns, toddlers, or stale logs', () {
    final week = routineWeek();
    expect(predictNextSleep(birthDate: birth, sleeps: const [], now: at(today, 10)), isNull);
    expect(
      predictNextSleep(birthDate: birth, sleeps: [...week, nap(at(today, 8, 30), at(today, 8, 30)).copyOngoing()], now: at(today, 9)),
      isNull,
      reason: 'asleep',
    );
    expect(predictNextSleep(birthDate: DateTime(2026, 10, 20), sleeps: week, now: at(today, 7)), isNull, reason: '8 days old');
    expect(predictNextSleep(birthDate: DateTime(2023, 1, 1), sleeps: week, now: at(today, 7)), isNull, reason: '3+ years');
    // Woke 6:30; at 16:00 nothing else was logged: the log is incomplete.
    expect(predictNextSleep(birthDate: birth, sleeps: week, now: at(today, 16)), isNull, reason: 'stale');
  });

  test('a predicted time long past is dropped', () {
    // First nap due 8:15-8:45; at 10:00 it's over an hour past.
    expect(predictNextSleep(birthDate: birth, sleeps: routineWeek(), now: at(today, 10)), isNull);
    // At 9:15 it still shows (a little late is still useful).
    expect(predictNextSleep(birthDate: birth, sleeps: routineWeek(), now: at(today, 9, 15)), isNotNull);
  });
}

extension on Sleep {
  Sleep copyOngoing() => Sleep(id: id, kind: kind, startedAt: startedAt);
}

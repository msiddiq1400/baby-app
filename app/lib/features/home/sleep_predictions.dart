import '../../core/baby_age.dart';
import '../../data/models.dart';

// "Next nap around 2:15-2:45 pm" / "Bedtime around 7:15-7:45 pm" (Palna
// Pro). A rough guide, never advice: it comes from the baby's own recent
// awake times between sleeps, and from typical awake times for the age
// when there isn't enough of the baby's own data yet.

/// Typical awake time between sleeps by age (minutes), from common infant
/// sleep guidance. Used on its own until there's a week of the baby's own
/// sleep, and as the sensible range for the baby's own pattern after that.
({int min, int max}) typicalAwakeMinutes(int ageMonths) => switch (ageMonths) {
  0 => (min: 35, max: 60),
  1 => (min: 60, max: 90),
  2 => (min: 75, max: 105),
  3 => (min: 90, max: 120),
  4 || 5 => (min: 105, max: 150),
  6 || 7 => (min: 120, max: 180),
  8 || 9 => (min: 150, max: 210),
  < 14 => (min: 180, max: 240),
  < 18 => (min: 240, max: 330),
  _ => (min: 300, max: 360),
};

enum SleepPredictionKind { nap, bedtime }

/// When the next sleep is likely: a 30-minute window around [center].
/// [personal] is true when it comes from the baby's own pattern.
typedef SleepPrediction = ({SleepPredictionKind kind, DateTime from, DateTime to, bool personal});

const _halfWindow = Duration(minutes: 15);

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

T _median<T extends Comparable<T>>(List<T> values) => (values.toList()..sort())[values.length ~/ 2];

/// Minutes after noon, so a bedtime of 23:30 and one of 00:15 sort next to
/// each other (both late evening), not 23 hours apart.
int _minutesAfterNoon(DateTime t) => ((t.hour - 12) % 24) * 60 + t.minute;

/// The next nap (or bedtime) for a baby born on [birthDate], from [sleeps]
/// (the last week or so, any order). Null while asleep, with no sleep
/// logged, when the last wake-up was long ago (the log is probably
/// incomplete), outside the ages where naps are predictable (3 weeks to
/// 3 years), or when the predicted time has long passed.
SleepPrediction? predictNextSleep({required DateTime birthDate, required List<Sleep> sleeps, required DateTime now}) {
  final ageDays = _day(now).difference(_day(birthDate)).inDays;
  if (ageDays < 21) return null;
  final age = babyAge(birthDate, now).months;
  if (age >= 36) return null;

  final sorted = [...sleeps]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  if (sorted.isEmpty || sorted.last.isOngoing) return null;
  final lastWake = sorted.last.endedAt!;
  if (now.difference(lastWake) > const Duration(hours: 8) || lastWake.isAfter(now)) return null;

  // Awake gaps that ended in a nap during the day, with their place in the
  // day: 0 = from waking up in the morning to the first nap, 1 = from the
  // first nap to the second, ...
  final gaps = <(int, Duration)>[];
  var index = 0;
  for (var i = 1; i < sorted.length; i++) {
    final prev = sorted[i - 1], next = sorted[i];
    if (prev.kind == SleepKind.night) index = 0;
    final end = prev.endedAt;
    if (end == null) continue;
    final gap = next.startedAt.difference(end);
    if (next.kind == SleepKind.nap && gap.inMinutes >= 15 && gap.inHours < 8) {
      gaps.add((index, gap));
    }
    if (next.kind == SleepKind.nap) index++;
  }
  // Where today's next gap sits: naps since the baby last woke from the night.
  var todayIndex = 0;
  for (final s in sorted.reversed) {
    if (s.kind == SleepKind.night) break;
    todayIndex++;
  }

  final range = typicalAwakeMinutes(age);
  final sameIndex = [for (final (i, g) in gaps) if (i == todayIndex) g];
  final all = [for (final (_, g) in gaps) g];
  final own = sameIndex.length >= 3 ? _median(sameIndex) : (all.length >= 3 ? _median(all) : null);
  // The baby's own pattern, kept within a sensible range for the age (a few
  // missed entries can make a gap look far too long or short).
  final low = Duration(minutes: (range.min * 0.75).round());
  final high = Duration(minutes: (range.max * 1.25).round());
  final awake = own == null
      ? Duration(minutes: (range.min + range.max) ~/ 2)
      : (own < low ? low : (own > high ? high : own));
  final napAt = lastWake.add(awake);

  // Bedtime: the median start of night sleep over the last week. Once the
  // next nap would come within 45 minutes of it, the next sleep is bedtime.
  final nightStarts = [
    for (final s in sorted)
      if (s.kind == SleepKind.night) _minutesAfterNoon(s.startedAt),
  ];
  SleepPrediction? result;
  if (nightStarts.length >= 3) {
    final m = _median<num>(nightStarts).toInt();
    // Tonight's bedtime: this evening, or before 4 am the evening just gone.
    final evening = now.hour < 4 ? DateTime(now.year, now.month, now.day - 1) : _day(now);
    final bedtime = DateTime(evening.year, evening.month, evening.day, 12).add(Duration(minutes: m));
    if (!napAt.isBefore(bedtime.subtract(const Duration(minutes: 45)))) {
      result = (kind: SleepPredictionKind.bedtime, from: bedtime.subtract(_halfWindow), to: bedtime.add(_halfWindow), personal: true);
    }
  }
  result ??= (kind: SleepPredictionKind.nap, from: napAt.subtract(_halfWindow), to: napAt.add(_halfWindow), personal: own != null);

  // Long past (e.g. a nap that wasn't logged): no guess is better than a
  // wrong one.
  if (now.isAfter(result.to.add(const Duration(minutes: 60)))) return null;
  return result;
}

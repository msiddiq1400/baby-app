import '../../data/models.dart';

// Gentle "usual pattern" insights for the dashboard, from the baby's own
// recent history. They describe, never prescribe: no age-based targets.

T _median<T extends Comparable<T>>(List<T> values) => (values.toList()..sort())[values.length ~/ 2];

/// Rough guide to the next feed: the median gap between feed starts over the
/// history given (ignoring gaps over 8 hours, e.g. a long night stretch),
/// added to the last feed. Null until there are at least 5 gaps to go on.
({Duration usualGap, DateTime nextAround})? hungerEstimate(List<Feed> feeds) {
  final starts = feeds.map((f) => f.startedAt).toList()..sort();
  final gaps = [
    for (var i = 1; i < starts.length; i++)
      if (starts[i].difference(starts[i - 1]) case final gap when gap.inMinutes >= 30 && gap.inHours < 8) gap,
  ];
  if (gaps.length < 5) return null;
  final usual = _median(gaps);
  return (usualGap: usual, nextAround: starts.last.add(usual));
}

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// Time asleep within one calendar day (a sleep crossing midnight is split).
Duration sleepOnDay(List<Sleep> sleeps, DateTime day, DateTime now) {
  final start = _day(day);
  final end = DateTime(start.year, start.month, start.day + 1);
  var total = Duration.zero;
  for (final s in sleeps) {
    final from = s.startedAt.isBefore(start) ? start : s.startedAt;
    final sleepEnd = s.endedAt ?? now;
    final to = sleepEnd.isAfter(end) ? end : sleepEnd;
    if (to.isAfter(from)) total += to.difference(from);
  }
  return total;
}

/// Median daily sleep over the 7 days before today, counting only days where
/// at least 8 hours were logged (so days the parent didn't log sleep don't
/// drag it down). Null with fewer than 3 such days.
Duration? usualDailySleep(List<Sleep> sleeps, DateTime now) {
  final days = [
    for (var i = 1; i <= 7; i++)
      if (sleepOnDay(sleeps, DateTime(now.year, now.month, now.day - i), now) case final d when d.inHours >= 8) d,
  ];
  return days.length < 3 ? null : _median(days);
}

/// How long since the last sleep ended (null while asleep or with no data),
/// and the median awake time between recent sleeps (null with too little data).
({Duration? awakeFor, Duration? usualAwake}) wakeWindow(List<Sleep> sleeps, DateTime now) {
  final sorted = [...sleeps]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  if (sorted.isEmpty || sorted.last.isOngoing) return (awakeFor: null, usualAwake: null);
  final gaps = [
    for (var i = 1; i < sorted.length; i++)
      if (sorted[i - 1].endedAt case final end?)
        if (sorted[i].startedAt.difference(end) case final gap when gap.inMinutes >= 15 && gap.inHours < 8) gap,
  ];
  return (
    awakeFor: now.difference(sorted.last.endedAt!),
    usualAwake: gaps.length < 3 ? null : _median(gaps),
  );
}

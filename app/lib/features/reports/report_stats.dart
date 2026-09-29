import '../../data/models.dart';
import '../home/insights.dart';

// Numbers for the Reports screen, from the baby's own log. Averages only
// count full days (not today) on which that kind of thing was logged, so a
// day the parent forgot to log doesn't pull the average down.

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// Totals for one calendar day.
class DayStats {
  DayStats(this.day);

  final DateTime day;
  int feeds = 0;
  int bottles = 0;
  int bottleMl = 0;
  int breastfeedsTimed = 0;
  int nursingSeconds = 0;
  int leftSeconds = 0;
  int rightSeconds = 0;
  int wet = 0;
  int dirty = 0;
  int diapers = 0;
  Duration night = Duration.zero;
  Duration naps = Duration.zero;
  int napCount = 0;

  Duration get sleep => night + naps;
}

/// One [DayStats] per day, oldest first: the [days] days up to and
/// including today.
List<DayStats> dailyStats({
  required List<Feed> feeds,
  required List<Diaper> diapers,
  required List<Sleep> sleeps,
  required int days,
  required DateTime now,
}) {
  final today = _day(now);
  final stats = [for (var i = days - 1; i >= 0; i--) DayStats(DateTime(today.year, today.month, today.day - i))];
  DayStats? on(DateTime t) {
    final d = _day(t);
    for (final s in stats) {
      if (s.day == d) return s;
    }
    return null;
  }

  for (final f in feeds) {
    final s = on(f.startedAt);
    if (s == null) continue;
    s.feeds++;
    if (f.type.isBottle && f.amountMl != null) {
      s.bottles++;
      s.bottleMl += f.amountMl!;
    }
    if (f.type == FeedType.breast) {
      final left = f.secondsOn(BreastSide.left, now), right = f.secondsOn(BreastSide.right, now);
      final total = left + right > 0 ? left + right : (f.duration(now)?.inSeconds ?? 0);
      if (total > 0) {
        s.breastfeedsTimed++;
        s.nursingSeconds += total;
        s.leftSeconds += left;
        s.rightSeconds += right;
      }
    }
  }

  for (final d in diapers) {
    final s = on(d.occurredAt);
    if (s == null) continue;
    s.diapers++;
    if (d.isWet) s.wet++;
    if (d.isDirty) s.dirty++;
  }

  for (final s in stats) {
    for (final sleep in sleeps) {
      final part = sleepOnDay([sleep], s.day, now);
      if (part == Duration.zero) continue;
      if (sleep.kind == SleepKind.night) {
        s.night += part;
      } else {
        s.naps += part;
      }
    }
    s.napCount = sleeps.where((x) => x.kind == SleepKind.nap && _day(x.startedAt) == s.day).length;
  }
  return stats;
}

/// Averages and patterns over a period.
class ReportSummary {
  const ReportSummary({
    this.feedsPerDay,
    this.usualGap,
    this.bottleMlPerDay,
    this.mlPerBottle,
    this.nursingPerDay,
    this.nursingPerFeed,
    this.leftShare,
    this.sleepPerDay,
    this.nightPerDay,
    this.napsPerDay,
    this.napTimePerDay,
    this.longestSleep,
    this.bedtime,
    this.wakeUp,
    this.usualAwake,
    this.wetPerDay,
    this.dirtyPerDay,
  });

  final double? feedsPerDay;
  final Duration? usualGap;
  final double? bottleMlPerDay;
  final double? mlPerBottle;
  final Duration? nursingPerDay;
  final Duration? nursingPerFeed;

  /// Share of breastfeeding time on the left (0..1), when per-side times exist.
  final double? leftShare;

  final Duration? sleepPerDay;
  final Duration? nightPerDay;
  final double? napsPerDay;
  final Duration? napTimePerDay;
  final Duration? longestSleep;

  /// Minutes after midnight (may be over 24 h for bedtimes after midnight).
  final int? bedtime;
  final int? wakeUp;
  final Duration? usualAwake;

  final double? wetPerDay;
  final double? dirtyPerDay;
}

double? _avg(Iterable<num> values) {
  final list = values.toList();
  return list.isEmpty ? null : list.fold<num>(0, (a, b) => a + b) / list.length;
}

Duration? _avgDuration(Iterable<Duration> values) =>
    _avg(values.map((d) => d.inSeconds)).let((s) => Duration(seconds: s.round()));

int _median(List<int> values) => (values.toList()..sort())[values.length ~/ 2];

ReportSummary summarize({
  required List<DayStats> days,
  required List<Feed> feeds,
  required List<Sleep> sleeps,
  required DateTime now,
}) {
  final full = days.where((d) => d.day.isBefore(_day(now))).toList();
  final from = days.first.day;
  final periodSleeps = sleeps.where((s) => !(s.endedAt ?? now).isBefore(from)).toList();

  final withFeeds = full.where((d) => d.feeds > 0);
  final withBottles = full.where((d) => d.bottles > 0);
  final withNursing = full.where((d) => d.nursingSeconds > 0);
  // A day counts for sleep once 8 hours were logged (as on the Today screen).
  final withSleep = full.where((d) => d.sleep.inHours >= 8);
  final withDiapers = full.where((d) => d.diapers > 0);

  final bottles = full.fold(0, (a, d) => a + d.bottles);
  final timedFeeds = full.fold(0, (a, d) => a + d.breastfeedsTimed);
  final left = full.fold(0, (a, d) => a + d.leftSeconds), right = full.fold(0, (a, d) => a + d.rightSeconds);

  final ended = periodSleeps.where((s) => s.endedAt != null);
  final nights = ended.where((s) => s.kind == SleepKind.night).toList();
  // Bedtimes are measured from noon so 11 pm and 1 am average sensibly.
  int fromNoon(DateTime t) => (t.hour * 60 + t.minute - 12 * 60) % (24 * 60);

  return ReportSummary(
    feedsPerDay: _avg(withFeeds.map((d) => d.feeds)),
    usualGap: hungerEstimate(feeds.where((f) => !f.startedAt.isBefore(from)).toList())?.usualGap,
    bottleMlPerDay: _avg(withBottles.map((d) => d.bottleMl)),
    mlPerBottle: bottles == 0 ? null : full.fold(0, (a, d) => a + d.bottleMl) / bottles,
    nursingPerDay: _avgDuration(withNursing.map((d) => Duration(seconds: d.nursingSeconds))),
    nursingPerFeed: timedFeeds == 0
        ? null
        : Duration(seconds: (full.fold(0, (a, d) => a + d.nursingSeconds) / timedFeeds).round()),
    leftShare: left + right == 0 ? null : left / (left + right),
    sleepPerDay: _avgDuration(withSleep.map((d) => d.sleep)),
    nightPerDay: _avgDuration(withSleep.map((d) => d.night)),
    napsPerDay: _avg(withSleep.map((d) => d.napCount)),
    napTimePerDay: _avgDuration(withSleep.map((d) => d.naps)),
    longestSleep: ended.isEmpty
        ? null
        : ended.map((s) => s.endedAt!.difference(s.startedAt)).reduce((a, b) => a > b ? a : b),
    bedtime: nights.length < 3 ? null : _median(nights.map((s) => fromNoon(s.startedAt)).toList()) + 12 * 60,
    wakeUp: nights.length < 3 ? null : _median(nights.map((s) => s.endedAt!.hour * 60 + s.endedAt!.minute).toList()),
    usualAwake: wakeWindow(periodSleeps, now).usualAwake,
    wetPerDay: _avg(withDiapers.map((d) => d.wet)),
    dirtyPerDay: _avg(withDiapers.map((d) => d.dirty)),
  );
}

/// Typical total sleep per 24 hours for the baby's age, in hours, and its
/// source: National Sleep Foundation (0-3 months), American Academy of
/// Sleep Medicine (4 months to 5 years, endorsed by the AAP).
({int from, int to})? typicalSleepHours(int ageDays) => switch (ageDays) {
      < 122 => (from: 14, to: 17),
      < 365 => (from: 12, to: 16),
      < 730 => (from: 11, to: 14),
      < 1826 => (from: 10, to: 13),
      _ => null,
    };

/// NHS: breastfed newborns feed 8 to 12 times a day in the first weeks.
bool showNewbornFeeds(int ageDays) => ageDays < 56;

/// NHS: from day 5, at least 6 wet diapers a day; up to 6 weeks, at least 2
/// dirty ones. Signs a breastfed baby is getting enough milk.
bool showWetGuide(int ageDays) => ageDays >= 5 && ageDays < 91;
bool showDirtyGuide(int ageDays) => ageDays >= 5 && ageDays < 42;

extension<T extends Object> on T? {
  R? let<R>(R Function(T) f) => this == null ? null : f(this as T);
}

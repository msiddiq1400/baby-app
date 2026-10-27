import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/topic_icons.dart';
import '../../app/theme.dart';
import '../../core/baby_age.dart';
import '../../core/l10n_lookup.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import 'report_stats.dart';
import '../plans/paywall_screen.dart';
import '../plans/plan.dart';

enum ReportTab { feeds, sleep, diapers }

/// Feeding, sleep and diapers over the last 7 or 30 days, each on its own
/// tab: a bar per day and the averages, with typical ranges for the baby's
/// age where a trusted source gives one.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, required this.baby, this.initialTab = ReportTab.feeds});

  final Baby baby;
  final ReportTab initialTab;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  var _days = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final period = (babyId: widget.baby.id, days: _days);
    final feeds = ref.watch(reportFeedsProvider(period));
    final sleeps = ref.watch(reportSleepsProvider(period));
    final diapers = ref.watch(reportDiapersProvider(period));

    return DefaultTabController(
      length: ReportTab.values.length,
      initialIndex: widget.initialTab.index,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reportsTitle),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(TopicIcons.feed), text: l10n.feeds),
              Tab(icon: const Icon(TopicIcons.sleep), text: l10n.sleep),
              Tab(icon: const Icon(TopicIcons.diaper), text: l10n.diapers),
            ],
          ),
        ),
        body: switch ((feeds, sleeps, diapers)) {
          (AsyncData(value: final f), AsyncData(value: final s), AsyncData(value: final d)) =>
            _Report(
              baby: widget.baby,
              days: _days,
              feeds: f,
              sleeps: s,
              diapers: d,
              onDays: (days) async {
                // Free: 7 days; 30 days is part of Palna Pro.
                if (days > PlanLimits.freeReportDays && !await requirePro(context, ref, l10n.proReasonReports)) return;
                if (mounted) setState(() => _days = days);
              },
            ),
          (AsyncError(), _, _) || (_, AsyncError(), _) || (_, _, AsyncError()) => Center(child: Text(l10n.errorGeneric)),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({
    required this.baby,
    required this.days,
    required this.feeds,
    required this.sleeps,
    required this.diapers,
    required this.onDays,
  });

  final Baby baby;
  final int days;
  final List<Feed> feeds;
  final List<Sleep> sleeps;
  final List<Diaper> diapers;
  final ValueChanged<int> onDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final navy = PalnaColors.chartNavy(theme.brightness);
    final now = DateTime.now();
    final ageDays = now.difference(baby.birthDate).inDays;
    final stats = dailyStats(feeds: feeds, diapers: diapers, sleeps: sleeps, days: days, now: now);
    final sum = summarize(days: stats, feeds: feeds, sleeps: sleeps, now: now);

    String dur(Duration? d) => d == null ? '' : formatDuration(l10n, d);
    String clock(int minutes) =>
        TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60).format(context);
    final sleepRange = typicalSleepHours(ageDays);

    // One tab per kind of entry, each with the period switch, its charts and
    // the notes.
    Widget page(List<Widget> sections) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Center(
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 7, label: Text(l10n.periodDays(7))),
                  ButtonSegment(value: 30, label: Text(l10n.periodDays(30))),
                ],
                selected: {days},
                showSelectedIcon: false,
                onSelectionChanged: (s) => onDays(s.first),
              ),
            ),
            const SizedBox(height: 16),
            ...sections,
            const SizedBox(height: 8),
            Text(l10n.reportAveragesNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(l10n.reportSources, style: theme.textTheme.bodySmall),
          ],
        );

    final sand = PalnaColors.sand;
    final rose = PalnaColors.rose;
    final dayList = [for (final d in stats) d.day];
    final noFeeds = !stats.any((d) => d.feeds > 0);
    final noSleep = !stats.any((d) => d.sleep > Duration.zero);
    final noDiapers = !stats.any((d) => d.diapers > 0);

    return TabBarView(
      children: [
        page([
          _Section(
            title: l10n.chartFeedsPerDay,
            empty: noFeeds,
            chart: _DailyBars(
              days: stats,
              segments: (d) => [(d.feeds.toDouble(), navy)],
              axisLabel: (v) => v.round().toString(),
            ),
            tiles: [
              if (sum.feedsPerDay case final v?)
                _Tile(l10n.feedsPerDay, _number(v), showNewbornFeeds(ageDays) ? l10n.newbornFeedsGuide : null),
              if (sum.nightFeedsPerDay case final v?) _Tile(l10n.nightFeedsPerDay, _number(v)),
              if (sum.usualGap case final v?) _Tile(l10n.timeBetweenFeeds, dur(v)),
              if (sum.nursingPerDay case final v?) _Tile(l10n.nursingPerDay, dur(v)),
              if (sum.nursingPerFeed case final v?) _Tile(l10n.perBreastfeed, dur(v)),
              if (sum.leftShare case final v?)
                _Tile(l10n.sideSplit, '${(v * 100).round()}% · ${100 - (v * 100).round()}%', null, true),
              if (sum.bottleMlPerDay case final v?) _Tile(l10n.bottlePerDay, '${v.round()} ml'),
              if (sum.mlPerBottle case final v?) _Tile(l10n.perBottle, '${v.round()} ml'),
            ],
          ),
          // When in the day and night feeds happen: cluster feeding, night feeds.
          _Section(
            title: l10n.chartFeedTimes,
            empty: noFeeds,
            legend: [(l10n.feedTypeBreast, navy), (l10n.legendBottle, sand), (l10n.legendNight, _nightShade(theme))],
            chart: _DayRhythm(
              days: dayList,
              now: now,
              marks: [
                for (final f in feeds)
                  _Mark(
                    f.startedAt,
                    f.endedAt ?? (f.timerActive ? now : null),
                    f.type == FeedType.breast ? navy : sand,
                  ),
              ],
            ),
          ),
          if (stats.any((d) => d.bottleMl > 0))
            _Section(
              title: l10n.chartBottleMl,
              empty: false,
              chart: _DailyBars(
                days: stats,
                segments: (d) => [(d.bottleMl.toDouble(), sand)],
                axisLabel: (v) => v.round().toString(),
              ),
            ),
        ]),
        page([
          _Section(
            title: l10n.chartSleepPerDay,
            empty: noSleep,
            legend: [(l10n.sleepNight, navy), (l10n.sleepNap, sand)],
            chart: _DailyBars(
              days: stats,
              segments: (d) => [
                (d.night.inMinutes / 60, navy),
                (d.naps.inMinutes / 60, sand),
              ],
              axisLabel: (v) => l10n.hoursShort(v.round()),
              band: sleepRange == null ? null : (sleepRange.from.toDouble(), sleepRange.to.toDouble()),
            ),
            tiles: [
              if (sum.sleepPerDay case final v?)
                _Tile(
                  l10n.sleepPerDay,
                  dur(v),
                  sleepRange == null ? null : l10n.typicalRange(l10n.hoursRange(sleepRange.from, sleepRange.to)),
                ),
              if (sum.nightPerDay case final v? when v > Duration.zero) _Tile(l10n.nightSleepPerDay, dur(v)),
              if (sum.napsPerDay case final v? when v > 0) _Tile(l10n.napsPerDay, _number(v)),
              if (sum.napTimePerDay case final v? when v > Duration.zero) _Tile(l10n.napTimePerDay, dur(v)),
              if (sum.longestSleep case final v?) _Tile(l10n.longestSleep, dur(v)),
              if (sum.usualAwake case final v?) _Tile(l10n.awakeBetweenSleeps, dur(v)),
              if (sum.bedtime case final v?) _Tile(l10n.usualBedtime, clock(v)),
              if (sum.wakeUp case final v?) _Tile(l10n.usualWakeUp, clock(v)),
            ],
          ),
          // The classic sleep log: when the baby slept, day by day.
          _Section(
            title: l10n.chartSleepPattern,
            empty: noSleep,
            legend: [(l10n.sleepNight, navy), (l10n.sleepNap, sand)],
            chart: _DayRhythm(
              days: dayList,
              now: now,
              marks: [
                for (final x in sleeps) _Mark(x.startedAt, x.endedAt ?? now, x.kind == SleepKind.night ? navy : sand),
              ],
            ),
          ),
          // Progress towards sleeping through the night.
          _Section(
            title: l10n.chartLongestSleep,
            empty: noSleep,
            chart: _DailyBars(
              days: stats,
              segments: (d) => [(d.longest.inMinutes / 60, navy)],
              axisLabel: (v) => l10n.hoursShort(v.round()),
            ),
          ),
        ]),
        page([
          _Section(
            title: l10n.chartDiapersPerDay,
            empty: noDiapers,
            legend: [(l10n.diaperWet, navy), (l10n.diaperDirty, rose)],
            chart: _DailyBars(
              days: stats,
              // A diaper that's both wet and dirty counts once in the bar.
              segments: (d) => [
                ((d.diapers - d.dirty).toDouble(), navy),
                (d.dirty.toDouble(), rose),
              ],
              axisLabel: (v) => v.round().toString(),
            ),
            tiles: [
              if (sum.wetPerDay case final v?) _Tile(l10n.wetPerDay, _number(v), showWetGuide(ageDays) ? l10n.wetGuide : null),
              if (sum.dirtyPerDay case final v?)
                _Tile(l10n.dirtyPerDay, _number(v), showDirtyGuide(ageDays) ? l10n.dirtyGuide : null),
            ],
          ),
          // Usual poop times, and long stretches without a wet diaper.
          _Section(
            title: l10n.chartDiaperTimes,
            empty: noDiapers,
            legend: [(l10n.diaperWet, navy), (l10n.diaperDirty, rose)],
            chart: _DayRhythm(
              days: dayList,
              now: now,
              marks: [for (final x in diapers) _Mark(x.occurredAt, null, x.isDirty ? rose : navy)],
            ),
          ),
        ]),
      ],
    );
  }
}

/// "7", "6.5": one decimal, without a trailing ".0".
String _number(double v) {
  final r = (v * 10).round() / 10;
  return r == r.roundToDouble() ? r.round().toString() : r.toStringAsFixed(1);
}

class _Tile {
  const _Tile(this.label, this.value, [this.note, this.leftToRight = false]);

  final String label;
  final String value;
  final String? note;

  /// For values whose order matters in every language (left · right).
  final bool leftToRight;
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.empty,
    required this.chart,
    this.tiles = const [],
    this.legend = const [],
  });

  final String title;
  final bool empty;
  final Widget chart;
  final List<_Tile> tiles;
  final List<(String, Color)> legend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            if (legend.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 2,
                children: [
                  for (final (label, color) in legend)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(label, style: theme.textTheme.bodySmall),
                      ],
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (empty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.reportNotEnough, textAlign: TextAlign.center),
              )
            else ...[
              chart,
              if (tiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [for (final t in tiles) SizedBox(width: width, child: _StatTile(tile: t))],
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tile.label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            tile.value,
            style: theme.textTheme.titleLarge,
            textDirection: tile.leftToRight ? TextDirection.ltr : null,
          ),
          if (tile.note case final note?) ...[
            const SizedBox(height: 4),
            Text(note, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          ],
        ],
      ),
    );
  }
}

/// One stacked bar per day, oldest on the left. [band] shades a typical
/// range behind the bars.
class _DailyBars extends StatelessWidget {
  const _DailyBars({required this.days, required this.segments, required this.axisLabel, this.band});

  final List<DayStats> days;
  final List<(double, Color)> Function(DayStats) segments;
  final String Function(double) axisLabel;
  final (double, double)? band;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = [for (final d in days) segments(d).fold(0.0, (a, s) => a + s.$1)];
    final top = math.max(totals.fold(0.0, math.max), band?.$2 ?? 0);
    final maxY = top <= 0 ? 4.0 : (top * 1.15).ceilToDouble();
    final interval = maxY <= 6 ? 1.0 : (maxY / 4).ceilToDouble();
    final labelEvery = days.length <= 7 ? 1 : 5;
    final barWidth = days.length <= 7 ? 18.0 : 6.0;
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11);

    // Time runs left to right in every language.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 170,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            barTouchData: BarTouchData(enabled: false),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (_) => FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 0.6),
            ),
            rangeAnnotations: band == null
                ? null
                : RangeAnnotations(
                    horizontalRangeAnnotations: [
                      HorizontalRangeAnnotation(
                        y1: band!.$1,
                        y2: band!.$2,
                        color: PalnaColors.sand.withValues(alpha: 0.28),
                      ),
                    ],
                  ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  interval: interval,
                  getTitlesWidget: (v, meta) =>
                      v == meta.max ? const SizedBox.shrink() : Text(axisLabel(v), style: muted),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, meta) {
                    final i = v.round();
                    final fromEnd = days.length - 1 - i;
                    if (i < 0 || i >= days.length || fromEnd % labelEvery != 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${days[i].day.day}', style: muted),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (final (i, d) in days.indexed)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: totals[i],
                      color: Colors.transparent,
                      width: barWidth,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      rodStackItems: [
                        for (final (from, (value, color)) in _stack(segments(d))) BarChartRodStackItem(from, from + value, color),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Each segment with where it starts.
  static List<(double, (double, Color))> _stack(List<(double, Color)> segments) {
    final out = <(double, (double, Color))>[];
    var from = 0.0;
    for (final s in segments) {
      out.add((from, s));
      from += s.$1;
    }
    return out;
  }
}

/// Shading for night hours on the 24-hour charts.
Color _nightShade(ThemeData theme) =>
    PalnaColors.chartNavy(theme.brightness).withValues(alpha: theme.brightness == Brightness.dark ? 0.22 : 0.10);

/// Something on the 24-hour chart: a block from [start] to [end], or a short
/// tick when there's no [end] (a diaper, a bottle).
class _Mark {
  const _Mark(this.start, this.end, this.color);

  final DateTime start;
  final DateTime? end;
  final Color color;
}

/// Each day is a row across 24 hours (midnight to midnight, left to right,
/// in every language), oldest at the top, with the night hours shaded.
/// Shows when things happen, which daily totals can't.
class _DayRhythm extends StatelessWidget {
  const _DayRhythm({required this.days, required this.marks, required this.now});

  final List<DateTime> days;
  final List<_Mark> marks;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final few = days.length <= 7;
    final rowHeight = few ? 18.0 : 6.0;
    final rowGap = few ? 6.0 : 2.0;
    final hourFormat = DateFormat.j(dateLocale(l10n));
    final labelEvery = few ? 1 : 5;
    return SizedBox(
      height: days.length * (rowHeight + rowGap) + 20,
      child: CustomPaint(
        size: Size.infinite,
        painter: _RhythmPainter(
          days: days,
          marks: marks,
          rowHeight: rowHeight,
          rowGap: rowGap,
          dayLabels: [
            for (final (i, d) in days.indexed) (days.length - 1 - i) % labelEvery == 0 ? '${d.day}' : null,
          ],
          hourLabels: [for (final h in const [0, 6, 12, 18]) hourFormat.format(DateTime(2000, 1, 1, h))],
          labelStyle: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
          rowColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          nightColor: _nightShade(theme),
          gridColor: theme.colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _RhythmPainter extends CustomPainter {
  _RhythmPainter({
    required this.days,
    required this.marks,
    required this.rowHeight,
    required this.rowGap,
    required this.dayLabels,
    required this.hourLabels,
    required this.labelStyle,
    required this.rowColor,
    required this.nightColor,
    required this.gridColor,
  });

  final List<DateTime> days;
  final List<_Mark> marks;
  final double rowHeight;
  final double rowGap;
  final List<String?> dayLabels;
  final List<String> hourLabels;
  final TextStyle labelStyle;
  final Color rowColor;
  final Color nightColor;
  final Color gridColor;

  static const _gutter = 26.0;

  void _text(Canvas canvas, String text, Offset at, {double alignX = 0}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width * alignX, painter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - _gutter;
    double x(double hours) => _gutter + width * hours / 24;
    final radius = Radius.circular(rowHeight > 10 ? 4 : 2);
    final fill = Paint();

    for (final (i, day) in days.indexed) {
      final top = i * (rowHeight + rowGap);
      final row = Rect.fromLTRB(x(0), top, x(24), top + rowHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(row, radius), fill..color = rowColor);
      // Night: 7 pm to 6 am.
      fill.color = nightColor;
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTRB(x(0), top, x(6), top + rowHeight), topLeft: radius, bottomLeft: radius),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTRB(x(19), top, x(24), top + rowHeight), topRight: radius, bottomRight: radius),
        fill,
      );
      if (dayLabels[i] case final label?) _text(canvas, label, Offset(0, top + rowHeight / 2));

      final dayEnd = DateTime(day.year, day.month, day.day + 1);
      double hoursInto(DateTime t) => t.difference(day).inMinutes / 60;
      for (final m in marks) {
        fill.color = m.color;
        final end = m.end;
        if (end == null) {
          // A tick, about 3 px wide.
          if (m.start.isBefore(day) || !m.start.isBefore(dayEnd)) continue;
          final cx = x(hoursInto(m.start));
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTRB(cx - 1.5, top, cx + 1.5, top + rowHeight), const Radius.circular(1.5)),
            fill,
          );
        } else {
          // The part of a block that falls on this day (a night sleep spans two rows).
          final from = m.start.isBefore(day) ? day : m.start;
          final to = end.isAfter(dayEnd) ? dayEnd : end;
          if (!to.isAfter(from)) continue;
          final left = x(hoursInto(from));
          final right = math.max(x(hoursInto(to)), left + 3);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(left, top, right, top + rowHeight), radius), fill);
        }
      }
    }

    // Hour lines and labels: midnight, 6 am, noon, 6 pm.
    final bottom = days.length * (rowHeight + rowGap) - rowGap;
    final line = Paint()
      ..color = gridColor
      ..strokeWidth = 0.6;
    for (final (i, h) in const [0, 6, 12, 18].indexed) {
      if (h > 0) canvas.drawLine(Offset(x(h.toDouble()), 0), Offset(x(h.toDouble()), bottom), line);
      _text(canvas, hourLabels[i], Offset(x(h.toDouble()), bottom + 11), alignX: h == 0 ? 0 : 0.5);
    }
  }

  @override
  bool shouldRepaint(_RhythmPainter old) => true;
}

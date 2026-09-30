import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/baby_age.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import 'report_stats.dart';

/// Feeding, sleep and diapers over the last 7 or 30 days: a bar per day and
/// the averages, with typical ranges for the baby's age where a trusted
/// source gives one.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, required this.baby});

  final Baby baby;

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: switch ((feeds, sleeps, diapers)) {
        (AsyncData(value: final f), AsyncData(value: final s), AsyncData(value: final d)) =>
          _Report(baby: widget.baby, days: _days, feeds: f, sleeps: s, diapers: d, onDays: (d) => setState(() => _days = d)),
        (AsyncError(), _, _) || (_, AsyncError(), _) || (_, _, AsyncError()) => Center(child: Text(l10n.errorGeneric)),
        _ => const Center(child: CircularProgressIndicator()),
      },
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
        _Section(
          icon: Icons.local_drink_outlined,
          title: l10n.feeds,
          empty: !stats.any((d) => d.feeds > 0),
          chart: _DailyBars(
            days: stats,
            segments: (d) => [(d.feeds.toDouble(), navy)],
            axisLabel: (v) => v.round().toString(),
          ),
          tiles: [
            if (sum.feedsPerDay case final v?)
              _Tile(l10n.feedsPerDay, _number(v), showNewbornFeeds(ageDays) ? l10n.newbornFeedsGuide : null),
            if (sum.usualGap case final v?) _Tile(l10n.timeBetweenFeeds, dur(v)),
            if (sum.nursingPerDay case final v?) _Tile(l10n.nursingPerDay, dur(v)),
            if (sum.nursingPerFeed case final v?) _Tile(l10n.perBreastfeed, dur(v)),
            if (sum.leftShare case final v?)
              _Tile(l10n.sideSplit, '${(v * 100).round()}% · ${100 - (v * 100).round()}%', null, true),
            if (sum.bottleMlPerDay case final v?) _Tile(l10n.bottlePerDay, '${v.round()} ml'),
            if (sum.mlPerBottle case final v?) _Tile(l10n.perBottle, '${v.round()} ml'),
          ],
        ),
        _Section(
          icon: Icons.bedtime_outlined,
          title: l10n.sleep,
          empty: !stats.any((d) => d.sleep > Duration.zero),
          legend: [(l10n.sleepNight, navy), (l10n.sleepNap, PalnaColors.sand)],
          chart: _DailyBars(
            days: stats,
            segments: (d) => [
              (d.night.inMinutes / 60, navy),
              (d.naps.inMinutes / 60, PalnaColors.sand),
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
        _Section(
          icon: Icons.baby_changing_station_outlined,
          title: l10n.diapers,
          empty: !stats.any((d) => d.diapers > 0),
          legend: [(l10n.diaperWet, navy), (l10n.diaperDirty, PalnaColors.rose)],
          chart: _DailyBars(
            days: stats,
            // A diaper that's both wet and dirty counts once in the bar.
            segments: (d) => [
              ((d.diapers - d.dirty).toDouble(), navy),
              (d.dirty.toDouble(), PalnaColors.rose),
            ],
            axisLabel: (v) => v.round().toString(),
          ),
          tiles: [
            if (sum.wetPerDay case final v?) _Tile(l10n.wetPerDay, _number(v), showWetGuide(ageDays) ? l10n.wetGuide : null),
            if (sum.dirtyPerDay case final v?)
              _Tile(l10n.dirtyPerDay, _number(v), showDirtyGuide(ageDays) ? l10n.dirtyGuide : null),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.reportAveragesNote, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(l10n.reportSources, style: theme.textTheme.bodySmall),
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
    required this.icon,
    required this.title,
    required this.empty,
    required this.chart,
    required this.tiles,
    this.legend = const [],
  });

  final IconData icon;
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
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
                for (final (label, color) in legend) ...[
                  const SizedBox(width: 10),
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(label, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
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

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/who_growth.dart';
import 'growth_points.dart';

/// WHO percentile curves (grey, when the sex is known) with the baby's
/// measurements on top. Age in months along the bottom.
class GrowthChart extends StatelessWidget {
  const GrowthChart({
    super.key,
    required this.who,
    required this.sex,
    required this.metric,
    required this.points,
    required this.ageNowMonths,
  });

  final WhoGrowth who;
  final String? sex;
  final GrowthMetric metric;
  final List<GrowthPoint> points;
  final double ageNowMonths;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Show a little past the baby's current age, at least 6 months, at most 24.
    final lastMonths = points.isEmpty ? 0.0 : points.last.months;
    final maxX = (math.max(ageNowMonths, lastMonths) + 1).ceilToDouble().clamp(6.0, 24.0);

    final curves = sex == null
        ? <LineChartBarData>[]
        : [
            for (final (label, z) in growthCurves)
              LineChartBarData(
                spots: [
                  for (var x = 0.0; x <= maxX + 0.001; x += 0.25)
                    FlSpot(x, who.valueAtZ(sex!, metric, x, z)),
                ],
                isCurved: true,
                barWidth: label == '50th' ? 2 : 1,
                color: colors.outline.withValues(alpha: label == '50th' ? 0.9 : 0.5),
                dashArray: label == '50th' ? null : [4, 4],
                dotData: const FlDotData(show: false),
              ),
          ];

    final babyLine = LineChartBarData(
      spots: [for (final p in points) FlSpot(p.months.clamp(0, maxX), p.value)],
      barWidth: 3,
      color: colors.primary,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) =>
            FlDotCirclePainter(radius: 4, color: colors.primary, strokeWidth: 2, strokeColor: colors.surface),
      ),
    );

    final allValues = [
      for (final c in curves) ...c.spots.map((s) => s.y),
      ...babyLine.spots.map((s) => s.y),
    ];
    final minY = allValues.isEmpty ? 0.0 : allValues.reduce(math.min);
    final maxY = allValues.isEmpty ? 10.0 : allValues.reduce(math.max);
    final pad = (maxY - minY) * 0.05 + 0.1;

    // Charts read left to right in every language.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AspectRatio(
        aspectRatio: 1.3,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: (minY - pad).floorToDouble().clamp(0, double.infinity),
            maxY: (maxY + pad).ceilToDouble(),
            lineBarsData: [...curves, if (points.isNotEmpty) babyLine],
            lineTouchData: const LineTouchData(enabled: false),
            gridData: FlGridData(
              drawVerticalLine: true,
              verticalInterval: maxX > 12 ? 3 : 1,
              getDrawingHorizontalLine: (_) => FlLine(color: colors.outlineVariant.withValues(alpha: 0.4), strokeWidth: 0.5),
              getDrawingVerticalLine: (_) => FlLine(color: colors.outlineVariant.withValues(alpha: 0.4), strokeWidth: 0.5),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxX > 12 ? 3 : 1,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) =>
                      SideTitleWidget(meta: meta, child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 11))),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) =>
                      SideTitleWidget(meta: meta, child: Text(meta.formattedValue, style: const TextStyle(fontSize: 11))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

enum GrowthMetric { weight, length, head }

/// WHO Child Growth Standards (birth to 24 months) using the LMS method:
/// each month has L (skew), M (median) and S (spread), from which any
/// measurement converts to a z-score and percentile.
class WhoGrowth {
  WhoGrowth._(this._tables);

  /// Tables per sex ('male' / 'female') and metric; row index = month 0..24.
  final Map<String, Map<GrowthMetric, List<_Lms>>> _tables;

  static const maxMonths = 24;

  /// Average month length used by WHO to convert days to months.
  static const daysPerMonth = 30.4375;

  static Future<WhoGrowth> load() async {
    final json = jsonDecode(await rootBundle.loadString('assets/who_growth.json')) as Map<String, dynamic>;
    return WhoGrowth.fromJson(json);
  }

  factory WhoGrowth.fromJson(Map<String, dynamic> json) {
    Map<GrowthMetric, List<_Lms>> tablesFor(String sex) => {
          for (final metric in GrowthMetric.values)
            metric: [
              for (final row in json[sex][metric.name] as List)
                _Lms((row[1] as num).toDouble(), (row[2] as num).toDouble(), (row[3] as num).toDouble()),
            ],
        };
    return WhoGrowth._({'male': tablesFor('male'), 'female': tablesFor('female')});
  }

  static double ageInMonths(DateTime birth, DateTime on) => on.difference(birth).inDays / daysPerMonth;

  /// LMS for a (fractional) age, linearly interpolated between months.
  _Lms _lmsAt(String sex, GrowthMetric metric, double months) {
    final table = _tables[sex]![metric]!;
    final m = months.clamp(0, maxMonths.toDouble());
    final lower = m.floor();
    if (lower >= maxMonths) return table[maxMonths];
    final t = m - lower;
    final a = table[lower], b = table[lower + 1];
    return _Lms(a.l + (b.l - a.l) * t, a.m + (b.m - a.m) * t, a.s + (b.s - a.s) * t);
  }

  double zScore(String sex, GrowthMetric metric, double months, double value) {
    final lms = _lmsAt(sex, metric, months);
    return lms.l == 0
        ? math.log(value / lms.m) / lms.s
        : (math.pow(value / lms.m, lms.l) - 1) / (lms.l * lms.s);
  }

  double percentile(String sex, GrowthMetric metric, double months, double value) =>
      _normalCdf(zScore(sex, metric, months, value)) * 100;

  /// The measurement that sits at [z] for this age; used to draw curves.
  double valueAtZ(String sex, GrowthMetric metric, double months, double z) {
    final lms = _lmsAt(sex, metric, months);
    return lms.l == 0
        ? lms.m * math.exp(lms.s * z)
        : lms.m * math.pow(1 + lms.l * lms.s * z, 1 / lms.l).toDouble();
  }
}

class _Lms {
  const _Lms(this.l, this.m, this.s);
  final double l, m, s;
}

/// Percentile curves drawn on the chart, as (label, z-score).
const growthCurves = [
  ('3rd', -1.8808),
  ('15th', -1.0364),
  ('50th', 0.0),
  ('85th', 1.0364),
  ('97th', 1.8808),
];

/// Standard normal cumulative distribution (Abramowitz & Stegun 7.1.26,
/// accurate to about 1e-7, far finer than a percentile needs).
double _normalCdf(double z) {
  final x = z.abs() / math.sqrt2;
  final t = 1 / (1 + 0.3275911 * x);
  final erf = 1 -
      (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) *
          t *
          math.exp(-x * x);
  return z >= 0 ? (1 + erf) / 2 : (1 - erf) / 2;
}

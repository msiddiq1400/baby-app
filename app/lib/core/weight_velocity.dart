import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/models.dart';
import 'who_growth.dart';

/// How fast the baby gained weight over about the last month, compared with
/// the WHO growth velocity standard (1-month weight increments, birth to 12
/// months).
enum GainBand { slow, usual, fast }

class WeightGainCheck {
  const WeightGainCheck({
    required this.gainPerMonthG,
    required this.daysApart,
    required this.p5,
    required this.p50,
    required this.p95,
  });

  /// Gain between the two weights, scaled to one month.
  final int gainPerMonthG;
  final int daysApart;

  /// WHO 5th, 50th and 95th percentiles of gain for this age (g per month).
  final int p5;
  final int p50;
  final int p95;

  GainBand get band => gainPerMonthG < p5 ? GainBand.slow : (gainPerMonthG > p95 ? GainBand.fast : GainBand.usual);
}

class WeightVelocity {
  WeightVelocity._(this._tables);

  /// Per sex ('male' / 'female'): the 12 WHO intervals in order (0–4 weeks,
  /// 4 weeks–2 months, 2–3 months ... 11–12 months), each (p5, p50, p95).
  final Map<String, List<(int, int, int)>> _tables;

  /// Weights closer together than this say little about a month's growth;
  /// further apart, the gain is no longer "the last month".
  static const minDays = 21;
  static const maxDays = 45;

  static Future<WeightVelocity> load() async =>
      WeightVelocity.fromJson(jsonDecode(await rootBundle.loadString('assets/who_weight_velocity.json')));

  factory WeightVelocity.fromJson(Map<String, dynamic> json) {
    List<(int, int, int)> rows(String key) => [
          for (final r in (json[key] as List).cast<Map<String, dynamic>>())
            ((r['p5'] as num).toInt(), (r['p50'] as num).toInt(), (r['p95'] as num).toInt()),
        ];
    return WeightVelocity._({'male': rows('boys'), 'female': rows('girls')});
  }

  /// Middle of each WHO interval, in days of age.
  static final _intervalMids = [
    14.0, // 0–4 weeks
    (28 + 2 * WhoGrowth.daysPerMonth) / 2, // 4 weeks–2 months
    for (var m = 2; m < 12; m++) (m + 0.5) * WhoGrowth.daysPerMonth,
  ];

  /// Compares the latest weight with the one about a month before it; null
  /// without the baby's sex, without two weights 3 to 6 weeks apart, or
  /// after 12 months (where the WHO table ends).
  WeightGainCheck? check(Baby baby, List<GrowthMeasurement> measurements) {
    final table = _tables[baby.sex];
    if (table == null) return null;
    // The birth weight counts: WHO's first interval is birth to 4 weeks.
    final weights = [
      if (baby.birthWeightG case final g?) GrowthMeasurement(id: 'birth', measuredOn: baby.birthDate, weightG: g),
      for (final m in measurements)
        if (m.weightG != null) m,
    ]
      ..sort((a, b) => a.measuredOn.compareTo(b.measuredOn));
    if (weights.length < 2) return null;
    final latest = weights.last;

    GrowthMeasurement? earlier;
    var bestDistance = double.infinity;
    for (final m in weights) {
      final days = latest.measuredOn.difference(m.measuredOn).inDays;
      if (days < minDays || days > maxDays) continue;
      final distance = (days - WhoGrowth.daysPerMonth).abs();
      if (distance < bestDistance) (earlier, bestDistance) = (m, distance);
    }
    if (earlier == null) return null;

    final days = latest.measuredOn.difference(earlier.measuredOn).inDays;
    final midAge = earlier.measuredOn.difference(baby.birthDate).inDays + days / 2;
    if (midAge > 12 * WhoGrowth.daysPerMonth) return null;
    var index = 0;
    for (var i = 1; i < _intervalMids.length; i++) {
      if ((_intervalMids[i] - midAge).abs() < (_intervalMids[index] - midAge).abs()) index = i;
    }
    final (p5, p50, p95) = table[index];
    return WeightGainCheck(
      gainPerMonthG: ((latest.weightG! - earlier.weightG!) * WhoGrowth.daysPerMonth / days).round(),
      daysApart: days,
      p5: p5,
      p50: p50,
      p95: p95,
    );
  }
}

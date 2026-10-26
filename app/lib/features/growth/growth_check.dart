import '../../core/weight_velocity.dart';
import '../../core/who_growth.dart';
import '../../data/models.dart';
import 'growth_points.dart';

/// How much a finding matters: worth a mention at the next check-up, or a
/// reason to talk to a doctor now.
enum GrowthConcern { none, mention, doctor }

enum GrowthFlagKind {
  /// Below the 3rd percentile (under the lowest grey curve).
  belowRange,

  /// Above the 97th percentile (over the highest grey curve).
  aboveRange,

  /// Dropped across two or more of the grey curves.
  fallingAcross,

  /// Climbed across two or more of the grey curves.
  risingAcross,

  /// Still under the birth weight after the first two weeks.
  belowBirthWeight,

  /// Gained less weight over the last month than 95 in 100 babies.
  slowGain,
}

class GrowthFlag {
  const GrowthFlag(this.metric, this.kind, this.concern);

  final GrowthMetric metric;
  final GrowthFlagKind kind;
  final GrowthConcern concern;
}

class GrowthCheckResult {
  const GrowthCheckResult(this.flags, {required this.hasEnoughData});

  /// Most serious first.
  final List<GrowthFlag> flags;

  /// False when there's nothing to judge yet (no sex, or no measurement
  /// after birth): then the screen shows no verdict at all.
  final bool hasEnoughData;

  GrowthConcern get concern => flags.isEmpty ? GrowthConcern.none : flags.first.concern;
}

/// The grey curves on the chart (3rd, 15th, 50th, 85th, 97th percentile).
final _curveZs = [for (final (_, z) in growthCurves) z];

/// Checks the baby's measurements against the WHO standards, the way a
/// doctor reads a growth chart: a value outside the grey curves, a line
/// crossing two curves, not back to birth weight by two weeks, slow weight
/// gain. Uses only birth to 24 months (where the WHO curves end).
///
/// Thresholds (WHO Child Growth Standards; NHS/RCPCH growth chart guidance):
/// - under the 3rd percentile, any measure: talk to a doctor;
/// - over the 97th: head, talk to a doctor; weight or length, mention it;
/// - falling across two curves: talk to a doctor; rising across two:
///   head, talk to a doctor; weight or length, mention it;
/// - under birth weight after 14 days: talk to a doctor;
/// - weight gain under WHO's 5th centile for the last month: mention it.
GrowthCheckResult checkGrowth({
  required Baby baby,
  required List<GrowthMeasurement> measurements,
  required WhoGrowth who,
  WeightGainCheck? weightGain,
}) {
  final flags = <GrowthFlag>[];
  final sex = baby.sex;
  var enough = false;

  for (final metric in GrowthMetric.values) {
    final points = growthPoints(baby, measurements, metric);
    final measured = [for (final p in points) if (p.measurement != null && p.months <= WhoGrowth.maxMonths) p];
    if (measured.isEmpty) continue;
    final latest = measured.last;

    if (metric == GrowthMetric.weight && baby.birthWeightG != null) {
      enough = true;
      final days = latest.date.difference(baby.birthDate).inDays;
      if (days > 14 && latest.value * 1000 < baby.birthWeightG!) {
        flags.add(const GrowthFlag(GrowthMetric.weight, GrowthFlagKind.belowBirthWeight, GrowthConcern.doctor));
      }
    }
    if (sex == null) continue;
    enough = true;

    final z = who.zScore(sex, metric, latest.months, latest.value);
    if (z < _curveZs.first) {
      flags.add(GrowthFlag(metric, GrowthFlagKind.belowRange, GrowthConcern.doctor));
    } else if (z > _curveZs.last) {
      flags.add(GrowthFlag(
        metric,
        GrowthFlagKind.aboveRange,
        metric == GrowthMetric.head ? GrowthConcern.doctor : GrowthConcern.mention,
      ));
    }

    // Crossing curves: the latest value against earlier measurements from
    // the last six months, at least three weeks before it (the birth value
    // is left out: newborns often settle onto a new curve in the first
    // weeks, and birth measurements are rough).
    var crossed = 0;
    for (final earlier in measured) {
      final gap = latest.date.difference(earlier.date).inDays;
      if (gap < 21 || gap > 183) continue;
      final before = who.zScore(sex, metric, earlier.months, earlier.value);
      final lines = _curveZs.where((c) => (before < c && c <= z) || (z <= c && c < before)).length;
      final signed = z < before ? -lines : lines;
      if (signed.abs() > crossed.abs()) crossed = signed;
    }
    if (crossed <= -2) {
      flags.add(GrowthFlag(metric, GrowthFlagKind.fallingAcross, GrowthConcern.doctor));
    } else if (crossed >= 2) {
      flags.add(GrowthFlag(
        metric,
        GrowthFlagKind.risingAcross,
        metric == GrowthMetric.head ? GrowthConcern.doctor : GrowthConcern.mention,
      ));
    }
  }

  if (weightGain?.band == GainBand.slow) {
    flags.add(const GrowthFlag(GrowthMetric.weight, GrowthFlagKind.slowGain, GrowthConcern.mention));
  }

  flags.sort((a, b) => b.concern.index.compareTo(a.concern.index));
  return GrowthCheckResult(flags, hasEnoughData: enough);
}

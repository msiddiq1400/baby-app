import '../../core/who_growth.dart';
import '../../data/models.dart';

/// One plotted value: when it was measured and the value in chart units
/// (kg for weight, cm for length and head).
class GrowthPoint {
  const GrowthPoint({required this.date, required this.value, required this.months, this.measurement});

  final DateTime date;
  final double value;

  /// Age in months at the time of measuring.
  final double months;

  /// Null for the birth values from the baby's profile.
  final GrowthMeasurement? measurement;
}

/// The baby's values for one metric, oldest first, starting with the birth
/// values from the profile when they were entered.
List<GrowthPoint> growthPoints(Baby baby, List<GrowthMeasurement> measurements, GrowthMetric metric) {
  double? birthValue = switch (metric) {
    GrowthMetric.weight => baby.birthWeightG == null ? null : baby.birthWeightG! / 1000,
    GrowthMetric.length => baby.birthLengthMm == null ? null : baby.birthLengthMm! / 10,
    GrowthMetric.head => baby.birthHeadMm == null ? null : baby.birthHeadMm! / 10,
  };

  return [
    if (birthValue != null) GrowthPoint(date: baby.birthDate, value: birthValue, months: 0),
    for (final m in measurements)
      if (_value(m, metric) case final value?)
        GrowthPoint(
          date: m.measuredOn,
          value: value,
          months: WhoGrowth.ageInMonths(baby.birthDate, m.measuredOn),
          measurement: m,
        ),
  ];
}

double? _value(GrowthMeasurement m, GrowthMetric metric) => switch (metric) {
      GrowthMetric.weight => m.weightG == null ? null : m.weightG! / 1000,
      GrowthMetric.length => m.lengthMm == null ? null : m.lengthMm! / 10,
      GrowthMetric.head => m.headMm == null ? null : m.headMm! / 10,
    };

/// "7.25 kg", "65.5 cm".
String formatGrowthValue(GrowthMetric metric, double value) =>
    metric == GrowthMetric.weight ? '${value.toStringAsFixed(2)} kg' : '${value.toStringAsFixed(1)} cm';

/// "+450 g", "-0.5 cm".
String formatGrowthChange(GrowthMetric metric, double change) {
  final sign = change >= 0 ? '+' : '-';
  return metric == GrowthMetric.weight
      ? '$sign${(change.abs() * 1000).round()} g'
      : '$sign${change.abs().toStringAsFixed(1)} cm';
}

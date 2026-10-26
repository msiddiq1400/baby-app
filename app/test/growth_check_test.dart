// The growth check on the Growth tab: which measurements make the app say
// "talk to your doctor", "mention it at the next check-up" or "growing as
// expected". Values are built from the WHO curves themselves (a value at a
// given z-score), so the tests follow the thresholds, not hand-picked kilos.

import 'dart:convert';
import 'dart:io';

import 'package:baby_app/core/weight_velocity.dart';
import 'package:baby_app/core/who_growth.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/growth/growth_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final who = WhoGrowth.fromJson(jsonDecode(File('assets/who_growth.json').readAsStringSync()) as Map<String, dynamic>);
  final velocity = WeightVelocity.fromJson(jsonDecode(File('assets/who_weight_velocity.json').readAsStringSync()));
  final birth = DateTime(2026, 1, 1);

  Baby baby({String? sex = 'female', int? birthWeightG = 3200}) =>
      Baby(id: 'b', familyId: 'f', name: 'Aisha', birthDate: birth, sex: sex, birthWeightG: birthWeightG);

  double months(int day) => WhoGrowth.ageInMonths(birth, birth.add(Duration(days: day)));

  /// A measurement on [day] with each given measure at that z-score.
  GrowthMeasurement at(int day, {double? weightZ, double? lengthZ, double? headZ, String sex = 'female'}) {
    int? value(GrowthMetric m, double? z, int scale) =>
        z == null ? null : (who.valueAtZ(sex, m, months(day), z) * scale).round();
    return GrowthMeasurement(
      id: 'm$day',
      measuredOn: birth.add(Duration(days: day)),
      weightG: value(GrowthMetric.weight, weightZ, 1000),
      lengthMm: value(GrowthMetric.length, lengthZ, 10),
      headMm: value(GrowthMetric.head, headZ, 10),
    );
  }

  GrowthCheckResult check(Baby b, List<GrowthMeasurement> ms) =>
      checkGrowth(baby: b, measurements: ms, who: who, weightGain: velocity.check(b, ms));

  Iterable<(GrowthMetric, GrowthFlagKind)> kinds(GrowthCheckResult r) => r.flags.map((f) => (f.metric, f.kind));

  test('no verdict without a measurement after birth', () {
    final r = check(baby(), const []);
    expect(r.hasEnoughData, isFalse);
    expect(r.flags, isEmpty);
  });

  test('values near the middle: growing as expected', () {
    final r = check(baby(), [at(60, weightZ: 0.2, lengthZ: -0.3, headZ: 0.1), at(120, weightZ: 0.3, lengthZ: -0.2, headZ: 0)]);
    expect(r.hasEnoughData, isTrue);
    expect(r.concern, GrowthConcern.none);
  });

  group('outside the grey curves', () {
    for (final metric in GrowthMetric.values) {
      test('${metric.name} under the 3rd percentile: talk to a doctor', () {
        final m = switch (metric) {
          GrowthMetric.weight => at(120, weightZ: -2.2),
          GrowthMetric.length => at(120, lengthZ: -2.2),
          GrowthMetric.head => at(120, headZ: -2.2),
        };
        final r = check(baby(), [m]);
        expect(r.concern, GrowthConcern.doctor);
        expect(kinds(r), contains((metric, GrowthFlagKind.belowRange)));
      });
    }

    test('head over the 97th percentile: talk to a doctor', () {
      final r = check(baby(), [at(120, headZ: 2.2)]);
      expect(r.concern, GrowthConcern.doctor);
      expect(kinds(r), contains((GrowthMetric.head, GrowthFlagKind.aboveRange)));
    });

    test('weight or length over the 97th: mention it, not alarming', () {
      final r = check(baby(), [at(120, weightZ: 2.2, lengthZ: 2.2)]);
      expect(r.concern, GrowthConcern.mention);
      expect(kinds(r), containsAll([(GrowthMetric.weight, GrowthFlagKind.aboveRange), (GrowthMetric.length, GrowthFlagKind.aboveRange)]));
    });

    test('just inside the curves is fine', () {
      final r = check(baby(), [at(120, weightZ: -1.8, lengthZ: 1.8, headZ: -1.8)]);
      expect(r.concern, GrowthConcern.none);
    });
  });

  group('crossing curves', () {
    test('weight dropping across two curves in a few months: talk to a doctor', () {
      // From above the 50th to under the 15th (crosses the 50th and the 15th).
      final r = check(baby(), [at(60, weightZ: 0.3), at(150, weightZ: -1.2)]);
      expect(r.concern, GrowthConcern.doctor);
      expect(kinds(r), contains((GrowthMetric.weight, GrowthFlagKind.fallingAcross)));
    });

    test('dropping across one curve only is not flagged', () {
      final r = check(baby(), [at(60, weightZ: 0.3), at(150, weightZ: -0.5)]);
      expect(kinds(r).where((k) => k.$2 == GrowthFlagKind.fallingAcross), isEmpty);
    });

    test('head climbing across two curves: talk to a doctor', () {
      final r = check(baby(), [at(60, headZ: -0.3), at(150, headZ: 1.3)]);
      expect(r.concern, GrowthConcern.doctor);
      expect(kinds(r), contains((GrowthMetric.head, GrowthFlagKind.risingAcross)));
    });

    test('weight climbing across two curves: mention it', () {
      final r = check(baby(), [at(60, weightZ: -0.3), at(150, weightZ: 1.3)]);
      expect(r.concern, GrowthConcern.mention);
      expect(kinds(r), contains((GrowthMetric.weight, GrowthFlagKind.risingAcross)));
    });

    test('measurements under three weeks apart are not compared (scale noise)', () {
      final r = check(baby(), [at(100, lengthZ: 0.3), at(110, lengthZ: -1.2)]);
      expect(kinds(r).where((k) => k.$2 == GrowthFlagKind.fallingAcross), isEmpty);
    });

    test('the birth value is not used for crossing (newborns settle onto a curve)', () {
      // Birth weight far above where the baby later sits.
      final big = (who.valueAtZ('female', GrowthMetric.weight, 0, 1.5) * 1000).round();
      final r = check(baby(birthWeightG: big), [at(90, weightZ: -0.5)]);
      expect(kinds(r).where((k) => k.$2 == GrowthFlagKind.fallingAcross), isEmpty);
    });
  });

  group('birth weight', () {
    test('still under birth weight after two weeks: talk to a doctor', () {
      final r = check(baby(birthWeightG: 3400), [
        GrowthMeasurement(id: 'w', measuredOn: birth.add(const Duration(days: 18)), weightG: 3250),
      ]);
      expect(r.concern, GrowthConcern.doctor);
      expect(kinds(r), contains((GrowthMetric.weight, GrowthFlagKind.belowBirthWeight)));
    });

    test('under birth weight in the first two weeks is normal', () {
      final r = check(baby(birthWeightG: 3400), [
        GrowthMeasurement(id: 'w', measuredOn: birth.add(const Duration(days: 7)), weightG: 3200),
      ]);
      expect(kinds(r).where((k) => k.$2 == GrowthFlagKind.belowBirthWeight), isEmpty);
    });

    test('works even when the sex is not set (no percentiles then)', () {
      final r = check(baby(sex: null, birthWeightG: 3400), [
        GrowthMeasurement(id: 'w', measuredOn: birth.add(const Duration(days: 20)), weightG: 3300),
      ]);
      expect(r.hasEnoughData, isTrue);
      expect(kinds(r), [(GrowthMetric.weight, GrowthFlagKind.belowBirthWeight)]);
    });
  });

  test('slow weight gain over the last month: mention it', () {
    final r = checkGrowth(
      baby: baby(),
      measurements: [
        GrowthMeasurement(id: 'a', measuredOn: birth.add(const Duration(days: 61)), weightG: 5200),
        GrowthMeasurement(id: 'b', measuredOn: birth.add(const Duration(days: 91)), weightG: 5250),
      ],
      who: who,
      weightGain: velocity.check(baby(), [
        GrowthMeasurement(id: 'a', measuredOn: birth.add(const Duration(days: 61)), weightG: 5200),
        GrowthMeasurement(id: 'b', measuredOn: birth.add(const Duration(days: 91)), weightG: 5250),
      ]),
    );
    expect(kinds(r), contains((GrowthMetric.weight, GrowthFlagKind.slowGain)));
  });

  test('the most serious finding comes first', () {
    final r = check(baby(), [at(60, weightZ: 2.3, headZ: 0), at(120, weightZ: 2.3, headZ: -2.3)]);
    expect(r.flags.first.concern, GrowthConcern.doctor);
    expect(r.concern, GrowthConcern.doctor);
  });

  test('after 24 months there are no WHO curves, so no percentile verdicts', () {
    final r = check(baby(), [
      GrowthMeasurement(id: 'old', measuredOn: birth.add(const Duration(days: 800)), weightG: 6000),
    ]);
    expect(kinds(r).where((k) => k.$2 == GrowthFlagKind.belowRange), isEmpty);
  });
}

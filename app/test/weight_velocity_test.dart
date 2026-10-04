import 'dart:convert';
import 'dart:io';

import 'package:baby_app/core/weight_velocity.dart';
import 'package:baby_app/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final velocity = WeightVelocity.fromJson(jsonDecode(File('assets/who_weight_velocity.json').readAsStringSync()));
  final birth = DateTime(2026, 1, 1);
  Baby baby({String? sex = 'male', int? birthWeightG}) =>
      Baby(id: 'b', familyId: 'f', name: 'Ali', birthDate: birth, sex: sex, birthWeightG: birthWeightG);
  GrowthMeasurement w(int day, int grams) =>
      GrowthMeasurement(id: 'm$day', measuredOn: birth.add(Duration(days: day)), weightG: grams);

  test('the WHO table has 12 one-month intervals for each sex', () {
    final json = jsonDecode(File('assets/who_weight_velocity.json').readAsStringSync()) as Map<String, dynamic>;
    for (final sex in ['boys', 'girls']) {
      final rows = (json[sex] as List).cast<Map<String, dynamic>>();
      expect(rows, hasLength(12));
      for (final r in rows) {
        expect(r['p5'] as int, lessThan(r['p50'] as int));
        expect(r['p50'] as int, lessThan(r['p95'] as int));
      }
    }
  });

  test('a usual month between 2 and 3 months', () {
    final check = velocity.check(baby(), [w(61, 5600), w(91, 6400)])!;
    expect(check.daysApart, 30);
    expect(check.gainPerMonthG, 812); // 800 g in 30 days, per average month
    expect(check.band, GainBand.usual);
  });

  test('very little gain is flagged as slow, a lot as fast', () {
    expect(velocity.check(baby(), [w(61, 5600), w(91, 5650)])!.band, GainBand.slow);
    expect(velocity.check(baby(), [w(61, 5600), w(91, 7400)])!.band, GainBand.fast);
  });

  test('the first month counts from the birth weight', () {
    final check = velocity.check(baby(birthWeightG: 3300), [w(28, 4300)])!;
    expect(check.daysApart, 28);
    expect(check.band, GainBand.usual);
  });

  test('picks the weight closest to a month before the latest', () {
    final check = velocity.check(baby(), [w(40, 5000), w(61, 5600), w(70, 5800), w(91, 6400)])!;
    expect(check.daysApart, 30);
  });

  test('nothing to say without sex, weights 3–6 weeks apart, or after 12 months', () {
    expect(velocity.check(baby(sex: null), [w(61, 5600), w(91, 6400)]), isNull);
    expect(velocity.check(baby(), [w(80, 6000), w(91, 6400)]), isNull); // 11 days
    expect(velocity.check(baby(), [w(30, 4500), w(91, 6400)]), isNull); // 61 days
    expect(velocity.check(baby(), [w(400, 9500), w(430, 9700)]), isNull);
  });
}

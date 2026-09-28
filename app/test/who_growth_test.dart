import 'dart:convert';
import 'dart:io';

import 'package:baby_app/core/who_growth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late WhoGrowth who;

  setUpAll(() {
    who = WhoGrowth.fromJson(jsonDecode(File('assets/who_growth.json').readAsStringSync()) as Map<String, dynamic>);
  });

  // Expected values are the published percentiles from the same WHO/CDC files.
  test('median is the 50th percentile', () {
    expect(who.percentile('male', GrowthMetric.weight, 0, 3.3464), closeTo(50, 0.01));
    expect(who.percentile('female', GrowthMetric.head, 0, 33.8787), closeTo(50, 0.01));
  });

  test('published 2.3rd and 97.7th percentiles round-trip', () {
    // Boys weight at birth: 2nd (2.3rd) = 2.459312 kg, 98th (97.7th) = 4.419354 kg
    expect(who.percentile('male', GrowthMetric.weight, 0, 2.459312), closeTo(2.28, 0.05));
    expect(who.percentile('male', GrowthMetric.weight, 0, 4.419354), closeTo(97.72, 0.05));
    // Boys weight at 24 months: 25th = 11.25065 kg
    expect(who.percentile('male', GrowthMetric.weight, 24, 11.25065), closeTo(25, 0.05));
  });

  test('curve values match the published table', () {
    // Girls head at birth, 98th (97.7th) = 36.2474987 cm, i.e. z = +2
    expect(who.valueAtZ('female', GrowthMetric.head, 0, 2), closeTo(36.2475, 0.001));
    expect(who.valueAtZ('male', GrowthMetric.weight, 1, 0), closeTo(4.4709, 0.0001));
  });

  test('ages between months are interpolated', () {
    final halfway = who.valueAtZ('male', GrowthMetric.weight, 0.5, 0);
    expect(halfway, closeTo((3.3464 + 4.4709) / 2, 0.001));
  });

  test('ages past 24 months use the 24-month values', () {
    expect(who.valueAtZ('male', GrowthMetric.weight, 30, 0), closeTo(12.1515, 0.0001));
  });
}

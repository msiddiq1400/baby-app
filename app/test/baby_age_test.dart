import 'package:baby_app/core/baby_age.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('months and days, matching the plan example', () {
    expect(babyAge(DateTime(2026, 4, 8), DateTime(2026, 9, 28)), (months: 5, days: 20));
  });

  test('newborn on the day of birth', () {
    expect(babyAge(DateTime(2026, 9, 28), DateTime(2026, 9, 28)), (months: 0, days: 0));
  });

  test('exact month birthday has zero days', () {
    expect(babyAge(DateTime(2026, 3, 15), DateTime(2026, 9, 15)), (months: 6, days: 0));
  });

  test('day before the monthly birthday', () {
    expect(babyAge(DateTime(2026, 3, 15), DateTime(2026, 9, 14)), (months: 5, days: 30));
  });

  test('born on the 31st, through a short month', () {
    expect(babyAge(DateTime(2026, 1, 31), DateTime(2026, 2, 28)), (months: 0, days: 28));
    expect(babyAge(DateTime(2026, 1, 31), DateTime(2026, 3, 1)), (months: 1, days: 1));
  });

  test('across a year boundary', () {
    expect(babyAge(DateTime(2025, 11, 20), DateTime(2026, 2, 5)), (months: 2, days: 16));
  });

  test('future birth date is clamped to zero', () {
    expect(babyAge(DateTime(2026, 10, 1), DateTime(2026, 9, 28)), (months: 0, days: 0));
  });
}

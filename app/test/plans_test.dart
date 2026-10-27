import 'package:baby_app/features/plans/paywall_screen.dart';
import 'package:baby_app/features/plans/plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('price per day: whole rupees, cents for dollars', () {
    expect(pricePerDay(299, 'PKR', 30), contains('10'));
    expect(pricePerDay(2499, 'PKR', 365), contains('7'));
    expect(pricePerDay(2.99, 'USD', 30), r'$0.10');
    expect(pricePerDay(19.99, 'USD', 365), r'$0.05');
  });

  test('yearly saving against 12 months', () {
    expect(yearlySaving(299, 2499), 30);
    expect(yearlySaving(2.99, 19.99), 44);
    expect(yearlySaving(0, 10), 0);
  });

  test("server's pro_until: date, no end, or Free", () {
    expect(parseProUntil('2027-10-27T10:00:00+00:00'), DateTime.utc(2027, 10, 27, 10));
    expect(parseProUntil('infinity')!.year, 9999);
    expect(parseProUntil(null), isNull);
    expect(parseProUntil('garbage'), isNull);
  });
}

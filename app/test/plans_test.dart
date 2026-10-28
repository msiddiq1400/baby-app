import 'package:baby_app/features/plans/paywall_screen.dart';
import 'package:baby_app/features/plans/plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Package _package(String id, PackageType type, double price) => Package(
  id,
  type,
  StoreProduct(id, '', '', price, '\$$price', 'USD'),
  const PresentedOfferingContext('default', null, null),
);

void main() {
  test('price per day: whole rupees, cents for dollars', () {
    expect(pricePerDay(299, 'PKR', 30), contains('10'));
    expect(pricePerDay(1999, 'PKR', 365), contains('5'));
    expect(pricePerDay(3.99, 'USD', 30), r'$0.13');
    expect(pricePerDay(24.99, 'USD', 365), r'$0.07');
  });

  test('yearly saving against 12 months', () {
    // Today's prices (todos.txt 52): Rs 299 / Rs 1,999; $3.99 / $24.99.
    expect(yearlySaving(299, 1999), 44);
    expect(yearlySaving(3.99, 24.99), 48);
    expect(yearlySaving(0, 10), 0);
  });

  test("server's pro_until: date, no end, or Free", () {
    expect(parseProUntil('2027-10-27T10:00:00+00:00'), DateTime.utc(2027, 10, 27, 10));
    expect(parseProUntil('infinity')!.year, 9999);
    expect(parseProUntil(null), isNull);
    expect(parseProUntil('garbage'), isNull);
  });

  test('the chosen option falls back to one the store offers', () {
    final monthly = _package('m', PackageType.monthly, 3.99);
    final yearly = _package('y', PackageType.annual, 24.99);
    final lifetime = _package('l', PackageType.lifetime, 49.99);
    final all = (monthly: monthly, yearly: yearly, lifetime: lifetime);
    for (final c in ProChoice.values) {
      expect(availableChoice(c, all), c);
    }
    // Lifetime not set up in the store yet: the paywall still works.
    expect(availableChoice(ProChoice.lifetime, (monthly: monthly, yearly: yearly, lifetime: null)), ProChoice.yearly);
    // Only lifetime.
    expect(availableChoice(ProChoice.yearly, (monthly: null, yearly: null, lifetime: lifetime)), ProChoice.lifetime);
  });
}

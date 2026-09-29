import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/milk/milk_reminders.dart';
import 'package:baby_app/features/milk/milk_rules.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final pumped = DateTime(2026, 9, 29, 8, 0);

MilkBag bag(
  MilkLocation location, {
  DateTime? frozenAt,
  DateTime? thawedAt,
  String id = 'b1',
}) => MilkBag(
  id: id,
  pumpedAt: pumped,
  amountMl: 120,
  location: location,
  frozenAt: frozenAt,
  thawedAt: thawedAt,
);

void main() {
  setUpAll(initializeDateFormatting);

  test('use-by follows CDC limits', () {
    expect(milkUseBy(bag(MilkLocation.room)), DateTime(2026, 9, 29, 12, 0));
    expect(milkUseBy(bag(MilkLocation.cooler)), DateTime(2026, 9, 30, 8, 0));
    expect(milkUseBy(bag(MilkLocation.fridge)), DateTime(2026, 10, 3, 8, 0));
    // Frozen a day later: 6 months from freezing.
    expect(
      milkUseBy(
        bag(MilkLocation.freezer, frozenAt: DateTime(2026, 9, 30, 20, 0)),
      ),
      DateTime(2027, 3, 30, 20, 0),
    );
    // Thawed: 24 hours from thawing, regardless of when it was pumped.
    expect(
      milkUseBy(
        bag(MilkLocation.thawed, thawedAt: DateTime(2027, 1, 10, 7, 0)),
      ),
      DateTime(2027, 1, 11, 7, 0),
    );
  });

  test(
    'milk only moves colder, except thawing; thawed milk never goes back',
    () {
      expect(milkMoves(MilkLocation.fridge), [MilkLocation.freezer]);
      expect(milkMoves(MilkLocation.freezer), [MilkLocation.thawed]);
      expect(milkMoves(MilkLocation.thawed), isEmpty);
      expect(milkMoves(MilkLocation.room), contains(MilkLocation.fridge));
    },
  );

  test('needs attention: within a day (7 days for freezer) or expired', () {
    final fridge = bag(MilkLocation.fridge); // use by 3 Oct 08:00
    expect(milkNeedsAttention(fridge, DateTime(2026, 10, 1, 9)), isFalse);
    expect(milkNeedsAttention(fridge, DateTime(2026, 10, 2, 9)), isTrue);
    expect(milkNeedsAttention(fridge, DateTime(2026, 10, 4)), isTrue);
    final frozen = bag(
      MilkLocation.freezer,
      frozenAt: pumped,
    ); // use by 29 Mar 2027
    expect(milkNeedsAttention(frozen, DateTime(2027, 3, 1)), isFalse);
    expect(milkNeedsAttention(frozen, DateTime(2027, 3, 25)), isTrue);
  });

  test('sorted so the milk to use first comes first', () {
    final sorted = sortByUseBy([
      bag(MilkLocation.fridge, id: 'fridge'),
      bag(MilkLocation.room, id: 'room'),
      bag(MilkLocation.cooler, id: 'cooler'),
    ]);
    expect(sorted.map((b) => b.id), ['room', 'cooler', 'fridge']);
  });

  test('reminder some time before use-by, with amount and place', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final reminders = milkReminders([bag(MilkLocation.fridge)], l10n);
    expect(
      reminders.single.at,
      DateTime(2026, 10, 2, 20, 0),
    ); // 12 h before 3 Oct 08:00
    expect(reminders.single.body, '120 ml (Fridge): use by Oct 3 8:00 AM');
  });
}

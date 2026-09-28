import '../../core/dates.dart';
import '../../data/models.dart';

// Storage limits for breast milk for a healthy full-term baby, from the CDC:
// https://www.cdc.gov/breastfeeding/breast-milk-preparation-and-storage/handling-breastmilk.html
//   room (25 °C or cooler) 4 h · cooler with ice packs 24 h · fridge 4 days
//   freezer: best within 6 months · thawed, in the fridge: 24 h · never refreeze

/// When a bag should be used by. Fresh milk counts from pumping; frozen
/// milk from freezing; thawed milk from thawing.
DateTime milkUseBy(MilkBag bag) => switch (bag.location) {
      MilkLocation.room => bag.pumpedAt.add(const Duration(hours: 4)),
      MilkLocation.cooler => bag.pumpedAt.add(const Duration(hours: 24)),
      MilkLocation.fridge => bag.pumpedAt.add(const Duration(days: 4)),
      MilkLocation.freezer => _addMonthsKeepingTime(bag.frozenAt ?? bag.pumpedAt, 6),
      MilkLocation.thawed => (bag.thawedAt ?? bag.pumpedAt).add(const Duration(hours: 24)),
    };

DateTime _addMonthsKeepingTime(DateTime t, int months) {
  final d = addMonths(t, months);
  return DateTime(d.year, d.month, d.day, t.hour, t.minute);
}

/// Where a bag can go next. Milk only gets colder, except thawing frozen
/// milk in the fridge; thawed milk can never go back in the freezer.
List<MilkLocation> milkMoves(MilkLocation from) => switch (from) {
      MilkLocation.room => [MilkLocation.fridge, MilkLocation.freezer, MilkLocation.cooler],
      MilkLocation.cooler => [MilkLocation.fridge, MilkLocation.freezer],
      MilkLocation.fridge => [MilkLocation.freezer],
      MilkLocation.freezer => [MilkLocation.thawed],
      MilkLocation.thawed => [],
    };

/// How long before the use-by time to send a reminder.
Duration milkReminderLead(MilkLocation location) => switch (location) {
      MilkLocation.room => const Duration(hours: 1),
      MilkLocation.cooler || MilkLocation.thawed => const Duration(hours: 4),
      MilkLocation.fridge => const Duration(hours: 12),
      MilkLocation.freezer => const Duration(days: 7),
    };

/// Expired, or (outside the freezer) due within a day: worth a warning.
bool milkNeedsAttention(MilkBag bag, DateTime now) {
  final useBy = milkUseBy(bag);
  if (bag.location == MilkLocation.freezer) return useBy.isBefore(now.add(const Duration(days: 7)));
  return useBy.isBefore(now.add(const Duration(hours: 24)));
}

/// Oldest-expiring first, so the milk that must be used soonest is on top.
List<MilkBag> sortByUseBy(List<MilkBag> bags) => [...bags]..sort((a, b) => milkUseBy(a).compareTo(milkUseBy(b)));

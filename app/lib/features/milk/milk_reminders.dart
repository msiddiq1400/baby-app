import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n_lookup.dart';
import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../data/baby_repository.dart';
import '../../data/milk_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'milk_rules.dart';
import 'milk_sheets.dart';

/// One reminder per stored bag, some time before its use-by time
/// (see [milkReminderLead]).
List<Reminder> milkReminders(List<MilkBag> bags, AppLocalizations l10n) {
  final format = DateFormat.MMMd(dateLocale(l10n)).add_jm();

  return [
    for (final bag in bags)
      Reminder(
        key: bag.id,
        at: milkUseBy(bag).subtract(milkReminderLead(bag.location)),
        title: l10n.milkExpiresTitle,
        body: l10n.milkExpiresBody(bag.amountMl, milkLocationLabel(l10n, bag.location), format.format(milkUseBy(bag))),
      ),
  ];
}

/// Keeps the phone's stored-milk reminders in step with the inventory.
final milkRemindersProvider = FutureProvider<void>((ref) async {
  final baby = await ref.watch(currentBabyProvider.future);
  if (baby == null) return Reminders.replaceGroup('milk', []);

  final bags = await ref.watch(milkBagsProvider(baby.id).future);
  final l10n = appL10n(ref.watch(localeProvider));
  await Reminders.replaceGroup('milk', milkReminders(bags, l10n));
});

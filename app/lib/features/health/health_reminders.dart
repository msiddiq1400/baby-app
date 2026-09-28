import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_lookup.dart';
import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../data/baby_repository.dart';
import '../../data/medication_repository.dart';
import '../../data/vaccine_repository.dart';
import 'medicine_plan.dart';
import 'vaccine_plan.dart';

/// Keeps the phone's vaccine reminders in step with the schedule and the
/// doses recorded. Re-runs whenever those, the baby or the language change.
final vaccineRemindersProvider = FutureProvider<void>((ref) async {
  final baby = await ref.watch(currentBabyProvider.future);
  if (baby == null) return Reminders.replaceGroup('vaccines', []);

  final schedule = await ref.watch(vaccineScheduleProvider.future);
  final given = await ref.watch(vaccinationsProvider(baby.id).future);
  final l10n = appL10n(ref.watch(localeProvider));
  final visits = planVisits(baby.birthDate, schedule, given);
  await Reminders.replaceGroup('vaccines', vaccineReminders(visits, l10n, baby.name));
});

/// Same for medicines: a reminder at each dose time for the next 7 days.
final medicineRemindersProvider = FutureProvider<void>((ref) async {
  final baby = await ref.watch(currentBabyProvider.future);
  if (baby == null) return Reminders.replaceGroup('medicines', []);

  final medications = await ref.watch(medicationsProvider(baby.id).future);
  final doses = await ref.watch(recentDosesProvider(baby.id).future);
  final l10n = appL10n(ref.watch(localeProvider));
  await Reminders.replaceGroup(
    'medicines',
    medicineReminders(medications, doses, l10n, baby.name, DateTime.now()),
  );
});

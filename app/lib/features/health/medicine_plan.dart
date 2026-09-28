import '../../core/reminders.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

enum SlotState { given, skipped, missed, due, upcoming }

/// One scheduled dose of one medicine, e.g. Amoxicillin at 20:00 today.
class DoseSlot {
  const DoseSlot({required this.medication, required this.at, this.record});

  final Medication medication;
  final DateTime at;

  /// What was recorded for this slot, if anything.
  final MedicationDose? record;

  /// "Due" from 30 minutes before until 2 hours after; later it's "missed"
  /// (still recordable, since a late dose may be what the doctor advised).
  SlotState state(DateTime now) {
    if (record case final r?) return r.skipped ? SlotState.skipped : SlotState.given;
    if (at.isAfter(now.add(const Duration(minutes: 30)))) return SlotState.upcoming;
    if (at.isBefore(now.subtract(const Duration(hours: 2)))) return SlotState.missed;
    return SlotState.due;
  }
}

bool _sameMinute(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day && a.hour == b.hour && a.minute == b.minute;

MedicationDose? _recordFor(Medication med, DateTime at, List<MedicationDose> doses) {
  for (final d in doses) {
    if (d.medicationId == med.id && d.scheduledFor != null && _sameMinute(d.scheduledFor!, at)) return d;
  }
  return null;
}

/// Scheduled doses of [med] on [day]; none for "as needed" medicines or on
/// days outside the prescription.
List<DoseSlot> slotsOn(Medication med, DateTime day, List<MedicationDose> doses) {
  if (med.asNeeded || !med.isActiveOn(day)) return [];
  return [
    for (final t in med.doseTimes)
      DoseSlot(medication: med, at: t.on(day), record: _recordFor(med, t.on(day), doses)),
  ];
}

/// Most recent dose actually given (not skipped), for "last given" labels.
MedicationDose? lastGiven(Medication med, List<MedicationDose> doses) {
  MedicationDose? latest;
  for (final d in doses) {
    if (d.medicationId == med.id && !d.skipped && (latest == null || d.givenAt.isAfter(latest.givenAt))) latest = d;
  }
  return latest;
}

/// A reminder at each scheduled dose time for the next [days] days, except
/// doses already recorded. Re-planned every time the app opens, so ongoing
/// medicines keep getting reminders as long as the app is used weekly.
List<Reminder> medicineReminders(
  List<Medication> medications,
  List<MedicationDose> doses,
  AppLocalizations l10n,
  String babyName,
  DateTime now, {
  int days = 7,
}) {
  String stamp(DateTime t) =>
      '${t.year}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}'
      '${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}';

  return [
    for (var i = 0; i < days; i++)
      for (final med in medications)
        for (final slot in slotsOn(med, DateTime(now.year, now.month, now.day + i), doses))
          if (slot.record == null && slot.at.isAfter(now))
            Reminder(
              key: '${med.id}-${stamp(slot.at)}',
              at: slot.at,
              title: l10n.medicineReminderTitle(babyName),
              body: l10n.medicineReminderBody(med.name, med.prescribedDose),
            ),
  ];
}

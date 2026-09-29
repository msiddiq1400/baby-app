import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/health/medicine_plan.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Medication med({
  String id = 'm1',
  List<DoseTime> times = const [DoseTime(9, 0), DoseTime(21, 0)],
  bool asNeeded = false,
  DateTime? start,
  DateTime? end,
}) => Medication(
  id: id,
  name: 'Amoxil',
  prescribedDose: '2.5 ml',
  doseTimes: times,
  asNeeded: asNeeded,
  startDate: start ?? DateTime(2026, 9, 28),
  endDate: end,
);

MedicationDose dose(
  String medId,
  DateTime at, {
  bool skipped = false,
  DateTime? scheduledFor,
}) => MedicationDose(
  id: '$at',
  medicationId: medId,
  givenAt: at,
  skipped: skipped,
  scheduledFor: scheduledFor,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final today = DateTime(2026, 9, 29);

  test('dose times parse from and to Postgres time values', () {
    expect(DoseTime.parse('08:30:00'), const DoseTime(8, 30));
    expect(const DoseTime(8, 5).toDb(), '08:05:00');
  });

  test('active only between start and end date, inclusive', () {
    final m = med(end: DateTime(2026, 10, 2));
    expect(m.isActiveOn(DateTime(2026, 9, 27)), isFalse);
    expect(m.isActiveOn(DateTime(2026, 9, 28, 23)), isTrue);
    expect(m.isActiveOn(DateTime(2026, 10, 2, 22)), isTrue);
    expect(m.isActiveOn(DateTime(2026, 10, 3)), isFalse);
  });

  test('slot states around now', () {
    final slots = slotsOn(
      med(times: const [DoseTime(8, 0), DoseTime(12, 0), DoseTime(20, 0)]),
      today,
      [],
    );
    final now = DateTime(2026, 9, 29, 11, 45);
    expect(slots.map((s) => s.state(now)), [
      SlotState.missed,
      SlotState.due,
      SlotState.upcoming,
    ]);
  });

  test('recorded doses mark their slot given or skipped', () {
    final m = med();
    final doses = [
      dose(
        'm1',
        DateTime(2026, 9, 29, 9, 10),
        scheduledFor: DateTime(2026, 9, 29, 9),
      ),
      dose(
        'm1',
        DateTime(2026, 9, 29, 21, 5),
        skipped: true,
        scheduledFor: DateTime(2026, 9, 29, 21),
      ),
    ];
    final slots = slotsOn(m, today, doses);
    final now = DateTime(2026, 9, 29, 22);
    expect(slots.map((s) => s.state(now)), [
      SlotState.given,
      SlotState.skipped,
    ]);
  });

  test('as-needed medicines have no slots; last given ignores skips', () {
    final m = med(asNeeded: true, times: const []);
    expect(slotsOn(m, today, []), isEmpty);
    final doses = [
      dose('m1', DateTime(2026, 9, 29, 8)),
      dose('m1', DateTime(2026, 9, 29, 10), skipped: true),
    ];
    expect(lastGiven(m, doses)!.givenAt, DateTime(2026, 9, 29, 8));
  });

  test(
    'reminders: future dose times for 7 days, within the prescription, not already recorded',
    () {
      final m = med(end: DateTime(2026, 10, 1));
      final now = DateTime(2026, 9, 29, 10);
      final doses = [
        dose(
          'm1',
          DateTime(2026, 9, 29, 20, 50),
          scheduledFor: DateTime(2026, 9, 29, 21),
        ),
      ];
      final reminders = medicineReminders([m], doses, l10n, 'Aisha', now);
      expect(reminders.map((r) => r.at), [
        // 29 Sep 21:00 already recorded; 09:00 today already passed.
        DateTime(2026, 9, 30, 9), DateTime(2026, 9, 30, 21),
        DateTime(2026, 10, 1, 9), DateTime(2026, 10, 1, 21),
      ]);
      expect(reminders.first.title, 'Medicine time for Aisha');
      expect(reminders.first.body, 'Amoxil: 2.5 ml');
      expect(reminders.map((r) => r.key).toSet().length, reminders.length);
    },
  );
}

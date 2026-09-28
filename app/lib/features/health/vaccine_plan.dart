import '../../core/dates.dart';
import '../../core/reminders.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

enum VisitStatus { done, overdue, dueSoon, upcoming }

/// All doses due at the same age, i.e. one trip to the vaccinator.
class VaccineVisit {
  VaccineVisit({
    required this.ageValue,
    required this.ageUnit,
    required this.dueDate,
    required this.doses,
    required this.given,
  });

  final int ageValue;
  final String ageUnit;

  /// Local calendar date (midnight).
  final DateTime dueDate;
  final List<VaccineDose> doses;

  /// Recorded doses from this visit, by vaccine code.
  final Map<String, Vaccination> given;

  String get key => '$ageValue$ageUnit';

  List<VaccineDose> get pending => [for (final d in doses) if (!given.containsKey(d.code)) d];

  /// "Due soon" means within the next 7 days.
  VisitStatus status(DateTime today) {
    final day = DateTime(today.year, today.month, today.day);
    if (pending.isEmpty) return VisitStatus.done;
    if (dueDate.isBefore(day)) return VisitStatus.overdue;
    if (!dueDate.isAfter(day.add(const Duration(days: 7)))) return VisitStatus.dueSoon;
    return VisitStatus.upcoming;
  }
}

/// Due date for a dose, counted from the date of birth.
DateTime vaccineDueDate(DateTime birth, int value, String unit) {
  final b = DateTime(birth.year, birth.month, birth.day);
  return switch (unit) {
    'day' => DateTime(b.year, b.month, b.day + value),
    'week' => DateTime(b.year, b.month, b.day + value * 7),
    'month' => _local(addMonths(b, value)),
    _ => throw ArgumentError('Unknown due age unit: $unit'),
  };
}

DateTime _local(DateTime utcDate) => DateTime(utcDate.year, utcDate.month, utcDate.day);

/// Groups the schedule into visits, in schedule order, and attaches the doses
/// already given.
List<VaccineVisit> planVisits(DateTime birth, List<VaccineDose> schedule, List<Vaccination> given) {
  final byCode = <String, Vaccination>{};
  for (final v in given) {
    byCode.putIfAbsent(v.vaccineCode, () => v);
  }

  final visits = <String, VaccineVisit>{};
  for (final dose in [...schedule]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder))) {
    final visit = visits.putIfAbsent(
      '${dose.dueAgeValue}${dose.dueAgeUnit}',
      () => VaccineVisit(
        ageValue: dose.dueAgeValue,
        ageUnit: dose.dueAgeUnit,
        dueDate: vaccineDueDate(birth, dose.dueAgeValue, dose.dueAgeUnit),
        doses: [],
        given: {},
      ),
    );
    visit.doses.add(dose);
    if (byCode[dose.code] case final v?) visit.given[dose.code] = v;
  }
  return visits.values.toList();
}

/// "Pentavalent (DTP-HepB-Hib) · Dose 2"
String doseTitle(VaccineDose dose) => dose.doseLabel == null ? dose.name : '${dose.name} · ${dose.doseLabel}';

String visitLabel(AppLocalizations l10n, VaccineVisit visit) => switch (visit.ageUnit) {
      _ when visit.ageValue == 0 => l10n.visitAtBirth,
      'week' => l10n.visitWeeks(visit.ageValue),
      'month' => l10n.visitMonths(visit.ageValue),
      _ => l10n.ageDays(visit.ageValue),
    };

/// Reminders at 9 am: the day before, on the day, and a week late if the
/// visit still isn't recorded. Visits already done get none.
List<Reminder> vaccineReminders(List<VaccineVisit> visits, AppLocalizations l10n, String babyName) {
  DateTime nineAm(DateTime day) => DateTime(day.year, day.month, day.day, 9);

  return [
    for (final visit in visits)
      if (visit.pending.isNotEmpty) ...[
        for (final (suffix, day, title) in [
          ('before', visit.dueDate.subtract(const Duration(days: 1)), l10n.vaccinesDueTomorrow(babyName)),
          ('due', visit.dueDate, l10n.vaccinesDueToday(babyName)),
          ('late', visit.dueDate.add(const Duration(days: 7)), l10n.vaccinesOverdueReminder(babyName)),
        ])
          Reminder(
            key: '${visit.key}-$suffix',
            at: nineAm(day),
            title: title,
            body: visit.pending.map((d) => d.code).join(', '),
          ),
      ],
  ];
}

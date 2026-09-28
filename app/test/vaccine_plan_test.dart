import 'package:baby_app/core/reminders.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/health/vaccine_plan.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

VaccineDose dose(String code, int value, String unit, int order) =>
    VaccineDose(code: code, name: code, dueAgeValue: value, dueAgeUnit: unit, sortOrder: order);

Vaccination given(String code, DateTime on) => Vaccination(id: code, vaccineCode: code, givenOn: on);

void main() {
  final birth = DateTime(2026, 4, 8);
  final schedule = [
    dose('BCG', 0, 'day', 10),
    dose('OPV-0', 0, 'day', 11),
    dose('OPV-1', 6, 'week', 20),
    dose('PENTA-1', 6, 'week', 21),
    dose('MR-1', 9, 'month', 50),
  ];
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('due dates count from birth by days, weeks and calendar months', () {
    expect(vaccineDueDate(birth, 0, 'day'), DateTime(2026, 4, 8));
    expect(vaccineDueDate(birth, 6, 'week'), DateTime(2026, 5, 20));
    expect(vaccineDueDate(birth, 9, 'month'), DateTime(2027, 1, 8));
    // Born on the 31st: 1 month later is the last day of the next month.
    expect(vaccineDueDate(DateTime(2026, 1, 31), 1, 'month'), DateTime(2026, 2, 28));
  });

  test('doses due at the same age form one visit, in schedule order', () {
    final visits = planVisits(birth, schedule, []);
    expect(visits.map((v) => v.key), ['0day', '6week', '9month']);
    expect(visits[1].doses.map((d) => d.code), ['OPV-1', 'PENTA-1']);
  });

  test('visit status', () {
    final visits = planVisits(birth, schedule, [given('BCG', birth), given('OPV-0', birth)]);
    final today = DateTime(2026, 5, 15);
    expect(visits[0].status(today), VisitStatus.done);
    expect(visits[1].status(today), VisitStatus.dueSoon); // due 20 May, within 7 days
    expect(visits[2].status(today), VisitStatus.upcoming);
    expect(visits[1].status(DateTime(2026, 5, 21)), VisitStatus.overdue);
  });

  test('partly given visit keeps only the missing doses pending', () {
    final visits = planVisits(birth, schedule, [given('OPV-1', DateTime(2026, 5, 20))]);
    expect(visits[1].pending.map((d) => d.code), ['PENTA-1']);
  });

  test('reminders: day before, on the day and a week late, only for visits not done', () {
    final visits = planVisits(birth, schedule, [given('BCG', birth), given('OPV-0', birth)]);
    final reminders = vaccineReminders(visits, l10n, 'Aisha');
    expect(reminders.map((r) => r.key), [
      '6week-before', '6week-due', '6week-late', //
      '9month-before', '9month-due', '9month-late',
    ]);
    final due = reminders[1];
    expect(due.at, DateTime(2026, 5, 20, 9));
    expect(due.title, "Aisha's vaccines are due today");
    expect(due.body, 'OPV-1, PENTA-1');
  });

  test('notification ids are stable and non-negative', () {
    expect(notificationId('vaccines:6week-due'), notificationId('vaccines:6week-due'));
    expect(notificationId('vaccines:6week-due'), isNot(notificationId('vaccines:6week-late')));
    expect(notificationId('x'), greaterThanOrEqualTo(0));
  });
}

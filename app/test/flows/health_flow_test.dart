// Health tab flows on the real database: vaccines (schedule by country,
// recording, editing, undoing, vaccines added by name), medicines (adding,
// given / skipped / undone doses, as-needed, deleting), the symptom diary
// (fever, validation, the young-baby warning), illness tracking from start
// to recovery, and the summary for the doctor (real data, period, Urdu,
// PDF). The test baby is Aisha, about 5 months 20 days, in Pakistan.

import 'dart:io';

import 'package:baby_app/core/countries.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/features/health/doctor_summary.dart';
import 'package:baby_app/features/health/doctor_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';
import 'health_helpers.dart';

const _dates = DefaultMaterialLocalizations();

void main() {
  setUpFlowTests();

  late FlowEnv env;
  setUp(() async {
    env = await FlowEnv.open();
    await seedVaccineSchedules(env);
  });
  tearDown(() => env.close());

  Future<void> openHealth(WidgetTester tester, [String? inner]) async {
    await env.pumpApp(tester);
    await openTab(tester, en.tabHealth);
    if (inner != null) await openInnerTab(tester, inner);
  }

  Future<DateTime> birthDate(WidgetTester tester) async =>
      DateTime.parse((await env.rows(tester, 'SELECT birth_date FROM babies WHERE id = ?', [env.babyId])).single['birth_date']! as String);

  group('vaccines', () {
    flowWidgets('Pakistan: the EPI visits, with the overdue birth visit as next', (tester) async {
      await openHealth(tester);
      expectNoErrors(tester);
      final birth = await birthDate(tester);
      expect(find.text(en.nextVisit(en.visitAtBirth, _dates.formatMediumDate(birth))), findsOneWidget);
      expect(find.text(en.vaccineScheduleNote), findsOneWidget);
      expect(find.text(en.catchUpNote), findsOneWidget);
      expect(find.text('BCG'), findsOneWidget);
    });

    flowWidgets("the schedule follows the baby's country (United Kingdom)", (tester) async {
      await tester.runAsync(() => env.db.execute("UPDATE babies SET country_code = 'GB' WHERE id = ?", [env.babyId]));
      await openHealth(tester);
      expect(find.text(en.vaccineScheduleNoteCountry(countryName('GB', 'en'))), findsOneWidget);
      expect(find.textContaining('6-in-1'), findsWidgets);
      expect(find.text('BCG'), findsNothing);
      expect(find.text(en.nextVisit(en.visitWeeks(8), _dates.formatMediumDate((await birthDate(tester)).add(const Duration(days: 56))))),
          findsOneWidget);
    });

    flowWidgets('a country without a schedule says so and never shows Pakistan\'s', (tester) async {
      await tester.runAsync(() => env.db.execute("UPDATE babies SET country_code = 'JP' WHERE id = ?", [env.babyId]));
      await openHealth(tester);
      expect(find.text(en.noScheduleTitle(countryName('JP', 'en'))), findsOneWidget);
      expect(find.text('BCG'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, en.addOtherVaccine), findsOneWidget);
    });

    Finder bcgTile() => find.widgetWithText(ListTile, 'BCG');
    Finder inBcg(Finder f) => find.descendant(of: bcgTile(), matching: f);

    flowWidgets('marking one dose given saves it for today and shows it as given', (tester) async {
      await openHealth(tester);
      await tapAndSettle(tester, inBcg(find.widgetWithText(TextButton, en.markGiven)));
      expect(find.text(en.recordVaccination), findsOneWidget);
      await tapSave(tester);
      expectNoErrors(tester);

      final rows = await env.rows(tester, 'SELECT baby_id, vaccine_code, given_on FROM vaccinations WHERE deleted_at IS NULL');
      expect(rows, [
        {'baby_id': env.babyId, 'vaccine_code': 'BCG', 'given_on': isoDay(today())},
      ]);
      await scrollToTop(tester);
      await waitFor(tester, inBcg(find.text(en.givenOn(_dates.formatMediumDate(today())))), count: 1);
      expect(inBcg(find.widgetWithText(TextButton, en.markGiven)), findsNothing);
    });

    flowWidgets('"Mark all as given" records the whole visit and moves "next" on', (tester) async {
      await openHealth(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.markVisitGiven).first);
      await tapSave(tester);

      final codes = (await env.rows(tester, 'SELECT vaccine_code FROM vaccinations ORDER BY vaccine_code')).map((r) => r['vaccine_code']);
      expect(codes, ['BCG', 'HEPB-0', 'OPV-0']);
      await scrollToTop(tester);
      await waitFor(tester, find.textContaining(en.nextVisit(en.visitWeeks(6), '').split(',').first), count: 1);
      final birth = await birthDate(tester);
      expect(find.text(en.nextVisit(en.visitAtBirth, _dates.formatMediumDate(birth))), findsNothing);
    });

    flowWidgets("editing a recorded dose's date updates the row", (tester) async {
      await seedRow(tester, env, 'vaccinations', {'vaccine_code': 'BCG', 'given_on': isoDay(daysAgo(2))});
      await openHealth(tester);
      await tapAndSettle(tester, bcgTile());
      expect(find.text(en.editVaccination), findsOneWidget);
      await tapAndSettle(tester, find.widgetWithText(ListTile, en.dateGivenLabel));
      final day = daysAgo(40);
      await pickDate(tester, day, shown: daysAgo(2));
      await tapSave(tester);

      final rows = await env.rows(tester, 'SELECT given_on FROM vaccinations');
      expect(rows, [
        {'given_on': isoDay(day)},
      ]);
      await scrollToTop(tester);
      await waitFor(tester, inBcg(find.text(en.givenOn(_dates.formatMediumDate(day)))), count: 1);
    });

    flowWidgets('deleting a recorded dose undoes it (soft delete) and offers "Given" again', (tester) async {
      await seedRow(tester, env, 'vaccinations', {'vaccine_code': 'BCG', 'given_on': isoDay(daysAgo(2))});
      await openHealth(tester);
      expect(inBcg(find.widgetWithText(TextButton, en.markGiven)), findsNothing);
      await tapAndSettle(tester, bcgTile());
      await deleteAndConfirm(tester);

      final rows = await env.rows(tester, 'SELECT deleted_at FROM vaccinations');
      expect(rows.single['deleted_at'], isNotNull);
      await scrollToTop(tester);
      await waitFor(tester, inBcg(find.widgetWithText(TextButton, en.markGiven)), count: 1);
    });

    flowWidgets('a vaccine added by name needs a name, then is saved and listed', (tester) async {
      await openHealth(tester);
      await scrollTo(tester, find.widgetWithText(OutlinedButton, en.addOtherVaccine));
      await tapAndSettle(tester, find.widgetWithText(OutlinedButton, en.addOtherVaccine));
      await tapSave(tester);
      expect(find.text(en.fieldRequired), findsOneWidget);
      expect(await env.rows(tester, 'SELECT id FROM vaccinations'), isEmpty);

      await typeInto(tester, en.vaccineNameLabel, 'Typhoid');
      await typeInto(tester, en.clinicLabel, 'City Clinic');
      await tapSave(tester);
      final rows = await env.rows(tester, 'SELECT vaccine_code, vaccine_name, clinic, given_on FROM vaccinations');
      expect(rows, [
        {'vaccine_code': Vaccination.otherCode, 'vaccine_name': 'Typhoid', 'clinic': 'City Clinic', 'given_on': isoDay(today())},
      ]);
      await scrollTo(tester, find.text('Typhoid'));
      expect(find.text('Typhoid'), findsOneWidget);
    });

    flowWidgets('a vaccine added by name can be renamed and deleted', (tester) async {
      await seedRow(tester, env, 'vaccinations', {
        'vaccine_code': Vaccination.otherCode,
        'vaccine_name': 'Typhoid',
        'given_on': isoDay(daysAgo(5)),
      });
      await openHealth(tester);
      await scrollTo(tester, find.widgetWithText(ListTile, 'Typhoid'));
      await tapAndSettle(tester, find.widgetWithText(ListTile, 'Typhoid'));
      await typeInto(tester, en.vaccineNameLabel, 'Typhoid conjugate');
      await tapSave(tester);
      expect((await env.rows(tester, 'SELECT vaccine_name FROM vaccinations')).single['vaccine_name'], 'Typhoid conjugate');
      await waitFor(tester, find.text('Typhoid conjugate'), count: 1);

      await tapAndSettle(tester, find.widgetWithText(ListTile, 'Typhoid conjugate'));
      await deleteAndConfirm(tester);
      expect((await env.rows(tester, 'SELECT deleted_at FROM vaccinations')).single['deleted_at'], isNotNull);
      await waitForNone(tester, find.text('Typhoid conjugate'));
    });
  });

  group('medicines', () {
    Future<void> openMedicines(WidgetTester tester) => openHealth(tester, en.tabMedicines);

    Future<void> addEvery6h(WidgetTester tester, {String name = 'Paracetamol syrup'}) async {
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.addMedicine));
      await typeInto(tester, en.medicineNameLabel, name);
      await typeInto(tester, en.prescribedDoseLabel, '2.5 ml');
      await tapAndSettle(tester, find.widgetWithText(ActionChip, en.presetEvery6h));
      await tapSave(tester);
    }

    flowWidgets('shows the safety note and adds a scheduled medicine', (tester) async {
      await openMedicines(tester);
      expect(find.text(en.medicineSafetyNote), findsOneWidget);
      expect(find.text(en.noMedicines), findsOneWidget);
      await addEvery6h(tester);
      expectNoErrors(tester);

      final rows = await env.rows(tester, 'SELECT baby_id, name, prescribed_dose, dose_times, as_needed, start_date, end_date FROM medications');
      expect(rows, hasLength(1));
      final m = rows.single;
      expect(m['baby_id'], env.babyId);
      expect(m['name'], 'Paracetamol syrup');
      expect(m['prescribed_dose'], '2.5 ml');
      expect(m['as_needed'], 0);
      expect(m['start_date'], isoDay(today()));
      expect(m['end_date'], isNull);
      for (final t in ['00:00', '06:00', '12:00', '18:00']) {
        expect(m['dose_times'] as String, contains(t));
      }
      expect(find.text('Paracetamol syrup'), findsOneWidget);
      expect(find.text(en.noMedicines), findsNothing);
    });

    flowWidgets('a medicine needs a name, a dose and (if scheduled) a time', (tester) async {
      await openMedicines(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.addMedicine));
      await tapSave(tester);
      expect(find.text(en.fieldRequired), findsNWidgets(2));
      expect(find.text(en.chooseTimes), findsOneWidget);
      expect(await env.rows(tester, 'SELECT id FROM medications'), isEmpty);
    });

    flowWidgets('a course in days sets the end date', (tester) async {
      await openMedicines(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.addMedicine));
      await typeInto(tester, en.medicineNameLabel, 'Amoxicillin');
      await typeInto(tester, en.prescribedDoseLabel, '5 ml');
      await tapAndSettle(tester, find.widgetWithText(ActionChip, en.presetTwice));
      await typeInto(tester, en.durationDaysLabel, '5');
      await tapSave(tester);
      final m = (await env.rows(tester, 'SELECT start_date, end_date FROM medications')).single;
      expect(m['end_date'], isoDay(DateTime(today().year, today().month, today().day + 4)));
    });

    flowWidgets("recording today's dose as given saves it and offers Undo", (tester) async {
      await openMedicines(tester);
      await addEvery6h(tester);
      // The midnight dose is always due or past, whatever time the test runs.
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.markDoseGiven).first);

      final doses = await env.rows(tester, 'SELECT baby_id, skipped, scheduled_for, given_at, deleted_at FROM medication_doses');
      expect(doses, hasLength(1));
      expect(doses.single['skipped'], 0);
      expect(doses.single['deleted_at'], isNull);
      expect(DateTime.parse(doses.single['scheduled_for']! as String).toLocal(), today());
      // One dose shows as given. Later doses already due (it depends on the
      // time of day) still have their button, which may use the same word.
      final given = find.text(en.doseGiven).evaluate().length;
      final buttons = find.descendant(of: find.byType(FilledButton), matching: find.text(en.doseGiven)).evaluate().length;
      expect(given - buttons, 1);
      expect(find.widgetWithText(TextButton, en.undoDose), findsOneWidget);
    });

    flowWidgets('skipping a dose records it as skipped, and Undo removes it', (tester) async {
      await openMedicines(tester);
      await addEvery6h(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.skipDose).first);
      expect((await env.rows(tester, 'SELECT skipped FROM medication_doses')).single['skipped'], 1);
      expect(find.text(en.doseSkipped), findsOneWidget);

      await tapAndSettle(tester, find.widgetWithText(TextButton, en.undoDose));
      expect((await env.rows(tester, 'SELECT deleted_at FROM medication_doses')).single['deleted_at'], isNotNull);
      expect(find.text(en.doseSkipped), findsNothing);
    });

    flowWidgets('an as-needed medicine records a dose now and shows when it was last given', (tester) async {
      await openMedicines(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.addMedicine));
      await typeInto(tester, en.medicineNameLabel, 'Ibuprofen');
      await typeInto(tester, en.prescribedDoseLabel, '2.5 ml');
      await tapAndSettle(tester, find.text(en.scheduleAsNeeded));
      await tapSave(tester);
      expect((await env.rows(tester, 'SELECT as_needed FROM medications')).single['as_needed'], 1);

      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.recordDoseNow));
      final doses = await env.rows(tester, 'SELECT skipped, scheduled_for FROM medication_doses');
      expect(doses, [
        {'skipped': 0, 'scheduled_for': null},
      ]);
      expect(find.textContaining(en.lastGiven('#').split('#').first), findsOneWidget);
    });

    flowWidgets('deleting a medicine removes it from the list (soft delete)', (tester) async {
      await openMedicines(tester);
      await addEvery6h(tester);
      await tapAndSettle(tester, find.byIcon(Icons.edit_outlined));
      expect(find.text(en.editMedicine), findsOneWidget);
      await deleteAndConfirm(tester);
      expect((await env.rows(tester, 'SELECT deleted_at FROM medications')).single['deleted_at'], isNotNull);
      expect(find.text(en.noMedicines), findsOneWidget);
    });

    flowWidgets('a course that has ended is listed under Finished', (tester) async {
      await seedRow(tester, env, 'medications', {
        'name': 'Old antibiotic',
        'prescribed_dose': '5 ml',
        'dose_times': '["09:00:00"]',
        'as_needed': 0,
        'start_date': isoDay(daysAgo(20)),
        'end_date': isoDay(daysAgo(14)),
      });
      await openMedicines(tester);
      expect(find.text('${en.finishedMedicines} (1)'), findsOneWidget);
      expect(find.text(en.noMedicines), findsOneWidget);
    });
  });

  group('symptoms', () {
    Future<void> openSymptomForm(WidgetTester tester) async {
      await openHealth(tester, en.tabSymptoms);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logSymptom).last);
    }

    flowWidgets('logging a fever saves temperature, severity and notes and lists it', (tester) async {
      await openSymptomForm(tester);
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.symptomFever));
      await typeInto(tester, en.temperatureLabel, '38.6');
      await tapAndSettle(tester, find.text(en.severityModerate));
      await typeInto(tester, en.notesLabel, 'After vaccines');
      await tapSave(tester);
      expectNoErrors(tester);

      final rows = await env.rows(tester, 'SELECT baby_id, symptom, temperature_c, severity, notes FROM symptom_logs');
      expect(rows, [
        {'baby_id': env.babyId, 'symptom': 'fever', 'temperature_c': 38.6, 'severity': 2, 'notes': 'After vaccines'},
      ]);
      expect(find.textContaining(displayTemperature(38.6)), findsOneWidget);
      expect(find.text('After vaccines'), findsOneWidget);
    });

    flowWidgets('a temperature in °F is saved in °C', (tester) async {
      await openSymptomForm(tester);
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.symptomFever));
      await tapAndSettle(tester, find.text('°F'));
      await typeInto(tester, en.temperatureLabel, '101.3');
      await tapSave(tester);
      expect((await env.rows(tester, 'SELECT temperature_c FROM symptom_logs')).single['temperature_c'], 38.5);
    });

    flowWidgets('no symptom chosen, or an impossible temperature, is refused', (tester) async {
      await openSymptomForm(tester);
      await tapSave(tester);
      expect(find.text(en.fieldRequired), findsOneWidget);
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.symptomFever));
      await typeInto(tester, en.temperatureLabel, '50');
      await tapSave(tester);
      expect(find.text(en.invalidTemperature), findsOneWidget);
      expect(await env.rows(tester, 'SELECT id FROM symptom_logs'), isEmpty);
    });

    flowWidgets('no young-baby fever warning at 5 months', (tester) async {
      await openSymptomForm(tester);
      await typeInto(tester, en.temperatureLabel, '38.4');
      expect(find.text(en.youngFeverWarning), findsNothing);
    });

    flowWidgets('editing a symptom changes it, deleting hides it', (tester) async {
      await seedRow(tester, env, 'symptom_logs', {
        'symptom': 'cough',
        'occurred_at': utcText(DateTime.now().subtract(const Duration(hours: 2))),
        'severity': 1,
      });
      Finder coughTile() => find.ancestor(of: find.textContaining(en.symptomCough), matching: find.byType(ListTile));
      await openHealth(tester, en.tabSymptoms);
      await tapAndSettle(tester, coughTile());
      expect(find.text(en.editSymptom), findsOneWidget);
      await tapAndSettle(tester, find.text(en.severitySevere));
      await tapSave(tester);
      expect((await env.rows(tester, 'SELECT severity FROM symptom_logs')).single['severity'], 3);

      await tapAndSettle(tester, coughTile());
      await deleteAndConfirm(tester);
      expect((await env.rows(tester, 'SELECT deleted_at FROM symptom_logs')).single['deleted_at'], isNotNull);
      await waitFor(tester, find.text(en.noSymptoms), count: 1);
    });
  });

  group('young baby', () {
    late FlowEnv young;
    setUp(() async {
      young = await FlowEnv.open(baby: false);
      await young.seedBaby(name: 'Zara', birthDate: DateTime.now().subtract(const Duration(days: 40)));
    });
    tearDown(() => young.close());

    flowWidgets('under 3 months, a fever of 38°C or more shows the see-a-doctor warning', (tester) async {
      await young.pumpApp(tester);
      await openTab(tester, en.tabHealth);
      await openInnerTab(tester, en.tabSymptoms);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logSymptom).last);
      await typeInto(tester, en.temperatureLabel, '37.5');
      expect(find.text(en.youngFeverWarning), findsNothing);
      await typeInto(tester, en.temperatureLabel, '38.2');
      expect(find.text(en.youngFeverWarning), findsOneWidget);
    });
  });

  group('illness', () {
    Future<void> startCold(WidgetTester tester) async {
      await openHealth(tester, en.tabSymptoms);
      await tapAndSettle(tester, find.widgetWithText(OutlinedButton, en.startIllnessButton));
      await tapAndSettle(tester, find.widgetWithText(ActionChip, en.illnessCold));
      await tapSave(tester);
    }

    final cardTitle = '${en.illnessDay(1)} · ${en.illnessCold}';

    flowWidgets('starting an illness saves it and shows "Day 1 · Cold"', (tester) async {
      await startCold(tester);
      expectNoErrors(tester);
      final rows = await env.rows(tester, 'SELECT baby_id, name, recovered_at FROM illnesses');
      expect(rows, [
        {'baby_id': env.babyId, 'name': en.illnessCold, 'recovered_at': null},
      ]);
      expect(find.text(cardTitle), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, en.startIllnessButton), findsNothing);
    });

    flowWidgets("a symptom and a doctor's visit logged from the card show on the day-by-day page", (tester) async {
      await startCold(tester);
      // The card's own buttons come first (it's above the diary's).
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.logSymptom).first);
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.symptomCough));
      await typeInto(tester, en.temperatureLabel, '38.1');
      await tapSave(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.doctorVisit).first);
      await typeInto(tester, en.doctorLabel, 'Dr Amina');
      await typeInto(tester, en.diagnosisLabel, 'Viral cold');
      await tapSave(tester);

      expect(await env.rows(tester, 'SELECT doctor, diagnosis FROM doctor_visits'), [
        {'doctor': 'Dr Amina', 'diagnosis': 'Viral cold'},
      ]);
      // The card lists the symptom and the last temperature.
      expect(find.widgetWithText(Chip, en.symptomCough), findsOneWidget);

      await tapAndSettle(tester, find.text(cardTitle));
      expectNoErrors(tester);
      expect(find.text(en.illnessDay(1)), findsOneWidget); // the header
      expect(find.textContaining(en.symptomCough), findsWidgets);
      expect(find.text('${en.doctorVisit} · Dr Amina · Viral cold'), findsOneWidget);
      expect(find.text(en.highestTemperature(displayTemperature(38.1))), findsOneWidget);
      expect(find.text(en.doctorVisitsCount(1)), findsOneWidget);
    });

    flowWidgets('Recovered ends the illness and lists it under past illnesses', (tester) async {
      await startCold(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.markRecovered));
      final rows = await env.rows(tester, 'SELECT recovered_at FROM illnesses');
      expect(rows.single['recovered_at'], isNotNull);
      expect(find.text(cardTitle), findsNothing);
      expect(find.widgetWithText(OutlinedButton, en.startIllnessButton), findsOneWidget);
      expect(find.widgetWithText(ListTile, en.illnessCold), findsOneWidget);
      expect(find.textContaining(en.illnessLasted(1)), findsOneWidget);
    });

    flowWidgets('a past illness can be reopened with "Still unwell"', (tester) async {
      await seedRow(tester, env, 'illnesses', {
        'name': 'Fever',
        'started_at': utcText(DateTime.now().subtract(const Duration(days: 3))),
        'recovered_at': utcText(DateTime.now().subtract(const Duration(days: 1))),
      });
      await openHealth(tester, en.tabSymptoms);
      await tapAndSettle(tester, find.widgetWithText(ListTile, 'Fever'));
      await tapAndSettle(tester, find.widgetWithText(OutlinedButton, en.stillUnwell));
      expect((await env.rows(tester, 'SELECT recovered_at FROM illnesses')).single['recovered_at'], isNull);
      await waitFor(tester, find.widgetWithText(FilledButton, en.markRecovered), count: 1);
    });
  });

  group('summary for the doctor', () {
    Future<void> seedHealthData(WidgetTester tester) async {
      final now = DateTime.now();
      await seedRow(tester, env, 'symptom_logs', {
        'symptom': 'fever',
        'occurred_at': utcText(now.subtract(const Duration(days: 1))),
        'temperature_c': 38.4,
      });
      await seedRow(tester, env, 'symptom_logs', {
        'symptom': 'cough',
        'occurred_at': utcText(now.subtract(const Duration(days: 10))),
      });
      for (var h = 1; h <= 3; h++) {
        await seedRow(tester, env, 'feeds', {'type': 'breast', 'started_at': utcText(now.subtract(Duration(minutes: h * 20)))});
        await seedRow(tester, env, 'diapers', {
          'occurred_at': utcText(now.subtract(Duration(minutes: h * 20))),
          'is_wet': 1,
          'is_dirty': 0,
        });
      }
      final med = await seedRow(tester, env, 'medications', {
        'name': 'Paracetamol syrup',
        'prescribed_dose': '2.5 ml',
        'dose_times': '[]',
        'as_needed': 1,
        'start_date': isoDay(daysAgo(2)),
      });
      await seedRow(tester, env, 'medication_doses', {
        'medication_id': med,
        'given_at': utcText(now.subtract(const Duration(hours: 20))),
        'skipped': 0,
      });
    }

    String summaryText(WidgetTester tester) => tester.widget<SelectableText>(find.byType(SelectableText)).data!;

    for (final tab in [null, 'medicines', 'symptoms']) {
      flowWidgets('opens from the top of Health (${tab ?? 'vaccines'} tab) with the real data', (tester) async {
        await seedHealthData(tester);
        await openHealth(tester, switch (tab) {
          'medicines' => en.tabMedicines,
          'symptoms' => en.tabSymptoms,
          _ => null,
        });
        await tapAndSettle(tester, find.widgetWithText(FilledButton, en.doctorSummary));
        expectNoErrors(tester);
        expect(find.byType(DoctorSummaryScreen), findsOneWidget);
        final text = summaryText(tester);
        expect(text, contains(en.sumTitle('Aisha')));
        expect(text, contains(en.symptomFever));
        expect(text, contains(en.symptomCough)); // since symptoms started, 10 days ago
        expect(text, contains(en.sumMedicines));
        expect(text, contains('Paracetamol syrup'));
        expect(text, contains(en.sumFeedsPerDay('#').split('#').first));
      });
    }

    flowWidgets('a shorter period leaves out older symptoms', (tester) async {
      await seedHealthData(tester);
      await openHealth(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.doctorSummary));
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, en.lastNDays(3)));
      final text = summaryText(tester);
      expect(text, contains(en.symptomFever));
      expect(text, isNot(contains(en.symptomCough)));
    });

    flowWidgets('in the Urdu app it starts in English for the doctor and switches to Urdu', (tester) async {
      await seedHealthData(tester);
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await env.pumpApp(tester);
      await openTab(tester, ur.tabHealth);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, ur.doctorSummary));
      expectNoErrors(tester);
      expect(summaryText(tester), contains(en.sumTitle('Aisha')));
      await tapAndSettle(tester, find.widgetWithText(SwitchListTile, ur.showInEnglish));
      expect(summaryText(tester), contains(ur.sumTitle('Aisha')));
      expect(summaryText(tester), contains(ur.symptomFever));
    });

    flowWidgets('PDF builds a real PDF file and hands it to the share sheet', (tester) async {
      await seedHealthData(tester);
      final messenger = tester.binding.defaultBinaryMessenger;
      final tempDir = Directory('${env.dir.path}/tmp')..createSync();
      messenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (call) async => tempDir.path);
      MethodCall? shared;
      messenger.setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/share'), (call) async {
        shared = call;
        return 'dev.fluttercommunity.plus/share/success';
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
        messenger.setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/share'), null);
      });

      await openHealth(tester);
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.doctorSummary));
      await tapAndSettle(tester, find.widgetWithText(OutlinedButton, en.pdfButton));
      await settle(tester, rounds: 10);
      expectNoErrors(tester);
      expect(find.text(en.errorGeneric), findsNothing);

      expect(shared, isNotNull, reason: 'the share sheet was not opened');
      final args = shared!.arguments as Map;
      final paths = (args['paths'] as List).cast<String>();
      expect(paths.single, endsWith('.pdf'));
      final bytes = await tester.runAsync(() => File(paths.single).readAsBytes());
      expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
    });
  });
}

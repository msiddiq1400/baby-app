// Growth tab flows on the real database: adding, checking, editing and
// deleting measurements; the weight-gain card against WHO from real rows;
// ticking milestones; monthly photos (data flow and the Photos tab).
// The test baby is Aisha, a girl, about 5 months 20 days, 3.2 kg at birth.

import 'dart:io';
import 'dart:typed_data';

import 'package:baby_app/core/providers.dart';
import 'package:baby_app/core/who_growth.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/photo_repository.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/features/growth/photos_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';
import 'health_helpers.dart';

void main() {
  setUpFlowTests();

  late FlowEnv env;
  setUp(() async => env = await FlowEnv.open());
  tearDown(() => env.close());

  Future<void> openGrowth(WidgetTester tester) async {
    await env.pumpApp(tester);
    await openTab(tester, en.tabGrowth);
  }

  Future<void> openAddMeasurement(WidgetTester tester) =>
      tapAndSettle(tester, find.widgetWithText(FloatingActionButton, en.addMeasurement));

  // The verdict card on top of Charts. Aisha is a girl of about 5 months 20
  // days: around 7.2 kg is the middle, under about 5.6 kg is below the 3rd
  // percentile.
  group('growth check', () {
    Finder card(String title) => find.ancestor(of: find.text(title), matching: find.byType(Card));

    flowWidgets('a usual weight says growing as expected, and nothing about a doctor', (tester) async {
      await openGrowth(tester);
      await openAddMeasurement(tester);
      await typeInto(tester, en.weightKgLabel, '7.2');
      await tapSave(tester);
      expectNoErrors(tester);
      expect(find.text(en.growthCheckOkTitle), findsOneWidget);
      expect(find.text(en.growthCheckDoctorTitle), findsNothing);
    });

    flowWidgets('a very low weight says talk to your doctor, with the reason in plain words', (tester) async {
      await openGrowth(tester);
      await openAddMeasurement(tester);
      await typeInto(tester, en.weightKgLabel, '4.5');
      await tapSave(tester);
      expectNoErrors(tester);
      expect(find.text(en.growthCheckDoctorTitle), findsOneWidget);
      expect(find.text(en.growthFlagBelowRange(en.growthMeasureWeight)), findsOneWidget);
      expect(find.text(en.growthCheckDoctorBody), findsOneWidget);
      // It might be a typo: say how to check.
      expect(find.text(en.growthCheckTypo), findsOneWidget);
      // At the top of the screen, above the chart.
      expect(tester.getTopLeft(card(en.growthCheckDoctorTitle)).dy, lessThan(tester.getTopLeft(find.byType(SegmentedButton<GrowthMetric>)).dy));
    });

    flowWidgets('a problem with another measure shows on the Weight view, and tapping it opens that chart', (tester) async {
      // Head size far above the top curve; the screen opens on Weight.
      await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(3)), 'head_mm': 470});
      await openGrowth(tester);
      final head = en.growthFlagAboveRange(en.growthMeasureHead);
      expect(find.text(en.growthCheckDoctorTitle), findsOneWidget);
      expect(find.text(head), findsOneWidget);
      expect(tester.widget<SegmentedButton<GrowthMetric>>(find.byType(SegmentedButton<GrowthMetric>)).selected, {GrowthMetric.weight});

      await tapAndSettle(tester, find.text(head));
      expect(tester.widget<SegmentedButton<GrowthMetric>>(find.byType(SegmentedButton<GrowthMetric>)).selected, {GrowthMetric.head});
    });

    flowWidgets('weight dropping across two curves says talk to your doctor', (tester) async {
      await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(90)), 'weight_g': 6200});
      await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(2)), 'weight_g': 6150});
      await openGrowth(tester);
      expect(find.text(en.growthCheckDoctorTitle), findsOneWidget);
      expect(find.text(en.growthFlagFallingAcross(en.growthMeasureWeight)), findsOneWidget);
    });

    flowWidgets('the latest card says what the percentile means, and the explanation opens', (tester) async {
      await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(1)), 'weight_g': 7200});
      await openGrowth(tester);
      // "Heavier than about N in 100 babies...": the text before the number.
      expect(find.textContaining(en.percentileMeaningWeight('#').split('#').first), findsOneWidget);
      await scrollTo(tester, find.text(en.legendYourBaby));
      expect(find.text(en.legendYourBaby), findsOneWidget);
      expect(find.text(en.percentileExplain), findsNothing);
      await scrollTo(tester, find.text(en.percentileExplainTitle));
      await tapAndSettle(tester, find.text(en.percentileExplainTitle));
      expect(find.text(en.percentileExplain), findsOneWidget);
      expectNoErrors(tester);
    });

    flowWidgets('in Urdu the doctor card reads right to left without overflowing', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(1)), 'weight_g': 4500});
      await env.pumpApp(tester);
      await openTab(tester, ur.tabGrowth);
      expectNoErrors(tester);
      expect(find.text(ur.growthCheckDoctorTitle), findsOneWidget);
      expect(find.text(ur.growthFlagBelowRange(ur.growthMeasureWeight)), findsOneWidget);
    });
  });

  group('measurements', () {
    flowWidgets('adding weight, length and head saves one row and shows the latest weight', (tester) async {
      await openGrowth(tester);
      await openAddMeasurement(tester);
      await typeInto(tester, en.weightKgLabel, '7.25');
      await typeInto(tester, en.lengthCmLabel, '65.5');
      await typeInto(tester, en.headCmLabel, '42');
      await tapSave(tester);
      expectNoErrors(tester);

      final rows = await env.rows(tester, 'SELECT baby_id, measured_on, weight_g, length_mm, head_mm FROM growth_measurements');
      expect(rows, [
        {'baby_id': env.babyId, 'measured_on': isoDay(today()), 'weight_g': 7250, 'length_mm': 655, 'head_mm': 420},
      ]);
      // The latest-value card and the history list.
      expect(find.text('7.25 kg'), findsWidgets);
      expect(find.text(en.noMeasurements), findsNothing);
    });

    flowWidgets('a weight outside 0.3-40 kg is refused and nothing is saved', (tester) async {
      await openGrowth(tester);
      await openAddMeasurement(tester);
      await typeInto(tester, en.weightKgLabel, '400');
      await tapSave(tester);
      expect(find.text(en.invalidWeightKg), findsOneWidget);
      expect(await env.rows(tester, 'SELECT id FROM growth_measurements'), isEmpty);
    });

    flowWidgets('silly length and head values are refused', (tester) async {
      await openGrowth(tester);
      await openAddMeasurement(tester);
      await typeInto(tester, en.lengthCmLabel, '5');
      await typeInto(tester, en.headCmLabel, '99');
      await tapSave(tester);
      expect(find.text(en.invalidLengthCm), findsOneWidget);
      expect(find.text(en.invalidHeadCm), findsOneWidget);
      expect(await env.rows(tester, 'SELECT id FROM growth_measurements'), isEmpty);
    });

    flowWidgets('saving an empty form asks for at least one measurement', (tester) async {
      await openGrowth(tester);
      await openAddMeasurement(tester);
      await tapSave(tester);
      expect(find.text(en.enterOneMeasurement), findsOneWidget);
      expect(await env.rows(tester, 'SELECT id FROM growth_measurements'), isEmpty);
    });

    flowWidgets('a measurement on an earlier date is saved with that date', (tester) async {
      await openGrowth(tester);
      await openAddMeasurement(tester);
      final day = daysAgo(20);
      await tapAndSettle(tester, find.widgetWithText(ListTile, en.dateLabel));
      await pickDate(tester, day);
      await typeInto(tester, en.weightKgLabel, '6.9');
      await tapSave(tester);
      final rows = await env.rows(tester, 'SELECT measured_on, weight_g FROM growth_measurements');
      expect(rows, [
        {'measured_on': isoDay(day), 'weight_g': 6900},
      ]);
    });

    flowWidgets('editing a measurement updates the same row', (tester) async {
      final id = await tester.runAsync(
        () => env.db.execute(
          "INSERT INTO growth_measurements (id, family_id, baby_id, measured_on, weight_g) VALUES ('m1', ?, ?, ?, 6800)",
          [env.familyId, env.babyId, isoDay(daysAgo(3))],
        ),
      );
      expect(id, isNotNull);
      await openGrowth(tester);
      await scrollTo(tester, find.widgetWithText(ListTile, '6.80 kg'));
      await tapAndSettle(tester, find.widgetWithText(ListTile, '6.80 kg'));
      expect(find.text(en.editMeasurement), findsOneWidget);
      await typeInto(tester, en.weightKgLabel, '6.95');
      await tapSave(tester);

      final rows = await env.rows(tester, 'SELECT id, weight_g FROM growth_measurements');
      expect(rows, [
        {'id': 'm1', 'weight_g': 6950},
      ]);
      expect(find.text('6.95 kg'), findsWidgets);
    });

    flowWidgets('deleting a measurement hides it (soft delete, kept for sync)', (tester) async {
      await tester.runAsync(
        () => env.db.execute(
          "INSERT INTO growth_measurements (id, family_id, baby_id, measured_on, weight_g) VALUES ('m1', ?, ?, ?, 6800)",
          [env.familyId, env.babyId, isoDay(daysAgo(3))],
        ),
      );
      await openGrowth(tester);
      await scrollTo(tester, find.widgetWithText(ListTile, '6.80 kg'));
      await tapAndSettle(tester, find.widgetWithText(ListTile, '6.80 kg'));
      await deleteAndConfirm(tester);
      expectNoErrors(tester);

      final rows = await env.rows(tester, 'SELECT deleted_at FROM growth_measurements WHERE id = ?', ['m1']);
      expect(rows.single['deleted_at'], isNotNull);
      expect(find.text('6.80 kg'), findsNothing);
      // Only the birth weight is left.
      expect(find.text('3.20 kg'), findsWidgets);
    });

    flowWidgets('a baby without sex asks for it before drawing curves, and saves the choice', (tester) async {
      await tester.runAsync(() => env.db.execute('UPDATE babies SET sex = NULL WHERE id = ?', [env.babyId]));
      await openGrowth(tester);
      expect(find.text(en.chooseSexForChart), findsOneWidget);
      await tapAndSettle(tester, find.widgetWithText(OutlinedButton, en.sexFemale));
      final rows = await env.rows(tester, 'SELECT sex FROM babies WHERE id = ?', [env.babyId]);
      expect(rows.single['sex'], 'female');
      expect(find.text(en.chooseSexForChart), findsNothing);
    });

    flowWidgets('Urdu: adding a weight works and shows the Urdu form', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await env.pumpApp(tester);
      await openTab(tester, ur.tabGrowth);
      await tapAndSettle(tester, find.widgetWithText(FloatingActionButton, ur.addMeasurement));
      await typeInto(tester, ur.weightKgLabel, '7.1');
      await tapAndSettle(tester, find.widgetWithText(FilledButton, ur.saveButton).last);
      expectNoErrors(tester);
      expect(await env.rows(tester, 'SELECT weight_g FROM growth_measurements'), [
        {'weight_g': 7100},
      ]);
    });
  });

  group('weight gain against WHO', () {
    Future<void> seedWeights(WidgetTester tester, int earlierG, int laterG) async {
      for (final (days, grams) in [(35, earlierG), (5, laterG)]) {
        await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(days)), 'weight_g': grams});
      }
    }

    flowWidgets('is hidden with only the birth weight', (tester) async {
      await openGrowth(tester);
      expect(find.text(en.weightGainTitle), findsNothing);
    });

    // 30 days apart at 5 months: WHO's usual range is about 170-740 g a month.
    for (final (name, gain, note) in [
      ('usual', 450, en.weightGainUsual),
      ('slower than most', 0, en.weightGainSlow),
      ('faster than most', 1500, en.weightGainFast),
    ]) {
      flowWidgets('two weights a month apart: $name', (tester) async {
        await seedWeights(tester, 6500, 6500 + gain);
        await openGrowth(tester);
        expect(find.text(en.weightGainTitle), findsOneWidget);
        expect(find.text(note), findsOneWidget);
        expect(find.textContaining('$gain'), findsWidgets);
      });
    }

    flowWidgets('weights only a week apart give no verdict', (tester) async {
      await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(10)), 'weight_g': 6900});
      await seedRow(tester, env, 'growth_measurements', {'measured_on': isoDay(daysAgo(3)), 'weight_g': 7000});
      await openGrowth(tester);
      expect(find.text(en.weightGainTitle), findsNothing);
    });
  });

  group('milestones', () {
    Future<void> openMilestones(WidgetTester tester) async {
      await openGrowth(tester);
      await openInnerTab(tester, en.tabMilestones);
    }

    flowWidgets("the baby's current age group opens first", (tester) async {
      await openMilestones(tester);
      // 5 months 20 days: working towards the 6-month checklist.
      final six = find.widgetWithText(ExpansionTile, en.byMonths(6));
      expect(tester.widget<ExpansionTile>(six).initiallyExpanded, isTrue);
      final two = find.widgetWithText(ExpansionTile, en.byMonths(2));
      await tester.scrollUntilVisible(two, -300, scrollable: find.byType(Scrollable).last);
      expect(tester.widget<ExpansionTile>(two).initiallyExpanded, isFalse);
    });

    flowWidgets('ticking a milestone saves it with today and shows "reached"', (tester) async {
      await openMilestones(tester);
      final box = find.byType(CheckboxListTile).first;
      final title = ((tester.widget<CheckboxListTile>(box).title!) as Text).data!;
      await tapAndSettle(tester, box);

      final rows = await env.rows(tester, 'SELECT baby_id, milestone_id, achieved_on, deleted_at FROM milestone_checks');
      expect(rows, hasLength(1));
      expect(rows.single['baby_id'], env.babyId);
      expect(rows.single['achieved_on'], isoDay(today()));
      expect(rows.single['deleted_at'], isNull);
      expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, title)).value, isTrue);
      expect(find.textContaining(en.reachedOn(MaterialLocalizations.of(tester.element(box)).formatMediumDate(today()))),
          findsOneWidget);
    });

    flowWidgets('unticking a milestone removes it (soft delete) and updates the count', (tester) async {
      await openMilestones(tester);
      final box = find.byType(CheckboxListTile).first;
      await tapAndSettle(tester, box);
      await tapAndSettle(tester, find.byType(CheckboxListTile).first);

      final rows = await env.rows(tester, 'SELECT deleted_at FROM milestone_checks');
      expect(rows, hasLength(1));
      expect(rows.single['deleted_at'], isNotNull);
      expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile).first).value, isFalse);
    });

    flowWidgets('ticked milestones count towards the age group progress', (tester) async {
      await openMilestones(tester);
      final group = find.widgetWithText(ExpansionTile, en.byMonths(6));
      final total = find
          .descendant(of: group, matching: find.byType(CheckboxListTile))
          .evaluate()
          .length;
      expect(find.text(en.milestonesProgress(0, total)), findsOneWidget);
      await tapAndSettle(tester, find.descendant(of: group, matching: find.byType(CheckboxListTile)).first);
      await tapAndSettle(tester, find.descendant(of: group, matching: find.byType(CheckboxListTile)).at(1));
      expect(find.text(en.milestonesProgress(2, total)), findsOneWidget);
    });
  });

  group('photos', () {
    // A tiny valid JPEG (1x1 pixel).
    final jpeg = Uint8List.fromList(const [
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, //
      0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43, 0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08,
      0x07, 0x07, 0x07, 0x09, 0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
      0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20, 0x24, 0x2E, 0x27, 0x20,
      0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29, 0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27,
      0x39, 0x3D, 0x38, 0x32, 0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0xFF, 0xC4, 0x00, 0x14,
      0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00, 0x2A, 0x9F, 0xFF, 0xD9,
    ]);

    late PhotoRepository photos;
    late Baby baby;
    setUp(() async {
      final folder = '${env.dir.path}/photos';
      await Directory(folder).create(recursive: true);
      photos = PhotoRepository(env.db, createPhotoQueue(env.db, env.supabase, folder), folder, env.supabase);
      baby = Baby.fromJson(await env.db.get('SELECT ${Baby.columns} FROM babies WHERE id = ?', [env.babyId]));
    });

    test('adding a photo saves the row and the file on the phone', () async {
      await photos.add(baby, ageMonth: 2, jpeg: jpeg, caption: 'First smile');
      final row = await env.db.get('SELECT baby_id, family_id, age_month, caption, deleted_at FROM photos');
      expect(row['baby_id'], env.babyId);
      expect(row['family_id'], env.familyId);
      expect(row['age_month'], 2);
      expect(row['caption'], 'First smile');
      expect(row['deleted_at'], isNull);

      final list = await photos.watchPhotos(env.babyId!).first;
      expect(list.single.ageMonth, 2);
      expect(list.single.localPath, isNotNull);
      expect(File(list.single.localPath!).readAsBytesSync(), jpeg);
    });

    test('only one photo per month: a second one for the same month is refused', () async {
      await photos.add(baby, ageMonth: 3, jpeg: jpeg);
      await expectLater(photos.add(baby, ageMonth: 3, jpeg: jpeg), throwsA(isA<PhotoLimitException>()));
      await photos.add(baby, ageMonth: 4, jpeg: jpeg);
      expect(await env.db.getAll('SELECT id FROM photos'), hasLength(2));
    });

    test('editing the caption changes only the caption', () async {
      await photos.add(baby, ageMonth: 1, jpeg: jpeg, caption: 'Old');
      final id = (await env.db.get('SELECT id FROM photos'))['id'] as String;
      await photos.updateCaption(id, 'New caption');
      final row = await env.db.get('SELECT age_month, caption FROM photos WHERE id = ?', [id]);
      expect(row, {'age_month': 1, 'caption': 'New caption'});
    });

    test('deleting a photo hides it and frees the month for a new one', () async {
      await photos.add(baby, ageMonth: 5, jpeg: jpeg);
      final id = (await env.db.get('SELECT id FROM photos'))['id'] as String;
      await photos.delete(baby, id);
      expect((await env.db.get('SELECT deleted_at FROM photos WHERE id = ?', [id]))['deleted_at'], isNotNull);
      expect(await photos.watchPhotos(env.babyId!).first, isEmpty);
      // The month can be filled again.
      await photos.add(baby, ageMonth: 5, jpeg: jpeg);
      expect(await photos.watchPhotos(env.babyId!).first, hasLength(1));
    });

    flowWidgets("the Photos tab shows a saved photo's month as filled", (tester) async {
      await tester.runAsync(() => photos.add(baby, ageMonth: 1, jpeg: jpeg));
      // The app's photo repository uses Supabase.instance (not set up in
      // tests), so give the screen one built on the test database.
      await pumpAppWith(tester, env, [
        photoRepositoryProvider.overrideWith(
          (ref) => PhotoRepository(env.db, ref.watch(photoQueueProvider), ref.watch(photoFolderProvider), ref.watch(supabaseProvider)),
        ),
      ]);
      await openTab(tester, en.tabGrowth);
      await openInnerTab(tester, en.tabPhotos);
      expectNoErrors(tester);
      // Newborn to 5 months is 6 tiles; one has the photo.
      expect(find.text(photoMonthLabel(en, 1)), findsOneWidget);
      expect(find.text(en.addPhoto), findsNWidgets(5));
    });
  });
}

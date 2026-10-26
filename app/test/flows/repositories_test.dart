// The data layer on a real on-phone database (no widgets, so these are
// fast): every repository saves, edits and soft-deletes; deleted rows stay
// hidden from every query (today, journal, reports, the doctor summary);
// queries never mix up two babies; days begin and end at local midnight
// (a sleep crossing midnight counts on both days); watch streams emit when
// data changes. Also the insertRow / updateRow helpers.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:baby_app/data/baby_repository.dart';
import 'package:baby_app/data/growth_repository.dart';
import 'package:baby_app/data/illness_repository.dart';
import 'package:baby_app/data/journal_repository.dart';
import 'package:baby_app/data/local_db.dart';
import 'package:baby_app/data/medication_repository.dart';
import 'package:baby_app/data/milk_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:baby_app/data/photo_repository.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/data/solids_repository.dart';
import 'package:baby_app/data/symptom_repository.dart';
import 'package:baby_app/data/tracking_repository.dart';
import 'package:baby_app/data/vaccine_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart';

import 'harness.dart';

Future<Baby> loadBaby(PowerSyncDatabase db, String id) async =>
    Baby.fromJson(await db.get('SELECT ${Baby.columns} FROM babies WHERE id = ?', [id]));

/// The first value of [stream] that passes [test] (fails after 5 s).
Future<T> firstWhere<T>(Stream<T> stream, bool Function(T) test) =>
    stream.firstWhere(test).timeout(const Duration(seconds: 5));

DateTime get _now => DateTime.now();
DateTime get today => DateTime(_now.year, _now.month, _now.day);
DateTime get yesterday => DateTime(_now.year, _now.month, _now.day - 1);
DateTime at(DateTime day, int hour, [int minute = 0, int second = 0]) =>
    DateTime(day.year, day.month, day.day, hour, minute, second);

void main() {
  late FlowEnv env;
  late PowerSyncDatabase db;
  late Baby baby;

  /// A second baby in the same family, whose rows must never show for [baby].
  late Baby sibling;

  setUp(() async {
    env = await FlowEnv.open();
    db = env.db;
    baby = await loadBaby(db, env.babyId!);
    sibling = await loadBaby(db, await env.seedBaby(name: 'Omar', sex: 'male'));
  });
  tearDown(() => env.close());

  group('local_db helpers', () {
    test('insertRow makes an id, stores booleans as 0/1 and lists as JSON', () async {
      final id = await insertRow(db, 'medications', {
        'family_id': baby.familyId,
        'baby_id': baby.id,
        'name': 'Syrup',
        'prescribed_dose': '2 ml',
        'as_needed': true,
        'dose_times': ['08:00:00', '20:00:00'],
        'start_date': '2026-10-01',
      });
      expect(id, isNotEmpty);
      final row = await db.get('SELECT as_needed, dose_times FROM medications WHERE id = ?', [id]);
      expect(row['as_needed'], 1);
      expect(jsonDecode(row['dose_times'] as String), ['08:00:00', '20:00:00']);
    });

    test('insertRow keeps an id it is given', () async {
      final id = await insertRow(db, 'families', {'id': 'fixed-id', 'name': 'F'});
      expect(id, 'fixed-id');
      expect(await db.getAll('SELECT id FROM families WHERE id = ?', ['fixed-id']), hasLength(1));
    });

    test('updateRow changes only the given columns and converts false to 0', () async {
      final id = await insertRow(db, 'diapers', {
        'family_id': baby.familyId,
        'baby_id': baby.id,
        'occurred_at': '2026-10-01T10:00:00.000Z',
        'is_wet': true,
        'is_dirty': true,
      });
      await updateRow(db, 'diapers', id, {'is_dirty': false});
      final row = await db.get('SELECT occurred_at, is_wet, is_dirty FROM diapers WHERE id = ?', [id]);
      expect(row, {'occurred_at': '2026-10-01T10:00:00.000Z', 'is_wet': 1, 'is_dirty': 0});
    });
  });

  group('babies', () {
    test('the first baby creates a family; a second baby joins the same family', () async {
      final families = await db.getAll('SELECT id FROM families');
      expect(families, hasLength(1));
      expect(sibling.familyId, baby.familyId);
    });

    test('updateBaby saves every field, including the country', () async {
      await BabyRepository(db).updateBaby(
        baby.id,
        name: 'Aisha K',
        birthDate: DateTime(2026, 5, 6),
        countryCode: 'GB',
        sex: 'female',
        birthWeightG: 3300,
        birthLengthMm: 500,
        birthHeadMm: 350,
      );
      final b = await loadBaby(db, baby.id);
      expect((b.name, b.birthDate, b.countryCode, b.birthWeightG, b.birthLengthMm, b.birthHeadMm),
          ('Aisha K', DateTime(2026, 5, 6), 'GB', 3300, 500, 350));
    });

    test('a deleted baby disappears from the list', () async {
      await BabyRepository(db).delete(sibling.id);
      final babies = await firstWhere(BabyRepository(db).watchBabies(), (l) => l.length == 1);
      expect(babies.single.id, baby.id);
    });

    test('the current baby is the one chosen on this phone, else the first', () async {
      final container = ProviderContainer(overrides: env.overrides);
      addTearDown(container.dispose);
      final sub = container.listen(currentBabyProvider, (_, _) {});
      addTearDown(sub.close);

      Future<String?> waitFor(String id) async {
        for (var i = 0; i < 100; i++) {
          final current = container.read(currentBabyProvider).value;
          if (current?.id == id) return id;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        return container.read(currentBabyProvider).value?.id;
      }

      expect(await waitFor(baby.id), baby.id, reason: 'nothing chosen: the first baby');
      await SettingsRepository(db).set(SettingKeys.babyId, sibling.id);
      expect(await waitFor(sibling.id), sibling.id, reason: 'the chosen baby');
      await BabyRepository(db).delete(sibling.id);
      expect(await waitFor(baby.id), baby.id, reason: 'the chosen baby was deleted: back to the first');
    });

    test('signed out, no babies are offered (even if the phone still has rows)', () async {
      final signedOut = await FlowEnv.open(signedIn: false);
      addTearDown(signedOut.close);
      final container = ProviderContainer(overrides: signedOut.overrides);
      addTearDown(container.dispose);
      // Riverpod pauses providers nobody listens to, so listen like a screen.
      container.listen(babiesProvider, (_, _) {});
      container.listen(currentBabyProvider, (_, _) {});
      for (var i = 0; i < 100 && !container.read(currentBabyProvider).hasValue; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(container.read(babiesProvider).value, isEmpty);
      expect(container.read(currentBabyProvider).hasValue, isTrue);
      expect(container.read(currentBabyProvider).value, isNull);
    });
  });

  group('settings (this phone only)', () {
    test('set adds a value, a second set replaces it, and the watch follows', () async {
      final settings = SettingsRepository(db);
      await settings.set(SettingKeys.locale, 'ur');
      expect(await firstWhere(settings.watch(SettingKeys.locale), (v) => v == 'ur'), 'ur');
      await settings.set(SettingKeys.locale, 'en');
      expect(await firstWhere(settings.watch(SettingKeys.locale), (v) => v == 'en'), 'en');
      expect(await db.getAll('SELECT id FROM app_settings WHERE id = ?', [SettingKeys.locale]), hasLength(1));
    });

    test('settings are never uploaded', () async {
      await SettingsRepository(db).set(SettingKeys.themeMode, 'dark');
      final batch = await db.getCrudBatch(limit: 1000);
      expect(batch?.crud.where((c) => c.table == 'app_settings') ?? const [], isEmpty);
    });
  });

  group('feeds, diapers and sleep', () {
    late TrackingRepository tracking;
    setUp(() => tracking = TrackingRepository(db));

    test('a bottle feed stores the amount and no breast fields', () async {
      final t = at(today, 0, 30);
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: t, amountMl: 120);
      final feed = (await tracking.today(baby.id)).feeds.single;
      expect((feed.type, feed.amountMl, feed.leftSeconds, feed.side, feed.startedAt, feed.endedAt),
          (FeedType.bottleFormula, 120, null, null, t, null));
    });

    test('a breastfeed with minutes per side starts that long before it ended', () async {
      final end = at(today, 1);
      await tracking.saveFeed(baby, type: FeedType.breast, at: end, amountMl: 50, leftSeconds: 300, rightSeconds: 240);
      final feed = (await tracking.today(baby.id)).feeds.single;
      expect(feed.amountMl, isNull, reason: 'no amount for a breastfeed');
      expect(feed.side, BreastSide.both);
      expect(feed.startedAt, end.subtract(const Duration(seconds: 540)));
      expect(feed.endedAt, end);
    });

    test('one side only is saved as that side', () async {
      await tracking.saveFeed(baby, type: FeedType.breast, at: at(today, 1), leftSeconds: 0, rightSeconds: 600);
      expect((await tracking.today(baby.id)).feeds.single.side, BreastSide.right);
    });

    test('editing a feed changes it in place and ends any timer', () async {
      await tracking.startFeedTimer(baby, BreastSide.left, at: at(today, 0, 10));
      final timer = (await tracking.today(baby.id)).feeds.single;
      await tracking.saveFeed(baby, existingId: timer.id, type: FeedType.bottleBreastMilk, at: at(today, 0, 20), amountMl: 90);
      final feeds = (await tracking.today(baby.id)).feeds;
      expect(feeds, hasLength(1));
      expect((feeds.single.id, feeds.single.type, feeds.single.amountMl, feeds.single.timerActive),
          (timer.id, FeedType.bottleBreastMilk, 90, false));
    });

    test('today has only today\'s entries, for this baby, not deleted ones', () async {
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(today, 0, 0, 1), amountMl: 10);
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(yesterday, 23, 59, 59), amountMl: 20);
      await tracking.saveFeed(sibling, type: FeedType.bottleFormula, at: at(today, 0, 5), amountMl: 30);
      await tracking.saveDiaper(baby, at: at(today, 0, 10), wet: true, dirty: false);
      await tracking.saveDiaper(baby, at: at(today, 0, 15), wet: false, dirty: true);
      final log = await tracking.today(baby.id);
      expect(log.feeds.map((f) => f.amountMl), [10]);
      expect((log.wetCount, log.dirtyCount), (1, 1));

      await tracking.delete(TrackedTable.diapers, log.diapers.first.id);
      await tracking.delete(TrackedTable.feeds, log.feeds.single.id);
      final after = await tracking.today(baby.id);
      expect(after.feeds, isEmpty);
      expect(after.diapers, hasLength(1));
    });

    test('a diaper stores wet and dirty as true/false', () async {
      await tracking.saveDiaper(baby, at: at(today, 0, 30), wet: true, dirty: true);
      final d = (await tracking.today(baby.id)).diapers.single;
      expect((d.isWet, d.isDirty), (true, true));
      await tracking.saveDiaper(baby, existingId: d.id, at: d.occurredAt, wet: false, dirty: true);
      final edited = (await tracking.today(baby.id)).diapers.single;
      expect((edited.isWet, edited.isDirty), (false, true));
    });

    test('a sleep from last night counts on today from midnight; yesterday\'s nap does not', () async {
      await tracking.addSleep(baby, kind: SleepKind.nap, startedAt: at(yesterday, 13), endedAt: at(yesterday, 14));
      await tracking.addSleep(baby, kind: SleepKind.night, startedAt: at(yesterday, 22), endedAt: at(today, 2));
      final log = await tracking.today(baby.id);
      expect(log.sleeps, hasLength(1));
      expect(log.sleptSince(at(today, 3)), const Duration(hours: 2));
    });

    test('a sleep still going from last night is today\'s ongoing sleep; ending it saves the time', () async {
      await tracking.addSleep(baby, kind: SleepKind.night, startedAt: at(yesterday, 23));
      final ongoing = (await tracking.today(baby.id)).ongoingSleep;
      expect(ongoing, isNotNull);
      final wake = DateTime.now();
      await tracking.endSleep(ongoing!.id, at: wake);
      final log = await tracking.today(baby.id);
      expect(log.ongoingSleep, isNull);
      expect(log.sleeps.single.endedAt!.difference(wake).inSeconds.abs(), lessThan(1));
    });

    test('updateSleep changes kind and times, and can make it ongoing again', () async {
      await tracking.addSleep(baby, kind: SleepKind.nap, startedAt: at(today, 0, 30), endedAt: at(today, 1));
      final s = (await tracking.today(baby.id)).sleeps.single;
      await tracking.updateSleep(s.id, kind: SleepKind.night, startedAt: at(today, 0, 15));
      final edited = (await tracking.today(baby.id)).sleeps.single;
      expect((edited.kind, edited.startedAt, edited.endedAt), (SleepKind.night, at(today, 0, 15), null));
    });

    test('sleep kind: 7 pm to 6 am is night, the rest is a nap', () {
      expect(sleepKindAt(at(today, 18, 59)), SleepKind.nap);
      expect(sleepKindAt(at(today, 19)), SleepKind.night);
      expect(sleepKindAt(at(today, 5, 59)), SleepKind.night);
      expect(sleepKindAt(at(today, 6)), SleepKind.nap);
    });

    test('feed timer: start, switch, pause, resume, finish', () async {
      final t0 = at(today, 0, 1);
      await tracking.startFeedTimer(baby, BreastSide.left, at: t0);
      Feed? timer = await firstWhere<Feed?>(tracking.watchFeedTimer(baby.id), (f) => f != null);
      expect((timer!.timerSide, timer.timerPaused), (BreastSide.left, false));

      await tracking.switchFeedSide(timer, BreastSide.right, at: t0.add(const Duration(minutes: 5)));
      timer = await firstWhere<Feed?>(tracking.watchFeedTimer(baby.id), (f) => f?.timerSide == BreastSide.right);
      expect(timer!.leftSeconds, 300);

      await tracking.pauseFeedTimer(timer, at: t0.add(const Duration(minutes: 8)));
      timer = await firstWhere<Feed?>(tracking.watchFeedTimer(baby.id), (f) => f?.timerPaused ?? false);
      expect((timer!.leftSeconds, timer.rightSeconds), (300, 180));

      await tracking.resumeFeedTimer(timer, at: t0.add(const Duration(minutes: 20)));
      timer = await firstWhere<Feed?>(tracking.watchFeedTimer(baby.id), (f) => f != null && !f.timerPaused);

      await tracking.finishFeedTimer(timer!, at: t0.add(const Duration(minutes: 22)));
      expect(await firstWhere(tracking.watchFeedTimer(baby.id), (f) => f == null), isNull);
      final feed = (await tracking.today(baby.id)).feeds.single;
      expect((feed.leftSeconds, feed.rightSeconds, feed.side), (300, 300, BreastSide.both));
      expect(feed.endedAt, t0.add(const Duration(minutes: 22)));
    });

    test('a deleted timer feed is no longer "feeding now"', () async {
      await tracking.startFeedTimer(baby, BreastSide.left, at: at(today, 0, 1));
      final timer = await firstWhere<Feed?>(tracking.watchFeedTimer(baby.id), (f) => f != null);
      await tracking.delete(TrackedTable.feeds, timer!.id);
      expect(await firstWhere(tracking.watchFeedTimer(baby.id), (f) => f == null), isNull);
    });

    test('another baby\'s timer is not this baby\'s', () async {
      await tracking.startFeedTimer(sibling, BreastSide.left, at: at(today, 0, 1));
      expect(await tracking.watchFeedTimer(baby.id).first, isNull);
    });

    test('watchToday emits again when a diaper is logged', () async {
      final seen = <int>[];
      final done = Completer<void>();
      final sub = tracking.watchToday(baby.id).listen((log) {
        seen.add(log.diapers.length);
        if (log.diapers.isNotEmpty && !done.isCompleted) done.complete();
      });
      // Not awaited: cancelling a table watch only finishes at the next change.
      addTearDown(() => unawaited(sub.cancel()));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tracking.saveDiaper(baby, at: at(today, 0, 5), wet: true, dirty: false);
      await done.future.timeout(const Duration(seconds: 5));
      expect(seen.first, 0);
      expect(seen.last, 1);
    });

    test('report and summary queries skip deleted entries and other babies', () async {
      final from = DateTime(_now.year, _now.month, _now.day - 7);
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(yesterday, 10), amountMl: 100);
      await tracking.saveFeed(sibling, type: FeedType.bottleFormula, at: at(yesterday, 11), amountMl: 200);
      await tracking.saveDiaper(baby, at: at(yesterday, 12), wet: true, dirty: false);
      await tracking.addSleep(baby, kind: SleepKind.nap, startedAt: at(yesterday, 13), endedAt: at(yesterday, 14));

      expect((await tracking.watchFeedsSince(baby.id, from).first).map((f) => f.amountMl), [100]);
      final (feeds, diapers) = await tracking.feedsAndDiapersSince(baby.id, from);
      expect((feeds.length, diapers.length), (1, 1));

      await tracking.delete(TrackedTable.feeds, feeds.single.id);
      await tracking.delete(TrackedTable.diapers, diapers.single.id);
      final sleeps = await tracking.watchSleepsSince(baby.id, from).first;
      await tracking.delete(TrackedTable.sleeps, sleeps.single.id);

      expect(await tracking.watchFeedsSince(baby.id, from).first, isEmpty);
      expect(await tracking.watchDiapersSince(baby.id, from).first, isEmpty);
      expect(await tracking.watchSleepsSince(baby.id, from).first, isEmpty);
      final (feedsAfter, diapersAfter) = await tracking.feedsAndDiapersSince(baby.id, from);
      expect(feedsAfter, isEmpty);
      expect(diapersAfter, isEmpty);
    });

    test('a soft delete is an update (it reaches other phones), not a removal', () async {
      await tracking.saveDiaper(baby, at: at(today, 0, 5), wet: true, dirty: false);
      final id = (await tracking.today(baby.id)).diapers.single.id;
      await tracking.delete(TrackedTable.diapers, id);
      final row = await db.get('SELECT deleted_at FROM diapers WHERE id = ?', [id]);
      expect(row['deleted_at'], isNotNull);
    });
  });

  group('breast milk', () {
    late MilkRepository milk;
    setUp(() => milk = MilkRepository(db));

    test('pumping with "store in" adds the session and one bag linked to it', () async {
      await milk.logPumping(baby, at: at(today, 0, 30), side: BreastSide.both, amountMl: 110, minutes: 15, storeIn: MilkLocation.fridge);
      final sessions = await milk.watchPumpingSince(baby.id, today).first;
      expect(sessions.single.amountMl, 110);
      expect(sessions.single.startedAt, at(today, 0, 15));
      expect(sessions.single.endedAt, at(today, 0, 30));
      final bags = await milk.watchActiveBags(baby.id).first;
      expect((bags.single.amountMl, bags.single.location), (110, MilkLocation.fridge));
      final link = await db.get('SELECT pumping_session_id FROM milk_stash WHERE id = ?', [bags.single.id]);
      expect(link['pumping_session_id'], sessions.single.id);
    });

    test('pumping without an amount stores no bag', () async {
      await milk.logPumping(baby, at: at(today, 0, 30), storeIn: MilkLocation.fridge);
      expect(await milk.watchActiveBags(baby.id).first, isEmpty);
      expect(await milk.watchPumpingSince(baby.id, today).first, hasLength(1));
    });

    test('editing and deleting a pumping session', () async {
      await milk.logPumping(baby, at: at(today, 0, 30), amountMl: 60);
      final s = (await milk.watchPumpingSince(baby.id, today).first).single;
      await milk.updatePumping(s.id, at: at(today, 0, 40), amountMl: 80, side: BreastSide.left);
      final edited = (await milk.watchPumpingSince(baby.id, today).first).single;
      expect((edited.amountMl, edited.side, edited.startedAt), (80, BreastSide.left, at(today, 0, 40)));
      await milk.deletePumping(s.id);
      expect(await milk.watchPumpingSince(baby.id, today).first, isEmpty);
    });

    test('a bag added to the freezer is dated frozen; moving it to thaw dates the thaw', () async {
      await milk.addBag(baby, amountMl: 90, pumpedAt: at(yesterday, 9), location: MilkLocation.freezer);
      final bag = (await milk.watchActiveBags(baby.id).first).single;
      expect(bag.frozenAt, isNotNull);
      expect(bag.thawedAt, isNull);
      await milk.move(bag, MilkLocation.thawed);
      final moved = (await milk.watchActiveBags(baby.id).first).single;
      expect((moved.location, moved.thawedAt != null, moved.frozenAt), (MilkLocation.thawed, true, bag.frozenAt));
    });

    test('a used or thrown-away bag leaves the stash, with the reason saved', () async {
      await milk.addBag(baby, amountMl: 90, pumpedAt: at(yesterday, 9), location: MilkLocation.fridge);
      await milk.addBag(baby, amountMl: 60, pumpedAt: at(yesterday, 10), location: MilkLocation.fridge);
      final bags = await milk.watchActiveBags(baby.id).first;
      await milk.finish(bags[0], used: true);
      await milk.finish(bags[1], used: false);
      expect(await milk.watchActiveBags(baby.id).first, isEmpty);
      final reasons = await db.getAll('SELECT finished_reason FROM milk_stash ORDER BY finished_reason');
      expect(reasons.map((r) => r['finished_reason']), ['discarded', 'used']);
    });

    test('one baby\'s stash is not the other\'s', () async {
      await milk.addBag(sibling, amountMl: 90, pumpedAt: at(yesterday, 9), location: MilkLocation.fridge);
      expect(await milk.watchActiveBags(baby.id).first, isEmpty);
    });
  });

  group('solids and milestones', () {
    late SolidsRepository solids;
    setUp(() => solids = SolidsRepository(db));

    test('a try is saved by date, edited in place, newest first, and deleted', () async {
      await solids.saveTry(baby, foodId: 'egg', triedOn: at(yesterday, 18), reaction: 'none', opinion: 'liked');
      await solids.saveTry(baby, foodId: 'banana', triedOn: at(today, 9), reaction: 'mild');
      var tries = await solids.watchTries(baby.id).first;
      expect(tries.map((t) => t.foodId), ['banana', 'egg']);
      expect(tries.last.triedOn, yesterday, reason: 'date only, no time');

      await solids.saveTry(baby, existingId: tries.first.id, foodId: 'banana', triedOn: today, reaction: 'severe', notes: 'rash');
      tries = await solids.watchTries(baby.id).first;
      expect((tries.first.reaction, tries.first.notes, tries.length), ('severe', 'rash', 2));

      await solids.deleteTry(tries.first.id);
      expect((await solids.watchTries(baby.id).first).map((t) => t.foodId), ['egg']);
    });

    test('another baby\'s tries are not shown', () async {
      await solids.saveTry(sibling, foodId: 'egg', triedOn: today, reaction: 'none');
      expect(await solids.watchTries(baby.id).first, isEmpty);
    });

    test('ticking a milestone twice keeps one; un-ticking hides it; ticking again adds it back', () async {
      await solids.setMilestone(baby, '6m-laughs', null, reached: true);
      var checks = await solids.watchMilestones(baby.id).first;
      await solids.setMilestone(baby, '6m-laughs', checks['6m-laughs'], reached: true);
      checks = await solids.watchMilestones(baby.id).first;
      expect(checks.keys, ['6m-laughs']);
      expect(checks['6m-laughs']!.achievedOn, today);

      await solids.setMilestone(baby, '6m-laughs', checks['6m-laughs'], reached: false);
      expect(await solids.watchMilestones(baby.id).first, isEmpty);

      await solids.setMilestone(baby, '6m-laughs', null, reached: true);
      expect((await solids.watchMilestones(baby.id).first).keys, ['6m-laughs']);
    });

    test('un-ticking a milestone that was never ticked does nothing', () async {
      await solids.setMilestone(baby, '6m-laughs', null, reached: false);
      expect(await db.getAll('SELECT id FROM milestone_checks'), isEmpty);
    });
  });

  group('growth', () {
    test('measurements are oldest first, editable, deletable and per baby', () async {
      final growth = GrowthRepository(db);
      await growth.save(baby, measuredOn: DateTime(2026, 9, 1), weightG: 6000);
      await growth.save(baby, measuredOn: DateTime(2026, 8, 1), weightG: 5500, lengthMm: 600, headMm: 400);
      await growth.save(sibling, measuredOn: DateTime(2026, 8, 15), weightG: 9999);
      var all = await growth.all(baby.id);
      expect(all.map((g) => g.weightG), [5500, 6000]);

      await growth.save(baby, existingId: all.last.id, measuredOn: DateTime(2026, 9, 2), weightG: 6100);
      all = await growth.all(baby.id);
      expect((all.last.weightG, all.last.measuredOn), (6100, DateTime(2026, 9, 2)));

      await growth.delete(all.first.id);
      expect((await growth.watchAll(baby.id).first).map((g) => g.weightG), [6100]);
    });
  });

  group('vaccines', () {
    late VaccineRepository vaccines;
    setUp(() => vaccines = VaccineRepository(db));

    test('the schedule is per country, in order', () async {
      for (final (country, code, order) in [('PK', 'B', 20), ('PK', 'A', 10), ('GB', 'X', 5)]) {
        await db.execute(
          'INSERT INTO vaccine_schedule (id, country_code, code, name, due_age_value, due_age_unit, sort_order) '
          "VALUES (?, ?, ?, ?, 0, 'day', ?)",
          ['$country-$code', country, code, code, order],
        );
      }
      expect((await vaccines.watchSchedule('PK').first).map((d) => d.code), ['A', 'B']);
      expect((await vaccines.watchSchedule('GB').first).map((d) => d.code), ['X']);
      expect(await vaccines.watchSchedule('JP').first, isEmpty);
    });

    test('a clinic visit records every dose given that day', () async {
      await vaccines.markGiven(baby, codes: ['OPV-1', 'PENTA-1'], givenOn: DateTime(2026, 6, 17), clinic: 'BHU');
      final given = await vaccines.watchGiven(baby.id).first;
      expect(given.map((v) => (v.vaccineCode, v.givenOn, v.clinic)), [
        ('OPV-1', DateTime(2026, 6, 17), 'BHU'),
        ('PENTA-1', DateTime(2026, 6, 17), 'BHU'),
      ]);
      expect(await vaccines.watchGiven(sibling.id).first, isEmpty);
    });

    test('an "other" vaccine has its name; editing without a name keeps it', () async {
      await vaccines.addOther(baby, name: 'Typhoid', givenOn: DateTime(2026, 9, 1));
      var v = (await vaccines.watchGiven(baby.id).first).single;
      expect((v.isOther, v.vaccineName), (true, 'Typhoid'));

      await vaccines.update(v.id, givenOn: DateTime(2026, 9, 2), batchNumber: 'B12');
      v = (await vaccines.watchGiven(baby.id).first).single;
      expect((v.vaccineName, v.givenOn, v.batchNumber), ('Typhoid', DateTime(2026, 9, 2), 'B12'));

      await vaccines.update(v.id, givenOn: v.givenOn, name: 'Typhoid conjugate');
      expect((await vaccines.watchGiven(baby.id).first).single.vaccineName, 'Typhoid conjugate');
    });

    test('a deleted vaccination is no longer given', () async {
      await vaccines.markGiven(baby, codes: ['BCG'], givenOn: DateTime(2026, 5, 7));
      await vaccines.delete((await vaccines.watchGiven(baby.id).first).single.id);
      expect(await vaccines.watchGiven(baby.id).first, isEmpty);
    });
  });

  group('medicines', () {
    late MedicationRepository meds;
    setUp(() => meds = MedicationRepository(db));

    Future<Medication> addSyrup({bool asNeeded = false}) async {
      await meds.save(
        baby,
        name: 'Paracetamol syrup',
        prescribedDose: '2.5 ml',
        doseTimes: const [DoseTime(20, 0), DoseTime(8, 0)],
        asNeeded: asNeeded,
        startDate: DateTime(2026, 10, 20),
        endDate: DateTime(2026, 10, 27),
      );
      return (await meds.all(baby.id)).single;
    }

    test('dose times round-trip in order', () async {
      final m = await addSyrup();
      expect(m.doseTimes, const [DoseTime(8, 0), DoseTime(20, 0)]);
      expect((m.asNeeded, m.startDate, m.endDate), (false, DateTime(2026, 10, 20), DateTime(2026, 10, 27)));
    });

    test('an as-needed medicine has no dose times', () async {
      final m = await addSyrup(asNeeded: true);
      expect(m.asNeeded, isTrue);
      expect(m.doseTimes, isEmpty);
    });

    test('a dose given or skipped is recorded with what it was for, and can be undone', () async {
      final m = await addSyrup();
      final scheduled = at(today, 8);
      await meds.recordDose(baby, m, scheduledFor: scheduled);
      await meds.recordDose(baby, m, skipped: true);
      var doses = await meds.watchRecentDoses(baby.id).first;
      expect(doses.map((d) => d.skipped).toSet(), {true, false});
      expect(doses.firstWhere((d) => !d.skipped).scheduledFor, scheduled);

      await meds.undoDose(doses.first.id);
      doses = await meds.watchRecentDoses(baby.id).first;
      expect(doses, hasLength(1));
      expect(await meds.dosesSince(baby.id, today), hasLength(1));
    });

    test('a deleted medicine is gone from the list; other babies\' medicines never show', () async {
      final m = await addSyrup();
      await meds.save(sibling, name: 'Drops', prescribedDose: '1', doseTimes: const [], asNeeded: true, startDate: today);
      await meds.delete(m.id);
      expect(await meds.watchAll(baby.id).first, isEmpty);
    });
  });

  group('symptoms', () {
    test('saved with temperature, found within the window, editable, deletable', () async {
      final symptoms = SymptomRepository(db);
      await symptoms.save(baby, symptom: 'fever', occurredAt: at(today, 0, 30), temperatureC: 38.4, severity: 2);
      await symptoms.save(baby, symptom: 'cough', occurredAt: DateTime(_now.year, _now.month, _now.day - 20));
      await symptoms.save(sibling, symptom: 'rash', occurredAt: at(today, 0, 40));
      final recent = await symptoms.since(baby.id, DateTime(_now.year, _now.month, _now.day - 14));
      expect(recent.map((s) => (s.symptom, s.temperatureC)), [('fever', 38.4)]);

      await symptoms.save(baby, existingId: recent.single.id, symptom: 'fever', occurredAt: at(today, 0, 30), temperatureC: 39.0);
      expect((await symptoms.since(baby.id, today)).single.temperatureC, 39.0);

      await symptoms.delete(recent.single.id);
      expect(await symptoms.watchSince(baby.id, today).first, isEmpty);
    });
  });

  group('illnesses', () {
    late IllnessRepository illnesses;
    late SymptomRepository symptoms;
    late MedicationRepository meds;
    setUp(() {
      illnesses = IllnessRepository(db);
      symptoms = SymptomRepository(db);
      meds = MedicationRepository(db);
    });

    Future<String> startCold(DateTime start, {DateTime? recovered}) async {
      await illnesses.saveIllness(baby, name: 'Cold', startedAt: start, recoveredAt: recovered);
      return (await illnesses.watchAll(baby.id).first).first.id;
    }

    test('an episode has the symptoms, doses and visits from its start on', () async {
      final start = DateTime.now().subtract(const Duration(days: 2));
      await symptoms.save(baby, symptom: 'cough', occurredAt: start.subtract(const Duration(hours: 1)));
      final id = await startCold(start);
      await symptoms.save(baby, symptom: 'fever', occurredAt: start.add(const Duration(hours: 1)), temperatureC: 38.5);
      await symptoms.save(sibling, symptom: 'rash', occurredAt: start.add(const Duration(hours: 2)));
      await meds.save(baby, name: 'Syrup', prescribedDose: '2 ml', doseTimes: const [], asNeeded: true, startDate: start);
      await meds.recordDose(baby, (await meds.all(baby.id)).single);
      await illnesses.saveVisit(baby, visitedAt: start.add(const Duration(hours: 3)), doctor: 'Dr A', diagnosis: 'Cold');

      final episode = (await illnesses.episode(baby.id, id))!;
      expect(episode.symptoms.map((s) => s.symptom), ['fever'], reason: 'before the start and other babies are left out');
      expect(episode.doses.single.medicine, 'Syrup');
      expect(episode.visits.single.doctor, 'Dr A');
      expect(episode.illness.ongoing, isTrue);
    });

    test('after recovery, later symptoms are not part of it; reopening includes them again', () async {
      final start = DateTime.now().subtract(const Duration(days: 3));
      final recovered = DateTime.now().subtract(const Duration(days: 1));
      final id = await startCold(start, recovered: recovered);
      await symptoms.save(baby, symptom: 'cough', occurredAt: DateTime.now().subtract(const Duration(hours: 1)));
      expect((await illnesses.episode(baby.id, id))!.symptoms, isEmpty);

      await illnesses.setRecovered(id, null);
      final reopened = (await illnesses.episode(baby.id, id))!;
      expect((reopened.illness.ongoing, reopened.symptoms.length), (true, 1));
    });

    test('a deleted illness has no episode and leaves the list', () async {
      final id = await startCold(DateTime.now().subtract(const Duration(days: 1)));
      await illnesses.deleteIllness(id);
      expect(await illnesses.episode(baby.id, id), isNull);
      expect(await illnesses.watchAll(baby.id).first, isEmpty);
    });

    test('visits between two times, end excluded; deleted visits hidden', () async {
      await illnesses.saveVisit(baby, visitedAt: at(yesterday, 10), doctor: 'A');
      await illnesses.saveVisit(baby, visitedAt: at(today, 0), doctor: 'B');
      final visits = await illnesses.visitsBetween(baby.id, yesterday, today);
      expect(visits.map((v) => v.doctor), ['A']);
      await illnesses.deleteVisit(visits.single.id);
      expect(await illnesses.visitsBetween(baby.id, yesterday, today), isEmpty);
    });

    test('the episode watch updates when a symptom is logged', () async {
      final id = await startCold(DateTime.now().subtract(const Duration(hours: 5)));
      final stream = illnesses.watchEpisode(baby.id, id);
      final first = await stream.first;
      expect(first!.symptoms, isEmpty);
      final later = firstWhere(illnesses.watchEpisode(baby.id, id), (e) => (e?.symptoms.length ?? 0) == 1);
      await symptoms.save(baby, symptom: 'fever', occurredAt: DateTime.now().subtract(const Duration(hours: 1)));
      expect((await later)!.symptoms.single.symptom, 'fever');
    });
  });

  group('journal day', () {
    late JournalRepository journal;
    late TrackingRepository tracking;
    setUp(() {
      journal = JournalRepository(db);
      tracking = TrackingRepository(db);
    });

    test('a day runs from local midnight to midnight', () async {
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(yesterday, 0), amountMl: 1);
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(yesterday, 23, 59, 59), amountMl: 2);
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(today, 0), amountMl: 3);
      final y = await journal.load(baby.id, yesterday);
      expect(y.log.feeds.map((f) => f.amountMl).toSet(), {1, 2});
      final t = await journal.load(baby.id, today);
      expect(t.log.feeds.map((f) => f.amountMl), [3]);
    });

    test('a sleep crossing midnight is on both days; one ending at midnight only on the first', () async {
      await tracking.addSleep(baby, kind: SleepKind.night, startedAt: at(yesterday, 21), endedAt: at(today, 5));
      await tracking.addSleep(baby, kind: SleepKind.nap, startedAt: at(yesterday, 23), endedAt: at(today, 0));
      expect((await journal.load(baby.id, yesterday)).log.sleeps, hasLength(2));
      expect((await journal.load(baby.id, today)).log.sleeps, hasLength(1));
    });

    test('every kind of entry shows on its day, and only for this baby', () async {
      final day = yesterday;
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(day, 8), amountMl: 100);
      await tracking.saveDiaper(baby, at: at(day, 9), wet: true, dirty: false);
      await tracking.addSleep(baby, kind: SleepKind.nap, startedAt: at(day, 10), endedAt: at(day, 11));
      await MilkRepository(db).logPumping(baby, at: at(day, 12), amountMl: 80);
      final meds = MedicationRepository(db);
      await meds.save(baby, name: 'Drops', prescribedDose: '1', doseTimes: const [], asNeeded: true, startDate: day);
      await insertRow(db, 'medication_doses', {
        'family_id': baby.familyId,
        'baby_id': baby.id,
        'medication_id': (await meds.all(baby.id)).single.id,
        'given_at': at(day, 13).toUtc().toIso8601String(),
        'skipped': false,
      });
      await SymptomRepository(db).save(baby, symptom: 'fever', occurredAt: at(day, 14), temperatureC: 38.0);
      await SolidsRepository(db).saveTry(baby, foodId: 'egg', triedOn: day, reaction: 'none');
      await GrowthRepository(db).save(baby, measuredOn: day, weightG: 7000);
      await VaccineRepository(db).markGiven(baby, codes: ['BCG'], givenOn: day);
      await SolidsRepository(db).setMilestone(baby, 'x', null, reached: true); // today, not [day]
      await IllnessRepository(db).saveVisit(baby, visitedAt: at(day, 15), doctor: 'Dr A');
      // The sibling's entries on the same day must not appear.
      await tracking.saveFeed(sibling, type: FeedType.bottleFormula, at: at(day, 8), amountMl: 999);

      final j = await journal.load(baby.id, day);
      expect(j.log.feeds.map((f) => f.amountMl), [100]);
      expect(j.log.diapers, hasLength(1));
      expect(j.log.sleeps, hasLength(1));
      expect(j.pumping.single.amountMl, 80);
      expect(j.doses.single.medicine, 'Drops');
      expect(j.symptoms.single.symptom, 'fever');
      expect(j.foodTries.single.foodId, 'egg');
      expect(j.growth.single.weightG, 7000);
      expect(j.vaccinations.single.vaccineCode, 'BCG');
      expect(j.milestones, isEmpty, reason: 'the milestone was ticked today');
      expect(j.visits.single.doctor, 'Dr A');
      expect(j.isEmpty, isFalse);
      expect((await journal.load(baby.id, DateTime(day.year, day.month, day.day - 1))).isEmpty, isTrue);
    });

    test('deleted entries are left out of the journal', () async {
      await tracking.saveFeed(baby, type: FeedType.bottleFormula, at: at(yesterday, 8), amountMl: 100);
      final feed = (await journal.load(baby.id, yesterday)).log.feeds.single;
      await tracking.delete(TrackedTable.feeds, feed.id);
      expect((await journal.load(baby.id, yesterday)).isEmpty, isTrue);
    });

    test('the journal watch updates when something is logged that day', () async {
      final later = firstWhere(journal.watch(baby.id, yesterday), (j) => j.log.diapers.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tracking.saveDiaper(baby, at: at(yesterday, 9), wet: true, dirty: true);
      expect((await later).log.diapers.single.isDirty, isTrue);
    });
  });

  group('photos', () {
    late PhotoRepository photos;
    setUp(() {
      final folder = '${env.dir.path}/photos';
      photos = PhotoRepository(db, createPhotoQueue(db, env.supabase, folder), folder, env.supabase);
    });

    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 0xFF, 0xD9]);

    test('a photo is saved on the phone for its month, with its caption', () async {
      await photos.add(baby, ageMonth: 2, jpeg: jpeg, caption: 'First smile');
      final list = await firstWhere(photos.watchPhotos(baby.id), (l) => l.isNotEmpty);
      expect((list.single.ageMonth, list.single.caption), (2, 'First smile'));
      expect(list.single.localPath, isNotNull, reason: 'the file is on the phone straight away (offline)');
      await photos.updateCaption(list.single.id, 'Smile');
      expect((await photos.watchPhotos(baby.id).first).single.caption, 'Smile');
    });

    test('a second photo for the same month is refused (free plan: one a month)', () async {
      await photos.add(baby, ageMonth: 3, jpeg: jpeg);
      await expectLater(photos.add(baby, ageMonth: 3, jpeg: jpeg), throwsA(isA<PhotoLimitException>()));
      await photos.add(baby, ageMonth: 4, jpeg: jpeg);
      await photos.add(sibling, ageMonth: 3, jpeg: jpeg);
      expect(await photos.watchPhotos(baby.id).first, hasLength(2));
    });

    test('a deleted photo is hidden and its month is free again', () async {
      await photos.add(baby, ageMonth: 1, jpeg: jpeg);
      final p = (await firstWhere(photos.watchPhotos(baby.id), (l) => l.isNotEmpty)).single;
      await photos.delete(baby, p.id);
      expect(await firstWhere(photos.watchPhotos(baby.id), (l) => l.isEmpty), isEmpty);
      await photos.add(baby, ageMonth: 1, jpeg: jpeg);
    });
  });
}

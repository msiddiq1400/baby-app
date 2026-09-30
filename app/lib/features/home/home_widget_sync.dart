import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/l10n_lookup.dart';
import '../../core/providers.dart';
import '../../data/baby_repository.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../data/vaccine_repository.dart';
import '../../l10n/app_localizations.dart';
import '../health/vaccine_plan.dart';
import 'log_sheets.dart';
import 'timeline.dart';

/// What the home-screen widget shows, as the text values the Android side
/// (PalnaWidgetProvider.kt) reads. Times are epoch milliseconds as text;
/// null removes a value (and hides that row).
Map<String, String?> widgetValues({
  required AppLocalizations l10n,
  required DateTime now,
  Baby? baby,
  Feed? feedTimer,
  List<Feed> recentFeeds = const [],
  Sleep? ongoingSleep,
  List<Sleep> recentSleeps = const [],
  VaccineVisit? nextVisit,
}) {
  String ms(DateTime t) => '${t.millisecondsSinceEpoch}';
  final values = <String, String?>{
    'baby_name': baby?.name,
    'label_empty': l10n.widgetEmpty,
    'feed_label': null,
    'feed_since': null,
    'feed_detail': null,
    'sleep_label': null,
    'sleep_since': null,
    'vaccine': null,
  };
  if (baby == null) return values;

  if (feedTimer != null) {
    values
      ..['feed_label'] = l10n.feedingNowTitle
      ..['feed_since'] = ms(feedTimer.startedAt)
      ..['feed_detail'] = feedTimer.timerPaused ? l10n.feedTimerPaused : sideName(l10n, feedTimer.timerSide!);
  } else if (recentFeeds.isNotEmpty) {
    final last = recentFeeds.reduce((a, b) => a.startedAt.isAfter(b.startedAt) ? a : b);
    values
      ..['feed_label'] = l10n.widgetLastFeed
      ..['feed_since'] = ms(last.endedAt ?? last.startedAt)
      ..['feed_detail'] = feedEntryText(l10n, last, now);
  }

  if (ongoingSleep != null) {
    values
      ..['sleep_label'] = l10n.widgetAsleep
      ..['sleep_since'] = ms(ongoingSleep.startedAt);
  } else {
    final ended = recentSleeps.where((s) => s.endedAt != null).toList();
    if (ended.isNotEmpty) {
      final last = ended.reduce((a, b) => a.endedAt!.isAfter(b.endedAt!) ? a : b);
      // "Awake for 20 hours" would only confuse: sleep probably wasn't logged.
      if (now.difference(last.endedAt!).inHours < 12) {
        values
          ..['sleep_label'] = l10n.widgetAwake
          ..['sleep_since'] = ms(last.endedAt!);
      }
    }
  }

  if (nextVisit != null) {
    values['vaccine'] = l10n.widgetNextVaccine(
      visitLabel(l10n, nextVisit),
      DateFormat.MMMd(dateLocale(l10n)).format(nextVisit.dueDate),
    );
  }
  return values;
}

/// Keeps the Android home-screen widget up to date whenever anything it
/// shows changes. (iPhone widgets need a separate app extension: todo 37.)
final homeWidgetSyncProvider = FutureProvider<void>((ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final l10n = appL10n(ref.watch(localeProvider));
  final baby = await ref.watch(currentBabyProvider.future);
  final now = DateTime.now();
  var values = widgetValues(l10n: l10n, now: now);
  if (baby != null) {
    final schedule = await ref.watch(vaccineScheduleProvider.future);
    final given = await ref.watch(vaccinationsProvider(baby.id).future);
    final next = planVisits(baby.birthDate, schedule, given)
        .where((v) => v.status(now) != VisitStatus.done && v.dueDate.difference(now).inDays <= 30)
        .firstOrNull;
    values = widgetValues(
      l10n: l10n,
      now: now,
      baby: baby,
      feedTimer: await ref.watch(feedTimerProvider(baby.id).future),
      recentFeeds: await ref.watch(recentFeedsProvider(baby.id).future),
      ongoingSleep: (await ref.watch(todayLogProvider(baby.id).future)).ongoingSleep,
      recentSleeps: await ref.watch(recentSleepsProvider(baby.id).future),
      nextVisit: next,
    );
  }
  try {
    for (final e in values.entries) {
      await HomeWidget.saveWidgetData<String>(e.key, e.value);
    }
    await HomeWidget.updateWidget(qualifiedAndroidName: 'com.palnacare.app.PalnaWidgetProvider');
  } catch (e) {
    // No widget support (e.g. tests): nothing to update.
    debugPrint('Home widget: $e');
  }
});

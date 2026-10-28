import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/topic_icons.dart';
import '../../core/baby_age.dart';
import '../../core/providers.dart';
import '../../data/baby_repository.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import '../common/tab_title.dart';
import '../journal/journal_screen.dart';
import '../reports/reports_screen.dart';
import 'activity_sheet.dart';
import '../plans/paywall_screen.dart';
import '../plans/plan.dart';
import 'insights.dart';
import 'live_timers.dart';
import 'log_sheets.dart';
import 'sleep_predictions.dart';
import 'timeline.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final today = ref.watch(todayLogProvider(baby.id));

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => showBabySwitcher(context, ref),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(baby.name, overflow: TextOverflow.ellipsis)),
                  if ((ref.watch(babiesProvider).value?.length ?? 0) > 1) const Icon(Icons.arrow_drop_down),
                ],
              ),
              Text(
                formatBabyAge(l10n, baby.birthDate, now),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          // The full journal: every kind of entry, day by day. (Each card's
          // "Past days" shows only its own kind.)
          IconButton(
            icon: const Icon(TopicIcons.journal),
            tooltip: l10n.journalTitle,
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute<void>(builder: (_) => JournalScreen(baby: baby))),
          ),
          const MainActions(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(todayLogProvider(baby.id).future),
        child: switch (today) {
          AsyncData(:final value) => _TodayView(
              baby: baby,
              log: value,
              now: now,
              feedTimer: ref.watch(feedTimerProvider(baby.id)).value,
              recentFeeds: ref.watch(recentFeedsProvider(baby.id)).value ?? const [],
              recentSleeps: ref.watch(recentSleepsProvider(baby.id)).value ?? const [],
              isPro: ref.watch(isProProvider),
            ),
          AsyncError() => ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l10n.errorGeneric, textAlign: TextAlign.center),
                ),
              ],
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView({
    required this.baby,
    required this.log,
    required this.now,
    required this.recentFeeds,
    required this.recentSleeps,
    this.feedTimer,
    this.isPro = false,
  });

  final Baby baby;
  final TodayLog log;
  final DateTime now;
  final List<Feed> recentFeeds;
  final List<Sleep> recentSleeps;
  final Feed? feedTimer;

  /// Palna Pro: shows the next nap / bedtime.
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lastFeed = log.lastFeed;
    final ongoing = log.ongoingSleep;
    final hunger = hungerEstimate(recentFeeds);
    final usualSleep = usualDailySleep(recentSleeps, now);
    final wake = wakeWindow(recentSleeps, now);
    // The next nap or bedtime (Pro); only while awake.
    final prediction = ongoing == null
        ? predictNextSleep(birthDate: baby.birthDate, sleeps: recentSleeps, now: now)
        : null;
    String time(DateTime t) => TimeOfDay.fromDateTime(t).format(context);
    void openReport(ReportTab tab) => Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute<void>(builder: (_) => ReportsScreen(baby: baby, initialTab: tab)));
    // Past days of one kind, starting from yesterday (today is on this screen).
    void openPastDays(TrackedTable only) => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => JournalScreen(
              baby: baby,
              only: only,
              initialDay: DateTime(now.year, now.month, now.day - 1),
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (feedTimer case final feed?) FeedTimerCard(baby: baby, feed: feed),
        if (ongoing case final sleep?) SleepTimerCard(baby: baby, sleep: sleep),
        if (log.ongoingActivity case final activity?) ActivityTimerCard(baby: baby, activity: activity),
        // Compact cards: today's numbers and the usual pattern. Tapping one
        // opens its report tab; the small buttons add a past entry or show
        // past days of that kind.
        _SummaryCard(
          icon: TopicIcons.feed,
          title: l10n.feeds,
          value: '${log.feeds.length}',
          onTap: () => openReport(ReportTab.feeds),
          details: [
            [
              if (log.bottleMl > 0) l10n.bottleTotal(log.bottleMl),
              if (lastFeed != null)
                l10n.lastFeed(l10n.agoLabel(formatDuration(l10n, now.difference(lastFeed.endedAt ?? lastFeed.startedAt)))),
            ].join(' · '),
            if (hunger != null) l10n.nextFeedAround(TimeOfDay.fromDateTime(hunger.nextAround).format(context)),
          ],
          actions: [
            _CardButton(Icons.add, l10n.pastFeedShort, () => showFeedSheet(context, baby, past: true)),
            _CardButton(Icons.history, l10n.pastDays, () => openPastDays(TrackedTable.feeds)),
          ],
        ),
        _SummaryCard(
          icon: TopicIcons.sleep,
          title: l10n.sleep,
          value: formatDuration(l10n, log.sleptSince(now)),
          onTap: () => openReport(ReportTab.sleep),
          details: [
            [
              l10n.sleptToday,
              if (usualSleep != null) l10n.sleepUsualShort(formatDuration(l10n, usualSleep)),
            ].join(' · '),
            // While asleep, the sleep timer card above shows the time.
            if (ongoing == null)
              if (wake.awakeFor case final awake? when awake.inHours < 12) l10n.awakeFor(formatDuration(l10n, awake)),
            if (prediction case final p? when isPro) ...[
              switch ((p.kind, now.isBefore(p.from))) {
                (SleepPredictionKind.nap, true) => l10n.nextNapAround(time(p.from), time(p.to)),
                (SleepPredictionKind.nap, false) => l10n.napTimeNow(time(p.to)),
                (SleepPredictionKind.bedtime, true) => l10n.bedtimeAround(time(p.from), time(p.to)),
                (SleepPredictionKind.bedtime, false) => l10n.bedtimeNow(time(p.to)),
              },
              if (!p.personal) l10n.predictionFromAge,
            ],
          ],
          actions: [
            // Free: a way to see what the nap times are about.
            if (prediction != null && !isPro)
              _CardButton(
                Icons.lock_outline,
                l10n.napTimesShort,
                () => showPaywall(context, reason: l10n.proReasonPredictions),
              ),
            _CardButton(Icons.add, l10n.pastSleepShort, () => showSleepSheet(context, baby, past: true)),
            _CardButton(Icons.history, l10n.pastDays, () => openPastDays(TrackedTable.sleeps)),
          ],
        ),
        _SummaryCard(
          icon: TopicIcons.diaper,
          title: l10n.diapers,
          value: '${log.diapers.length}',
          onTap: () => openReport(ReportTab.diapers),
          details: [if (log.diapers.isNotEmpty) l10n.diaperCounts(log.wetCount, log.dirtyCount)],
          actions: [
            _CardButton(Icons.add, l10n.pastDiaperShort, () => showDiaperSheet(context, baby, past: true)),
            _CardButton(Icons.history, l10n.pastDays, () => openPastDays(TrackedTable.diapers)),
          ],
        ),
        _ActivitiesCard(baby: baby, log: log, now: now, onPastDays: () => openPastDays(TrackedTable.activities)),
        const SizedBox(height: 16),
        Text(l10n.todayTimeline, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Timeline(baby: baby, log: log, now: now),
      ],
    );
  }
}

/// Today's tummy time (the number), the other activities underneath, and
/// buttons to add one or start the tummy-time timer.
class _ActivitiesCard extends ConsumerWidget {
  const _ActivitiesCard({required this.baby, required this.log, required this.now, required this.onPastDays});

  final Baby baby;
  final TodayLog log;
  final DateTime now;
  final VoidCallback onPastDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tummy = log.timeOn(ActivityKind.tummyTime, now);
    // "Bath · Play 15m": each other kind once, with its total time if timed.
    final others = <String>[
      for (final kind in ActivityKind.values.where((k) => k != ActivityKind.tummyTime))
        if (log.activities.any((a) => a.kind == kind))
          switch (log.timeOn(kind, now)) {
            Duration.zero => activityName(l10n, kind),
            final d => '${activityName(l10n, kind)} ${formatDuration(l10n, d)}',
          },
    ];
    final timerRunning = log.ongoingActivity != null;
    return _SummaryCard(
      icon: activityIcon(ActivityKind.tummyTime),
      title: l10n.activities,
      value: tummy == Duration.zero ? '' : formatDuration(l10n, tummy),
      onTap: () => showActivitySheet(context, baby),
      details: [
        if (tummy > Duration.zero) l10n.tummyTimeToday,
        if (others.isNotEmpty) others.join(' · '),
        if (log.activities.isEmpty) l10n.activitiesNoneToday,
      ],
      actions: [
        _CardButton(Icons.add, l10n.activityShort, () => showActivitySheet(context, baby)),
        if (!timerRunning)
          _CardButton(
            Icons.timer_outlined,
            l10n.tummyTimer,
            () => ref
                .read(trackingRepositoryProvider)
                .startActivityTimer(baby, ActivityKind.tummyTime, at: DateTime.now())
                .then((_) => ref.invalidate(todayLogProvider(baby.id))),
          ),
        _CardButton(Icons.history, l10n.pastDays, onPastDays),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.details = const [],
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final List<String> details;

  /// Small labelled buttons at the bottom of the card.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final lines = details.where((d) => d.isNotEmpty);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                // Centred on the title line.
                padding: const EdgeInsets.only(top: 6),
                child: Icon(icon, size: 28, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and today's number, then the arrow to the report.
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(title, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 8),
                                // Long values (in Urdu, hours and minutes are
                                // long words) shrink to fit.
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 120),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(value, style: theme.textTheme.titleLarge),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: muted),
                        ],
                      ),
                    ),
                    for (final line in lines) Text(line, style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
                    if (actions.isNotEmpty)
                      Padding(
                        // Room for Urdu script, which draws below its line.
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Wrap(spacing: 4, children: actions),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small labelled button on a card ("+ Past feed", "Past days"): short
/// text, so the card stays compact; the card's title says what it's for.
class _CardButton extends StatelessWidget {
  const _CardButton(this.icon, this.label, this.onPressed);

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
}

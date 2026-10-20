import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_age.dart';
import '../../core/providers.dart';
import '../../data/baby_repository.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import '../journal/journal_screen.dart';
import '../reports/reports_screen.dart';
import 'insights.dart';
import 'live_timers.dart';
import 'log_sheets.dart';
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
          onTap: () => _showBabySwitcher(context, ref),
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
        actions: const [MainActions()],
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

/// Lists the babies to switch between (only when there's more than one).
void _showBabySwitcher(BuildContext context, WidgetRef ref) {
  final babies = ref.read(babiesProvider).value ?? const [];
  if (babies.length < 2) return;
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      // Clear of the phone's navigation buttons.
      minimum: const EdgeInsets.only(bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.switchBaby, style: Theme.of(context).textTheme.titleMedium),
          for (final b in babies)
            ListTile(
              leading: const Icon(Icons.child_care),
              title: Text(b.name),
              subtitle: Text(formatBabyAge(l10n, b.birthDate, DateTime.now())),
              onTap: () {
                selectBaby(ref, b.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}

class _TodayView extends StatelessWidget {
  const _TodayView({
    required this.baby,
    required this.log,
    required this.now,
    required this.recentFeeds,
    required this.recentSleeps,
    this.feedTimer,
  });

  final Baby baby;
  final TodayLog log;
  final DateTime now;
  final List<Feed> recentFeeds;
  final List<Sleep> recentSleeps;
  final Feed? feedTimer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lastFeed = log.lastFeed;
    final ongoing = log.ongoingSleep;
    final hunger = hungerEstimate(recentFeeds);
    final usualSleep = usualDailySleep(recentSleeps, now);
    final wake = wakeWindow(recentSleeps, now);
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
        // Compact cards: today's numbers and the usual pattern. Tapping one
        // opens its report tab; the small buttons add a past entry or show
        // past days of that kind.
        _SummaryCard(
          icon: Icons.local_drink_outlined,
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
          icon: Icons.bedtime_outlined,
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
          ],
          actions: [
            _CardButton(Icons.add, l10n.pastSleepShort, () => showSleepSheet(context, baby, past: true)),
            _CardButton(Icons.history, l10n.pastDays, () => openPastDays(TrackedTable.sleeps)),
          ],
        ),
        _SummaryCard(
          icon: Icons.baby_changing_station_outlined,
          title: l10n.diapers,
          value: '${log.diapers.length}',
          onTap: () => openReport(ReportTab.diapers),
          details: [if (log.diapers.isNotEmpty) l10n.diaperCounts(log.wetCount, log.dirtyCount)],
          actions: [
            _CardButton(Icons.add, l10n.pastDiaperShort, () => showDiaperSheet(context, baby, past: true)),
            _CardButton(Icons.history, l10n.pastDays, () => openPastDays(TrackedTable.diapers)),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.todayTimeline, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Timeline(baby: baby, log: log, now: now),
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

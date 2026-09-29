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
import 'glance_card.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: l10n.seeReports,
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute<void>(builder: (_) => ReportsScreen(baby: baby))),
          ),
          const LanguageMenu(showSignOut: true),
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
      bottomNavigationBar: _QuickActions(baby: baby, ongoingSleep: today.value?.ongoingSleep),
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
  const _TodayView({required this.baby, required this.log, required this.now, this.feedTimer});

  final Baby baby;
  final TodayLog log;
  final DateTime now;
  final Feed? feedTimer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lastFeed = log.lastFeed;
    final ongoing = log.ongoingSleep;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (feedTimer case final feed?) FeedTimerCard(baby: baby, feed: feed),
        if (ongoing case final sleep?) SleepTimerCard(baby: baby, sleep: sleep),
        GlanceCard(baby: baby, now: now),
        _SummaryCard(
          icon: Icons.local_drink_outlined,
          title: l10n.feeds,
          value: '${log.feeds.length}',
          details: [
            if (log.bottleMl > 0) l10n.bottleTotal(log.bottleMl),
            if (lastFeed != null)
              l10n.lastFeed(l10n.agoLabel(formatDuration(l10n, now.difference(lastFeed.endedAt ?? lastFeed.startedAt)))),
          ],
        ),
        _SummaryCard(
          icon: Icons.baby_changing_station_outlined,
          title: l10n.diapers,
          value: '${log.diapers.length}',
          details: [if (log.diapers.isNotEmpty) l10n.diaperCounts(log.wetCount, log.dirtyCount)],
        ),
        _SummaryCard(
          icon: Icons.bedtime_outlined,
          title: l10n.sleep,
          value: formatDuration(l10n, log.sleptSince(now)),
          details: [
            if (ongoing != null)
              l10n.sleepingSince(TimeOfDay.fromDateTime(ongoing.startedAt).format(context))
            else
              l10n.sleptToday,
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text(l10n.todayTimeline, style: Theme.of(context).textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute<void>(builder: (_) => JournalScreen(baby: baby))),
              icon: const Icon(Icons.history, size: 18),
              label: Text(l10n.pastDays),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Timeline(baby: baby, log: log, now: now),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.title, required this.value, this.details = const []});

  final IconData icon;
  final String title;
  final String value;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: details.isEmpty ? null : Text(details.join('\n')),
        // Long values (e.g. "13 گھنٹے 20 منٹ" in Urdu) shrink to fit rather
        // than squeezing out the title.
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: Text(value, style: theme.textTheme.headlineSmall),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.baby, required this.ongoingSleep});

  final Baby baby;
  final Sleep? ongoingSleep;

  Future<void> _toggleSleep(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(trackingRepositoryProvider);
    try {
      final sleep = ongoingSleep;
      if (sleep == null) {
        await repo.startSleep(baby, at: DateTime.now());
      } else {
        await repo.endSleep(sleep.id, at: DateTime.now());
      }
      ref.invalidate(todayLogProvider(baby.id));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asleep = ongoingSleep != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showFeedSheet(context, baby),
                icon: const Icon(Icons.local_drink),
                label: Text(l10n.logFeed),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showDiaperSheet(context, baby),
                icon: const Icon(Icons.baby_changing_station),
                label: Text(l10n.logDiaper),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _toggleSleep(context, ref),
                icon: Icon(asleep ? Icons.wb_sunny_outlined : Icons.bedtime),
                label: Text(asleep ? l10n.endSleep : l10n.startSleep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

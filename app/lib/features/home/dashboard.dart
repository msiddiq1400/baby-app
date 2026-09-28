import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_age.dart';
import '../../core/providers.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baby.name),
            Text(
              formatBabyAge(l10n, baby.birthDate, now),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: const [LanguageMenu(showSignOut: true)],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(todayLogProvider(baby.id).future),
        child: switch (today) {
          AsyncData(:final value) => _TodayView(log: value, now: now),
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

class _TodayView extends StatelessWidget {
  const _TodayView({required this.log, required this.now});

  final TodayLog log;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lastFeed = log.lastFeed;
    final ongoing = log.ongoingSleep;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
        Text(l10n.todayTimeline, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Timeline(log: log, now: now),
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
        trailing: Text(value, style: theme.textTheme.headlineSmall),
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

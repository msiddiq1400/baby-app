import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/l10n_lookup.dart';
import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../data/baby_repository.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import 'log_sheets.dart';

/// "12:05", or "1:02:05" past an hour.
String clockText(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  String two(int n) => n.toString().padLeft(2, '0');
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}

/// Rebuilds every second while shown, for running clocks.
class _Ticker extends StatefulWidget {
  const _Ticker({required this.builder});

  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, DateTime.now());
}

Future<void> _guard(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
    }
  }
}

/// The breastfeeding timer: a clock per side. Tap the other side to switch,
/// the running side to pause or resume; Finish saves the feed.
class FeedTimerCard extends ConsumerWidget {
  const FeedTimerCard({super.key, required this.baby, required this.feed});

  final Baby baby;
  final Feed feed;

  Future<void> _tapSide(BuildContext context, WidgetRef ref, BreastSide side) {
    final repo = ref.read(trackingRepositoryProvider);
    final now = DateTime.now();
    return _guard(context, () {
      if (side != feed.timerSide) return repo.switchFeedSide(feed, side, at: now);
      return feed.timerPaused ? repo.resumeFeedTimer(feed, at: now) : repo.pauseFeedTimer(feed, at: now);
    });
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.discardFeedConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.discardButton)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _guard(context, () => ref.read(trackingRepositoryProvider).delete(TrackedTable.feeds, feed.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      color: scheme.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: _Ticker(
          builder: (context, now) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: scheme.onPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feed.timerPaused ? l10n.feedTimerPaused : l10n.feedingNowTitle,
                      style: text.titleMedium?.copyWith(color: scheme.onPrimary),
                    ),
                  ),
                  Text(
                    clockText(feed.duration(now) ?? Duration.zero),
                    style: text.headlineSmall?.copyWith(color: scheme.onPrimary, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Left is on the left in every language: it's the mother's side.
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  for (final (i, side) in const [BreastSide.left, BreastSide.right].indexed) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _SideButton(
                        label: sideName(l10n, side),
                        time: clockText(Duration(seconds: feed.secondsOn(side, now))),
                        current: feed.timerSide == side,
                        running: feed.timerSide == side && !feed.timerPaused,
                        onTap: () => _tapSide(context, ref, side),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.feedTimerHelp,
                style: text.bodySmall?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: scheme.onPrimary),
                    onPressed: () => _discard(context, ref),
                    child: Text(l10n.discardButton),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: scheme.onPrimary, foregroundColor: scheme.primary),
                    onPressed: () => _guard(
                      context,
                      () => ref.read(trackingRepositoryProvider).finishFeedTimer(feed, at: DateTime.now()),
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(l10n.finishFeed),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.label,
    required this.time,
    required this.current,
    required this.running,
    required this.onTap,
  });

  final String label;
  final String time;
  final bool current;
  final bool running;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fg = current ? scheme.primary : scheme.onPrimary;
    return Material(
      color: current ? scheme.onPrimary : scheme.onPrimary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded, color: fg, size: 20),
                  const SizedBox(width: 4),
                  Flexible(child: Text(label, style: text.titleSmall?.copyWith(color: fg), overflow: TextOverflow.ellipsis)),
                ],
              ),
              Text(
                time,
                style: text.titleLarge?.copyWith(color: fg, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A sleep that's going: a running clock and "Woke up".
class SleepTimerCard extends ConsumerWidget {
  const SleepTimerCard({super.key, required this.baby, required this.sleep});

  final Baby baby;
  final Sleep sleep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      color: scheme.secondaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showSleepSheet(context, baby, sleep),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.bedtime, color: scheme.onSecondaryContainer, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sleep.kind == SleepKind.night ? l10n.asleepNight : l10n.asleepNap,
                      style: text.titleMedium?.copyWith(color: scheme.onSecondaryContainer),
                    ),
                    _Ticker(
                      builder: (context, now) => Text(
                        clockText(now.difference(sleep.startedAt)),
                        style: text.headlineSmall?.copyWith(
                          color: scheme.onSecondaryContainer,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Text(
                      l10n.sleepingSince(TimeOfDay.fromDateTime(sleep.startedAt).format(context)),
                      style: text.bodySmall?.copyWith(color: scheme.onSecondaryContainer),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _guard(context, () async {
                  await ref.read(trackingRepositoryProvider).endSleep(sleep.id, at: DateTime.now());
                  ref.invalidate(todayLogProvider(baby.id));
                }),
                icon: const Icon(Icons.wb_sunny_outlined),
                label: Text(l10n.endSleep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps the "timer running" notifications in step with the feed timer and
/// the sleep that are going, including ones started on another phone.
final timerNotificationsProvider = FutureProvider<void>((ref) async {
  final baby = await ref.watch(currentBabyProvider.future);
  if (baby == null) {
    await TimerNotifications.cancel('feed');
    await TimerNotifications.cancel('sleep');
    return;
  }
  final l10n = appL10n(ref.watch(localeProvider));
  final feed = await ref.watch(feedTimerProvider(baby.id).future);
  final sleep = (await ref.watch(todayLogProvider(baby.id).future)).ongoingSleep;
  final now = DateTime.now();

  if (feed == null) {
    await TimerNotifications.cancel('feed');
  } else {
    final side = sideName(l10n, feed.timerSide!);
    final total = feed.duration(now) ?? Duration.zero;
    await TimerNotifications.show(
      'feed',
      title: l10n.feedingNotificationTitle(baby.name),
      body: feed.timerPaused ? '${l10n.feedTimerPaused} · ${clockText(total)}' : side,
      runningSince: feed.timerPaused ? null : now.subtract(total),
    );
  }

  if (sleep == null) {
    await TimerNotifications.cancel('sleep');
  } else {
    await TimerNotifications.show(
      'sleep',
      title: l10n.sleepNotificationTitle(baby.name),
      body: l10n.sleepingSince(DateFormat.jm(dateLocale(l10n)).format(sleep.startedAt)),
      runningSince: sleep.startedAt,
    );
  }
});

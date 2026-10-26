import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/topic_icons.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import 'log_sheets.dart';

/// Feed, Diaper and Sleep buttons, shown above the tabs on every screen so
/// the three most common entries are always one tap away.
class QuickLogBar extends ConsumerWidget {
  const QuickLogBar({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ongoing = ref.watch(todayLogProvider(baby.id)).value?.ongoingSleep;
    // Keeps recent feeds loaded, so the feed form can start as the last feed.
    ref.watch(recentFeedsProvider(baby.id));

    return Material(
      color: Theme.of(context).navigationBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showFeedSheet(context, baby),
                icon: const Icon(TopicIcons.feedFilled),
                label: Text(l10n.logFeed, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showDiaperSheet(context, baby),
                icon: const Icon(TopicIcons.diaperFilled),
                label: Text(l10n.logDiaper, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                // Opens the form (time, nap or night); nothing starts or ends
                // until Save.
                onPressed: () => ongoing == null
                    ? showSleepSheet(context, baby)
                    : showSleepSheet(context, baby, existing: ongoing, wakingUp: true),
                icon: Icon(ongoing != null ? Icons.wb_sunny_outlined : TopicIcons.sleepFilled),
                label: Text(ongoing != null ? l10n.endSleep : l10n.startSleep, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

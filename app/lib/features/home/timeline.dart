import 'package:flutter/material.dart';

import '../../app/topic_icons.dart';
import '../../core/baby_age.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'activity_sheet.dart';
import 'log_sheets.dart';

/// Today's feeds, diapers, sleeps and activities in one list, newest first.
/// Tapping an entry opens it for editing.
class Timeline extends StatelessWidget {
  const Timeline({super.key, required this.baby, required this.log, required this.now});

  final Baby baby;
  final TodayLog log;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <(DateTime, IconData, String, VoidCallback)>[
      for (final f in log.feeds)
        (f.startedAt, TopicIcons.feed, feedEntryText(l10n, f, now), () => showFeedSheet(context, baby, existing: f)),
      for (final d in log.diapers)
        (
          d.occurredAt,
          TopicIcons.diaper,
          diaperEntryText(l10n, d),
          () => showDiaperSheet(context, baby, existing: d),
        ),
      for (final s in log.sleeps)
        (s.startedAt, TopicIcons.sleep, sleepEntryText(l10n, s), () => showSleepSheet(context, baby, existing: s)),
      for (final a in log.activities)
        (
          a.startedAt,
          activityIcon(a.kind),
          activityEntryText(l10n, a, now),
          () => showActivitySheet(context, baby, existing: a),
        ),
    ]..sort((a, b) => b.$1.compareTo(a.$1));

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(l10n.nothingLoggedToday, textAlign: TextAlign.center),
      );
    }

    return Column(
      children: [
        for (final (time, icon, text, onTap) in entries)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(text),
            trailing: Text(TimeOfDay.fromDateTime(time).format(context)),
            onTap: onTap,
          ),
      ],
    );
  }
}

// How entries read in lists (Today and the journal).

String feedEntryText(AppLocalizations l10n, Feed f, DateTime now) {
  final left = f.secondsOn(BreastSide.left, now);
  final right = f.secondsOn(BreastSide.right, now);
  final parts = [
    switch (f.type) {
      FeedType.breast => l10n.feedTypeBreast,
      FeedType.bottleBreastMilk => l10n.feedTypeBottleBreastMilk,
      FeedType.bottleFormula || FeedType.solids => l10n.feedTypeFormula,
    },
    if (f.timerActive)
      l10n.feedingNow
    else if (left > 0 && right > 0)
      '${l10n.sideLeft} ${formatDuration(l10n, Duration(seconds: left))} + '
          '${l10n.sideRight} ${formatDuration(l10n, Duration(seconds: right))}'
    else ...[
      if (f.side != null) sideName(l10n, f.side!),
      if (f.duration(now) case final d? when d.inMinutes > 0) formatDuration(l10n, d),
    ],
    if (f.amountMl != null) '${f.amountMl} ml',
  ];
  return parts.join(' · ');
}

String diaperEntryText(AppLocalizations l10n, Diaper d) => [
      l10n.logDiaper,
      [if (d.isWet) l10n.diaperWet, if (d.isDirty) l10n.diaperDirty].join(' + '),
    ].join(' · ');

String sleepEntryText(AppLocalizations l10n, Sleep s) => [
      s.kind == SleepKind.night ? l10n.sleepNight : l10n.sleepNap,
      s.endedAt == null ? l10n.sleepingNow : formatDuration(l10n, s.endedAt!.difference(s.startedAt)),
    ].join(' · ');

String activityEntryText(AppLocalizations l10n, Activity a, DateTime now) => [
      activityTitle(l10n, a),
      if (a.isOngoing)
        l10n.activityRunning
      else if (a.duration(now) case final d?)
        formatDuration(l10n, d),
    ].join(' · ');

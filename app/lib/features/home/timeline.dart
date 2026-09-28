import 'package:flutter/material.dart';

import '../../core/baby_age.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'log_sheets.dart';

/// Today's feeds, diapers and sleeps in one list, newest first.
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
        (f.startedAt, Icons.local_drink_outlined, _feedText(l10n, f), () => showFeedSheet(context, baby, existing: f)),
      for (final d in log.diapers)
        (
          d.occurredAt,
          Icons.baby_changing_station_outlined,
          _diaperText(l10n, d),
          () => showDiaperSheet(context, baby, existing: d),
        ),
      for (final s in log.sleeps)
        (s.startedAt, Icons.bedtime_outlined, _sleepText(l10n, s), () => showSleepSheet(context, baby, s)),
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

  String _feedText(AppLocalizations l10n, Feed f) {
    final parts = [
      switch (f.type) {
        FeedType.breast => l10n.feedTypeBreast,
        FeedType.bottleBreastMilk => l10n.feedTypeBottleBreastMilk,
        FeedType.bottleFormula || FeedType.solids => l10n.feedTypeFormula,
      },
      if (f.side != null) _sideText(l10n, f.side!),
      if (f.amountMl != null) '${f.amountMl} ml',
      if (f.endedAt != null && f.endedAt!.isAfter(f.startedAt))
        formatDuration(l10n, f.endedAt!.difference(f.startedAt)),
    ];
    return parts.join(' · ');
  }

  String _sideText(AppLocalizations l10n, BreastSide side) => switch (side) {
        BreastSide.left => l10n.sideLeft,
        BreastSide.right => l10n.sideRight,
        BreastSide.both => l10n.sideBoth,
      };

  String _diaperText(AppLocalizations l10n, Diaper d) => [
        l10n.logDiaper,
        [if (d.isWet) l10n.diaperWet, if (d.isDirty) l10n.diaperDirty].join(' + '),
      ].join(' · ');

  String _sleepText(AppLocalizations l10n, Sleep s) => [
        s.kind == SleepKind.night ? l10n.sleepNight : l10n.sleepNap,
        s.endedAt == null ? l10n.sleepingNow : formatDuration(l10n, s.endedAt!.difference(s.startedAt)),
      ].join(' · ');
}

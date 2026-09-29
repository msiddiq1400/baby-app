import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/who_growth.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/solids_repository.dart';
import '../../l10n/app_localizations.dart';

String _areaName(AppLocalizations l10n, String area) => switch (area) {
      'social' => l10n.areaSocial,
      'language' => l10n.areaLanguage,
      'cognitive' => l10n.areaCognitive,
      _ => l10n.areaMovement,
    };

IconData _areaIcon(String area) => switch (area) {
      'social' => Icons.favorite_outline,
      'language' => Icons.record_voice_over_outlined,
      'cognitive' => Icons.lightbulb_outline,
      _ => Icons.directions_run,
    };

/// CDC milestone checklists by age: the baby's current checklist opens
/// first; tick what they can do; activities to help; when to see a doctor.
class MilestonesView extends ConsumerWidget {
  const MilestonesView({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final guide = ref.watch(milestoneGuideProvider).value;
    final checks = ref.watch(milestoneChecksProvider(baby.id)).value ?? const {};
    if (guide == null) return const Center(child: CircularProgressIndicator());

    // The checklist for the next age the baby is working towards.
    final ageMonths = WhoGrowth.ageInMonths(baby.birthDate, DateTime.now());
    final current = guide.ages.firstWhere((a) => a.months >= ageMonths, orElse: () => guide.ages.last);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(guide.intro.of(l10n), style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        for (final age in guide.ages)
          Card(
            child: ExpansionTile(
              initiallyExpanded: age == current,
              shape: const Border(),
              title: Text(l10n.byMonths(age.months)),
              subtitle: Text(l10n.milestonesProgress(
                age.milestones.where((m) => checks.containsKey(m.id)).length,
                age.milestones.length,
              )),
              children: [
                for (final area in const ['social', 'language', 'cognitive', 'movement'])
                  if (age.milestones.any((m) => m.area == area)) ...[
                    ListTile(
                      dense: true,
                      leading: Icon(_areaIcon(area), color: theme.colorScheme.primary),
                      title: Text(_areaName(l10n, area), style: theme.textTheme.titleSmall),
                    ),
                    for (final m in age.milestones.where((m) => m.area == area))
                      CheckboxListTile(
                        dense: true,
                        value: checks.containsKey(m.id),
                        title: Text(m.text.of(l10n)),
                        subtitle: checks[m.id] == null
                            ? null
                            : Text(l10n.reachedOn(MaterialLocalizations.of(context).formatMediumDate(checks[m.id]!.achievedOn))),
                        onChanged: (v) => ref
                            .read(solidsRepositoryProvider)
                            .setMilestone(baby, m.id, checks[m.id], reached: v ?? false),
                      ),
                  ],
                ListTile(
                  leading: const Icon(Icons.toys_outlined),
                  title: Text(l10n.waysToHelp, style: theme.textTheme.titleSmall),
                ),
                for (final tip in age.tips)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(alignment: AlignmentDirectional.centerStart, child: Text('• ${tip.of(l10n)}')),
                  ),
              ],
            ),
          ),
        Card(
          color: theme.colorScheme.tertiaryContainer,
          child: ListTile(
            leading: const Icon(Icons.medical_services_outlined),
            title: Text(l10n.actEarlyTitle),
            subtitle: Text(guide.actEarly.of(l10n)),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.sourcesLabel(guide.source), style: theme.textTheme.bodySmall),
      ],
    );
  }
}

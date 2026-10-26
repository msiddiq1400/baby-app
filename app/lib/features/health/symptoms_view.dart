import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/topic_icons.dart';
import '../../data/models.dart';
import '../../data/symptom_repository.dart';
import '../../l10n/app_localizations.dart';
import 'doctor_summary.dart';
import 'illness_screen.dart';
import 'symptom_sheet.dart';

/// Symptoms tab: illnesses, then the last 14 days of symptoms by day.
class SymptomsView extends ConsumerWidget {
  const SymptomsView({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final symptoms = ref.watch(recentSymptomsProvider(baby.id));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(recentSymptomsProvider(baby.id).future),
      child: switch (symptoms) {
        AsyncData(:final value) => _SymptomList(baby: baby, logs: value),
        AsyncError() => ListView(
            children: [
              Padding(padding: const EdgeInsets.all(32), child: Text(l10n.errorGeneric, textAlign: TextAlign.center)),
            ],
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _SymptomList extends StatelessWidget {
  const _SymptomList({required this.baby, required this.logs});

  final Baby baby;

  /// Newest first.
  final List<SymptomLog> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dates = MaterialLocalizations.of(context);
    DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        IllnessSection(baby: baby),
        const SizedBox(height: 16),
        // The doctor summary is at the top of the Health tab.
        FilledButton.icon(
          onPressed: () => showSymptomSheet(context, baby),
          icon: const Icon(Icons.add),
          label: Text(l10n.logSymptom),
        ),
        if (logs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.noSymptoms, textAlign: TextAlign.center),
          ),
        for (final (i, log) in logs.indexed) ...[
          if (i == 0 || dayOf(logs[i - 1].occurredAt) != dayOf(log.occurredAt))
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Text(dates.formatFullDate(log.occurredAt), style: theme.textTheme.titleSmall),
            ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(TopicIcons.symptom),
            title: Text(
              [
                symptomName(l10n, log.symptom),
                if (log.temperatureC case final t?) displayTemperature(t),
                if (log.severity case final s?) severityName(l10n, s),
              ].join(' · '),
            ),
            subtitle: log.notes == null ? null : Text(log.notes!),
            trailing: Text(TimeOfDay.fromDateTime(log.occurredAt).format(context)),
            onTap: () => showSymptomSheet(context, baby, existing: log),
          ),
        ],
      ],
    );
  }
}

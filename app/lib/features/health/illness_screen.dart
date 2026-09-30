import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/illness_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'doctor_summary.dart';
import 'illness_sheets.dart';
import 'symptom_sheet.dart';

String illnessTitle(AppLocalizations l10n, Illness illness) =>
    (illness.name ?? '').trim().isEmpty ? l10n.illnessUnnamed : illness.name!.trim();

/// Top of the Symptoms tab: the illness going on now (Day 3 of a cold...),
/// or a button to start tracking one, and the last few past illnesses.
class IllnessSection extends ConsumerWidget {
  const IllnessSection({super.key, required this.baby});

  final Baby baby;

  void _open(BuildContext context, Illness illness) => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(builder: (_) => IllnessScreen(baby: baby, illnessId: illness.id)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dates = MaterialLocalizations.of(context);
    final illnesses = ref.watch(illnessesProvider(baby.id)).value ?? const <Illness>[];
    final current = illnesses.where((i) => i.ongoing).firstOrNull;
    final past = illnesses.where((i) => !i.ongoing).take(3).toList();
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (current != null)
          _CurrentIllnessCard(baby: baby, illness: current, onOpen: () => _open(context, current))
        else
          OutlinedButton.icon(
            onPressed: () => showIllnessSheet(context, baby),
            icon: const Icon(Icons.sick_outlined),
            label: Text(l10n.startIllnessButton),
          ),
        for (final i in past)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(illnessTitle(l10n, i)),
            subtitle: Text(
              '${dates.formatShortMonthDay(i.startedAt)} – ${dates.formatShortMonthDay(i.recoveredAt!)} · '
              '${l10n.illnessLasted(i.days(now))}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, i),
          ),
      ],
    );
  }
}

class _CurrentIllnessCard extends ConsumerWidget {
  const _CurrentIllnessCard({required this.baby, required this.illness, required this.onOpen});

  final Baby baby;
  final Illness illness;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final episode = ref.watch(illnessEpisodeProvider((babyId: baby.id, illnessId: illness.id))).value;
    final last = episode?.lastTemperature;
    final doses = episode?.dosesOn(now) ?? 0;
    final codes = episode?.symptomCodes ?? const <String>[];

    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.55),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sick_outlined, color: scheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.illnessDay(illness.dayNumber(now))} · ${illnessTitle(l10n, illness)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              Text(
                l10n.illnessStartedOn(MaterialLocalizations.of(context).formatMediumDate(illness.startedAt)),
                style: theme.textTheme.bodySmall,
              ),
              if (codes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in codes.take(4))
                      Chip(label: Text(symptomName(l10n, c)), visualDensity: VisualDensity.compact),
                  ],
                ),
              ],
              if (last != null) ...[
                const SizedBox(height: 6),
                Text(l10n.lastTemperature(
                  displayTemperature(last.temperatureC!),
                  TimeOfDay.fromDateTime(last.occurredAt).format(context),
                )),
              ],
              if (doses > 0) Text(l10n.dosesToday(doses)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => showSymptomSheet(context, baby),
                    icon: const Icon(Icons.thermostat_outlined),
                    label: Text(l10n.logSymptom),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => showDoctorVisitSheet(context, baby),
                    icon: const Icon(Icons.local_hospital_outlined),
                    label: Text(l10n.doctorVisit),
                  ),
                  FilledButton.icon(
                    onPressed: () => ref.read(illnessRepositoryProvider).setRecovered(illness.id, DateTime.now()),
                    icon: const Icon(Icons.check),
                    label: Text(l10n.markRecovered),
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

/// One illness, day by day (newest day first): symptoms and temperatures,
/// medicine doses and doctor's visits.
class IllnessScreen extends ConsumerWidget {
  const IllnessScreen({super.key, required this.baby, required this.illnessId});

  final Baby baby;
  final String illnessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final episode = ref.watch(illnessEpisodeProvider((babyId: baby.id, illnessId: illnessId)));

    return switch (episode) {
      AsyncData(value: final e?) => _EpisodeView(baby: baby, episode: e),
      // Deleted (or not synced yet).
      AsyncData() => Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.errorGeneric))),
      AsyncError() => Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.errorGeneric))),
      _ => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
    };
  }
}

class _EpisodeView extends ConsumerWidget {
  const _EpisodeView({required this.baby, required this.episode});

  final Baby baby;
  final IllnessEpisode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dates = MaterialLocalizations.of(context);
    final illness = episode.illness;
    final now = DateTime.now();
    String time(DateTime t) => TimeOfDay.fromDateTime(t).format(context);

    // Everything with a time, grouped by illness day.
    final entries = <(DateTime, IconData, String, String?, VoidCallback?)>[
      for (final s in episode.symptoms)
        (
          s.occurredAt,
          Icons.thermostat_outlined,
          [
            symptomName(l10n, s.symptom),
            if (s.temperatureC != null) displayTemperature(s.temperatureC!),
            if (s.severity != null) severityName(l10n, s.severity!),
          ].join(' · '),
          s.notes,
          () => showSymptomSheet(context, baby, existing: s),
        ),
      for (final (:dose, :medicine) in episode.doses)
        (dose.givenAt, Icons.medication_outlined, '$medicine · ${dose.skipped ? l10n.doseSkipped : l10n.doseGiven}', null, null),
      for (final v in episode.visits)
        (
          v.visitedAt,
          Icons.local_hospital_outlined,
          [l10n.doctorVisit, if (v.doctor != null) v.doctor!, if (v.diagnosis != null) v.diagnosis!].join(' · '),
          v.advice,
          () => showDoctorVisitSheet(context, baby, existing: v),
        ),
    ];
    final lastDay = illness.days(now);
    final days = [
      for (var d = lastDay; d >= 1; d--)
        (
          d,
          DateTime(illness.startedAt.year, illness.startedAt.month, illness.startedAt.day + d - 1),
          [
            for (final e in entries)
              if (illness.dayNumber(e.$1) == d) e,
          ]..sort((a, b) => b.$1.compareTo(a.$1)),
        ),
    ];
    final highest = episode.highestTemperature;

    return Scaffold(
      appBar: AppBar(
        title: Text(illnessTitle(l10n, illness)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editIllness,
            onPressed: () => showIllnessSheet(context, baby, existing: illness),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    illness.ongoing ? l10n.illnessDay(lastDay) : l10n.illnessLasted(lastDay),
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    illness.ongoing
                        ? l10n.illnessStartedOn(dates.formatMediumDate(illness.startedAt))
                        : '${dates.formatMediumDate(illness.startedAt)} – ${dates.formatMediumDate(illness.recoveredAt!)}',
                  ),
                  if (highest != null) Text(l10n.highestTemperature(displayTemperature(highest.temperatureC!))),
                  if (episode.visits.isNotEmpty) Text(l10n.doctorVisitsCount(episode.visits.length)),
                  if ((illness.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(illness.notes!, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => showSymptomSheet(context, baby),
                        icon: const Icon(Icons.thermostat_outlined),
                        label: Text(l10n.logSymptom),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => showDoctorVisitSheet(context, baby),
                        icon: const Icon(Icons.local_hospital_outlined),
                        label: Text(l10n.doctorVisit),
                      ),
                      if (illness.ongoing)
                        FilledButton.icon(
                          onPressed: () => ref.read(illnessRepositoryProvider).setRecovered(illness.id, DateTime.now()),
                          icon: const Icon(Icons.check),
                          label: Text(l10n.markRecovered),
                        )
                      else
                        OutlinedButton(
                          onPressed: () => ref.read(illnessRepositoryProvider).setRecovered(illness.id, null),
                          child: Text(l10n.stillUnwell),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          for (final (number, date, list) in days) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
              child: Text(
                '${l10n.illnessDay(number)} · ${dates.formatMediumDate(date)}',
                style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(l10n.nothingThisDay, style: theme.textTheme.bodySmall),
              ),
            for (final (at, icon, text, detail, onTap) in list)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(text),
                subtitle: detail == null ? null : Text(detail),
                trailing: Text(time(at)),
                onTap: onTap,
              ),
          ],
        ],
      ),
    );
  }
}

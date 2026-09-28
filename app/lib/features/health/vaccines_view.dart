import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/vaccine_repository.dart';
import '../../l10n/app_localizations.dart';
import 'vaccination_sheet.dart';
import 'vaccine_plan.dart';

/// Vaccines tab: the schedule as clinic visits, with doses to record.
class VaccinesView extends ConsumerWidget {
  const VaccinesView({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final schedule = ref.watch(vaccineScheduleProvider);
    final given = ref.watch(vaccinationsProvider(baby.id));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(vaccinationsProvider(baby.id).future),
      child: switch ((schedule, given)) {
        (AsyncData(value: final schedule), AsyncData(value: final given)) =>
          _VisitList(baby: baby, visits: planVisits(baby.birthDate, schedule, given)),
        (AsyncError(), _) || (_, AsyncError()) => ListView(
            children: [
              Padding(padding: const EdgeInsets.all(32), child: Text(l10n.errorGeneric, textAlign: TextAlign.center)),
            ],
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _VisitList extends StatelessWidget {
  const _VisitList({required this.baby, required this.visits});

  final Baby baby;
  final List<VaccineVisit> visits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = DateTime.now();
    final dates = MaterialLocalizations.of(context);
    final next = visits.where((v) => v.status(today) != VisitStatus.done).firstOrNull;
    final anyOverdue = visits.any((v) => v.status(today) == VisitStatus.overdue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.event_available, color: theme.colorScheme.primary),
            title: Text(
              next == null
                  ? l10n.allVaccinesDone
                  : l10n.nextVisit(visitLabel(l10n, next), dates.formatMediumDate(next.dueDate)),
            ),
            subtitle: Text(l10n.vaccineScheduleNote),
          ),
        ),
        if (anyOverdue)
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.catchUpNote, style: TextStyle(color: theme.colorScheme.onTertiaryContainer)),
            ),
          ),
        const SizedBox(height: 8),
        for (final visit in visits) _VisitCard(baby: baby, visit: visit, today: today),
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.baby, required this.visit, required this.today});

  final Baby baby;
  final VaccineVisit visit;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dates = MaterialLocalizations.of(context);
    final status = visit.status(today);
    final pending = visit.pending;

    final (statusText, statusColor) = switch (status) {
      VisitStatus.done => (l10n.statusDone, theme.colorScheme.primary),
      VisitStatus.overdue => (l10n.statusOverdue, theme.colorScheme.error),
      VisitStatus.dueSoon => (l10n.statusDueSoon, theme.colorScheme.tertiary),
      VisitStatus.upcoming => (l10n.statusUpcoming, theme.colorScheme.outline),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visitLabel(l10n, visit), style: theme.textTheme.titleMedium),
                      Text(l10n.dueOn(dates.formatMediumDate(visit.dueDate)), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(statusText, style: theme.textTheme.labelLarge?.copyWith(color: statusColor)),
                ),
              ],
            ),
            for (final dose in visit.doses)
              if (visit.given[dose.code] case final given?)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  title: Text(doseTitle(dose)),
                  subtitle: Text(l10n.givenOn(dates.formatMediumDate(given.givenOn))),
                  onTap: () => showEditVaccinationSheet(context, baby, dose, given),
                )
              else
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.radio_button_unchecked),
                  title: Text(doseTitle(dose)),
                  trailing: TextButton(
                    onPressed: () => showRecordVaccinationSheet(context, baby, [dose]),
                    child: Text(l10n.markGiven),
                  ),
                ),
            if (pending.length > 1 && status != VisitStatus.upcoming)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  onPressed: () => showRecordVaccinationSheet(context, baby, pending),
                  child: Text(l10n.markVisitGiven),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

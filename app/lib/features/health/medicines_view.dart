import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/medication_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'medicine_plan.dart';
import 'medicine_sheet.dart';

/// Medicines tab: today's doses with Given / Skip, plus finished medicines.
class MedicinesView extends ConsumerWidget {
  const MedicinesView({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final medications = ref.watch(medicationsProvider(baby.id));
    final doses = ref.watch(recentDosesProvider(baby.id));

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        ref.refresh(medicationsProvider(baby.id).future),
        ref.refresh(recentDosesProvider(baby.id).future),
      ]),
      child: switch ((medications, doses)) {
        (AsyncData(value: final meds), AsyncData(value: final doses)) =>
          _MedicineList(baby: baby, medications: meds, doses: doses),
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

class _MedicineList extends StatelessWidget {
  const _MedicineList({required this.baby, required this.medications, required this.doses});

  final Baby baby;
  final List<Medication> medications;
  final List<MedicationDose> doses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final finished = [for (final m in medications) if (m.endDate != null && m.endDate!.isBefore(day)) m];
    final current = [for (final m in medications) if (!finished.contains(m)) m];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.medicineSafetyNote, style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => showMedicineSheet(context, baby),
          icon: const Icon(Icons.add),
          label: Text(l10n.addMedicine),
        ),
        const SizedBox(height: 8),
        if (current.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.noMedicines, textAlign: TextAlign.center),
          ),
        for (final med in current) _MedicineCard(baby: baby, medication: med, doses: doses, now: today),
        if (finished.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('${l10n.finishedMedicines} (${finished.length})'),
            children: [
              for (final med in finished)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(med.name),
                  subtitle: Text(_summary(context, med)),
                  onTap: () => showMedicineSheet(context, baby, existing: med),
                ),
            ],
          ),
      ],
    );
  }
}

/// "2.5 ml · 9:00 AM, 9:00 PM · Until 5 Oct"
String _summary(BuildContext context, Medication med) {
  final l10n = AppLocalizations.of(context);
  final schedule = med.asNeeded
      ? l10n.scheduleAsNeeded
      : med.doseTimes.map((t) => TimeOfDay(hour: t.hour, minute: t.minute).format(context)).join(', ');
  final until = med.endDate == null
      ? l10n.ongoing
      : l10n.untilDate(MaterialLocalizations.of(context).formatMediumDate(med.endDate!));
  return [med.prescribedDose, schedule, until].join(' · ');
}

class _MedicineCard extends ConsumerWidget {
  const _MedicineCard({required this.baby, required this.medication, required this.doses, required this.now});

  final Baby baby;
  final Medication medication;
  final List<MedicationDose> doses;
  final DateTime now;

  Future<void> _act(BuildContext context, WidgetRef ref, Future<void> Function(MedicationRepository repo) action) async {
    try {
      await action(ref.read(medicationRepositoryProvider));
      ref.invalidate(recentDosesProvider(baby.id));
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
    final theme = Theme.of(context);
    final slots = slotsOn(medication, now, doses);
    final last = lastGiven(medication, doses);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.medication_outlined, color: theme.colorScheme.primary),
              title: Text(medication.name, style: theme.textTheme.titleMedium),
              subtitle: Text(_summary(context, medication)),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => showMedicineSheet(context, baby, existing: medication),
              ),
            ),
            for (final slot in slots)
              _SlotRow(
                slot: slot,
                now: now,
                onRecord: ({required skipped}) => _act(
                  context,
                  ref,
                  (repo) => repo.recordDose(baby, medication, scheduledFor: slot.at, skipped: skipped),
                ),
                onUndo: (record) => _act(context, ref, (repo) => repo.undoDose(record.id)),
              ),
            if (medication.asNeeded) ...[
              if (last != null)
                Text(
                  l10n.lastGiven(
                    '${MaterialLocalizations.of(context).formatShortMonthDay(last.givenAt)}, '
                    '${TimeOfDay.fromDateTime(last.givenAt).format(context)}',
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  onPressed: medication.isActiveOn(now)
                      ? () => _act(context, ref, (repo) => repo.recordDose(baby, medication))
                      : null,
                  child: Text(l10n.recordDoseNow),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One of today's scheduled doses: its time, state, and Given / Skip / Undo.
class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot, required this.now, required this.onRecord, required this.onUndo});

  final DoseSlot slot;
  final DateTime now;
  final void Function({required bool skipped}) onRecord;
  final void Function(MedicationDose record) onUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = slot.state(now);

    final (label, color) = switch (state) {
      SlotState.given => (l10n.doseGiven, theme.colorScheme.primary),
      SlotState.skipped => (l10n.doseSkipped, theme.colorScheme.outline),
      SlotState.missed => (l10n.doseMissed, theme.colorScheme.error),
      SlotState.due || SlotState.upcoming => ('', theme.colorScheme.onSurface),
    };

    // Time and state stack on the left, so the buttons always fit beside
    // them, even for "Missed" in Urdu on a narrow phone.
    const compact = VisualDensity.compact;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TimeOfDay.fromDateTime(slot.at).format(context), style: theme.textTheme.titleSmall),
              if (label.isNotEmpty)
                Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (slot.record case final record?)
          TextButton(
            style: TextButton.styleFrom(visualDensity: compact),
            onPressed: () => onUndo(record),
            child: Text(l10n.undoDose),
          )
        else if (state != SlotState.upcoming) ...[
          TextButton(
            style: TextButton.styleFrom(visualDensity: compact),
            onPressed: () => onRecord(skipped: true),
            child: Text(l10n.skipDose),
          ),
          FilledButton(
            style: FilledButton.styleFrom(visualDensity: compact),
            onPressed: () => onRecord(skipped: false),
            child: Text(l10n.markDoseGiven),
          ),
        ],
      ],
    );
  }
}

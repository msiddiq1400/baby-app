import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/vaccine_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';
import 'vaccine_plan.dart';

/// Record [doses] as given (one dose, or a whole visit at once).
Future<void> showRecordVaccinationSheet(BuildContext context, Baby baby, List<VaccineDose> doses) =>
    showFormSheet(context, _VaccinationSheet(baby: baby, doses: doses));

/// Edit or delete a recorded dose.
Future<void> showEditVaccinationSheet(BuildContext context, Baby baby, VaccineDose dose, Vaccination existing) =>
    showFormSheet(context, _VaccinationSheet(baby: baby, doses: [dose], existing: existing));

class _VaccinationSheet extends ConsumerStatefulWidget {
  const _VaccinationSheet({required this.baby, required this.doses, this.existing});

  final Baby baby;
  final List<VaccineDose> doses;
  final Vaccination? existing;

  @override
  ConsumerState<_VaccinationSheet> createState() => _VaccinationSheetState();
}

class _VaccinationSheetState extends ConsumerState<_VaccinationSheet> {
  late DateTime _date = widget.existing?.givenOn ?? DateTime.now();
  late final _batch = TextEditingController(text: widget.existing?.batchNumber ?? '');
  late final _clinic = TextEditingController(text: widget.existing?.clinic ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  var _busy = false;

  @override
  void dispose() {
    _batch.dispose();
    _clinic.dispose();
    _notes.dispose();
    super.dispose();
  }

  static String? _orNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  void _refresh() => ref.invalidate(vaccinationsProvider(widget.baby.id));

  Future<void> _submit() async {
    setState(() => _busy = true);
    final repo = ref.read(vaccineRepositoryProvider);
    final existing = widget.existing;
    await runAndClose(
      context,
      () => existing == null
          ? repo.markGiven(
              widget.baby,
              codes: [for (final d in widget.doses) d.code],
              givenOn: _date,
              batchNumber: _orNull(_batch),
              clinic: _orNull(_clinic),
              notes: _orNull(_notes),
            )
          : repo.update(
              existing.id,
              givenOn: _date,
              batchNumber: _orNull(_batch),
              clinic: _orNull(_clinic),
              notes: _orNull(_notes),
            ),
      onDone: _refresh,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final existing = widget.existing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(existing == null ? l10n.recordVaccination : l10n.editVaccination, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final dose in widget.doses) Text('• ${doseTitle(dose)}', style: theme.textTheme.bodyMedium),
        DateField(
          label: l10n.dateGivenLabel,
          date: _date,
          firstDate: widget.baby.birthDate,
          onChanged: (d) => setState(() => _date = d),
        ),
        TextField(controller: _batch, decoration: InputDecoration(labelText: l10n.batchLabel)),
        const SizedBox(height: 12),
        TextField(
          controller: _clinic,
          decoration: InputDecoration(labelText: l10n.clinicLabel),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextField(controller: _notes, decoration: InputDecoration(labelText: l10n.notesLabel), maxLines: 2),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.saveButton)),
        if (existing != null)
          DeleteButton(
            enabled: !_busy,
            onConfirmed: () => runAndClose(
              context,
              () => ref.read(vaccineRepositoryProvider).delete(existing.id),
              onDone: _refresh,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/numbers.dart';
import '../../data/medication_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';

/// Add a medicine, or edit [existing].
Future<void> showMedicineSheet(BuildContext context, Baby baby, {Medication? existing}) =>
    showFormSheet(context, _MedicineSheet(baby: baby, existing: existing));

class _MedicineSheet extends ConsumerStatefulWidget {
  const _MedicineSheet({required this.baby, this.existing});

  final Baby baby;
  final Medication? existing;

  @override
  ConsumerState<_MedicineSheet> createState() => _MedicineSheetState();
}

class _MedicineSheetState extends ConsumerState<_MedicineSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _dose = TextEditingController(text: widget.existing?.prescribedDose ?? '');
  late final _days = TextEditingController(text: _initialDays());
  late final _prescribedBy = TextEditingController(text: widget.existing?.prescribedBy ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late bool _asNeeded = widget.existing?.asNeeded ?? false;
  late List<DoseTime> _times = [...?widget.existing?.doseTimes];
  late DateTime _start = widget.existing?.startDate ?? DateTime.now();
  var _busy = false;
  var _showTimesError = false;

  static const _presets = {
    'once': [DoseTime(9, 0)],
    'twice': [DoseTime(9, 0), DoseTime(21, 0)],
    'thrice': [DoseTime(8, 0), DoseTime(14, 0), DoseTime(20, 0)],
    'every6h': [DoseTime(0, 0), DoseTime(6, 0), DoseTime(12, 0), DoseTime(18, 0)],
  };

  String _initialDays() {
    final m = widget.existing;
    if (m?.endDate == null) return '';
    return '${m!.endDate!.difference(m.startDate).inDays + 1}';
  }

  @override
  void dispose() {
    for (final c in [_name, _dose, _days, _prescribedBy, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (picked == null) return;
    final time = DoseTime(picked.hour, picked.minute);
    if (!_times.contains(time)) setState(() => _times = [..._times, time]..sort());
  }

  static String? _orNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _submit() async {
    final timesMissing = !_asNeeded && _times.isEmpty;
    setState(() => _showTimesError = timesMissing);
    if (!_formKey.currentState!.validate() || timesMissing) return;

    final days = parseLocalizedInt(_days.text);
    final start = DateTime(_start.year, _start.month, _start.day);
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(medicationRepositoryProvider).save(
            widget.baby,
            existingId: widget.existing?.id,
            name: _name.text.trim(),
            prescribedDose: _dose.text.trim(),
            doseTimes: _times,
            asNeeded: _asNeeded,
            startDate: start,
            endDate: days == null ? null : start.add(Duration(days: days - 1)),
            prescribedBy: _orNull(_prescribedBy),
            notes: _orNull(_notes),
          ),
      onDone: () => ref.invalidate(medicationsProvider(widget.baby.id)),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final existing = widget.existing;
    final presetLabels = {
      'once': l10n.presetOnce,
      'twice': l10n.presetTwice,
      'thrice': l10n.presetThrice,
      'every6h': l10n.presetEvery6h,
    };

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(existing == null ? l10n.addMedicine : l10n.editMedicine, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.medicineNameLabel),
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dose,
            decoration: InputDecoration(labelText: l10n.prescribedDoseLabel),
            validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l10n.scheduleAtTimes)),
              ButtonSegment(value: true, label: Text(l10n.scheduleAsNeeded)),
            ],
            selected: {_asNeeded},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _asNeeded = s.first),
          ),
          if (!_asNeeded) ...[
            const SizedBox(height: 12),
            Text(l10n.doseTimesLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in _presets.entries)
                  ActionChip(
                    label: Text(presetLabels[entry.key]!),
                    onPressed: () => setState(() => _times = [...entry.value]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final t in _times)
                  InputChip(
                    label: Text(TimeOfDay(hour: t.hour, minute: t.minute).format(context)),
                    onDeleted: () => setState(() => _times = [..._times]..remove(t)),
                  ),
                ActionChip(avatar: const Icon(Icons.add, size: 18), label: Text(l10n.addTime), onPressed: _addTime),
              ],
            ),
            if (_showTimesError)
              Text(l10n.chooseTimes, style: TextStyle(color: theme.colorScheme.error)),
          ],
          DateField(
            label: l10n.startDateLabel,
            date: _start,
            firstDate: widget.baby.birthDate,
            onChanged: (d) => setState(() => _start = d),
          ),
          TextFormField(
            controller: _days,
            decoration: InputDecoration(labelText: l10n.durationDaysLabel),
            keyboardType: TextInputType.number,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return null;
              final d = parseLocalizedInt(v!);
              return d == null || d < 1 || d > 365 ? l10n.invalidDays : null;
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _prescribedBy,
            decoration: InputDecoration(labelText: l10n.prescribedByLabel),
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
                () => ref.read(medicationRepositoryProvider).delete(existing.id),
                onDone: () => ref.invalidate(medicationsProvider(widget.baby.id)),
              ),
            ),
        ],
      ),
    );
  }
}

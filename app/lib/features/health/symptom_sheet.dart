import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_age.dart';
import '../../core/numbers.dart';
import '../../data/models.dart';
import '../../data/symptom_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';
import 'doctor_summary.dart';

/// Log a symptom, or edit [existing].
Future<void> showSymptomSheet(BuildContext context, Baby baby, {SymptomLog? existing}) =>
    showFormSheet(context, _SymptomSheet(baby: baby, existing: existing));

class _SymptomSheet extends ConsumerStatefulWidget {
  const _SymptomSheet({required this.baby, this.existing});

  final Baby baby;
  final SymptomLog? existing;

  @override
  ConsumerState<_SymptomSheet> createState() => _SymptomSheetState();
}

class _SymptomSheetState extends ConsumerState<_SymptomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String? _symptom = widget.existing?.symptom;
  late DateTime _at = widget.existing?.occurredAt ?? DateTime.now();
  late final _temperature = TextEditingController(text: widget.existing?.temperatureC?.toStringAsFixed(1) ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late int? _severity = widget.existing?.severity;
  var _fahrenheit = false;
  var _busy = false;
  var _showSymptomError = false;

  @override
  void initState() {
    super.initState();
    // Re-check the young-baby fever warning as the temperature is typed.
    _temperature.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _temperature.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// The typed temperature in °C, or null if empty or out of range.
  double? get _celsius {
    final value = parseLocalizedNumber(_temperature.text);
    if (value == null) return null;
    final c = _fahrenheit ? (value - 32) * 5 / 9 : value;
    return c >= 30 && c <= 45 ? double.parse(c.toStringAsFixed(1)) : null;
  }

  bool get _youngWithFever {
    final c = _celsius;
    return c != null && c >= 38 && babyAge(widget.baby.birthDate, _at).months < 3;
  }

  Future<void> _submit() async {
    setState(() => _showSymptomError = _symptom == null);
    if (_symptom == null || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(symptomRepositoryProvider).save(
            widget.baby,
            existingId: widget.existing?.id,
            symptom: _symptom!,
            occurredAt: _at,
            temperatureC: _celsius,
            severity: _severity,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          ),
      onDone: () => ref.invalidate(recentSymptomsProvider(widget.baby.id)),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final existing = widget.existing;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(existing == null ? l10n.logSymptom : l10n.editSymptom, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final code in symptomCodes)
                ChoiceChip(
                  label: Text(symptomName(l10n, code)),
                  selected: _symptom == code,
                  onSelected: (_) => setState(() => _symptom = code),
                ),
            ],
          ),
          if (_showSymptomError) Text(l10n.fieldRequired, style: TextStyle(color: theme.colorScheme.error)),
          DateField(
            label: l10n.dateLabel,
            date: _at,
            firstDate: widget.baby.birthDate,
            onChanged: (d) => setState(() => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute)),
          ),
          TimeField(label: l10n.timeLabel, time: _at, onChanged: (t) => setState(() => _at = t)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _temperature,
                  decoration: InputDecoration(labelText: l10n.temperatureLabel),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v ?? '').trim().isNotEmpty && _celsius == null ? l10n.invalidTemperature : null,
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('°C')),
                  ButtonSegment(value: true, label: Text('°F')),
                ],
                selected: {_fahrenheit},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _fahrenheit = s.first),
              ),
            ],
          ),
          if (_youngWithFever)
            Card(
              color: theme.colorScheme.errorContainer,
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                leading: Icon(Icons.local_hospital, color: theme.colorScheme.onErrorContainer),
                title: Text(l10n.youngFeverWarning, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
            ),
          const SizedBox(height: 12),
          Text(l10n.severityLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 1, label: Text(l10n.severityMild)),
              ButtonSegment(value: 2, label: Text(l10n.severityModerate)),
              ButtonSegment(value: 3, label: Text(l10n.severitySevere)),
            ],
            selected: {?_severity},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _severity = s.firstOrNull),
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
                () => ref.read(symptomRepositoryProvider).delete(existing.id),
                onDone: () => ref.invalidate(recentSymptomsProvider(widget.baby.id)),
              ),
            ),
        ],
      ),
    );
  }
}

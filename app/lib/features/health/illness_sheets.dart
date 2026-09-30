import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/illness_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';

/// Start tracking an illness, or edit [existing].
Future<void> showIllnessSheet(BuildContext context, Baby baby, {Illness? existing}) =>
    showFormSheet(context, _IllnessSheet(baby: baby, existing: existing));

/// Record a doctor's visit, or edit [existing].
Future<void> showDoctorVisitSheet(BuildContext context, Baby baby, {DoctorVisit? existing}) =>
    showFormSheet(context, _VisitSheet(baby: baby, existing: existing));

/// Common names offered as one-tap choices (free text is fine too).
List<String> illnessSuggestions(AppLocalizations l10n) => [
      l10n.illnessCold,
      l10n.illnessFever,
      l10n.illnessCough,
      l10n.illnessTummy,
      l10n.illnessEar,
      l10n.illnessRash,
    ];

String? _trimmed(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

class _IllnessSheet extends ConsumerStatefulWidget {
  const _IllnessSheet({required this.baby, this.existing});

  final Baby baby;
  final Illness? existing;

  @override
  ConsumerState<_IllnessSheet> createState() => _IllnessSheetState();
}

class _IllnessSheetState extends ConsumerState<_IllnessSheet> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late DateTime _start = widget.existing?.startedAt ?? DateTime.now();
  late DateTime? _recovered = widget.existing?.recoveredAt;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _valid => _recovered == null || !_recovered!.isBefore(_start);

  Future<void> _submit() async {
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(illnessRepositoryProvider).saveIllness(
            widget.baby,
            existingId: widget.existing?.id,
            name: _trimmed(_name),
            startedAt: _start,
            recoveredAt: _recovered,
            notes: _trimmed(_notes),
          ),
      onDone: () {},
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
        Text(existing == null ? l10n.startIllness : l10n.editIllness, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        if (existing == null) Text(l10n.startIllnessHelp, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        TextField(controller: _name, decoration: InputDecoration(labelText: l10n.illnessNameLabel)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final s in illnessSuggestions(l10n))
              ActionChip(label: Text(s), onPressed: () => setState(() => _name.text = s)),
          ],
        ),
        DateField(
          label: l10n.illnessStartedLabel,
          date: _start,
          firstDate: widget.baby.birthDate,
          onChanged: (d) => setState(() => _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute)),
        ),
        TimeField(label: l10n.timeLabel, time: _start, onChanged: (t) => setState(() => _start = t)),
        if (existing != null) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.recoveredLabel),
            value: _recovered != null,
            onChanged: (v) => setState(() => _recovered = v ? DateTime.now() : null),
          ),
          if (_recovered != null)
            DateField(
              label: l10n.recoveredOnLabel,
              date: _recovered!,
              firstDate: _start,
              onChanged: (d) => setState(() => _recovered = DateTime(d.year, d.month, d.day, 12)),
            ),
        ],
        if (!_valid) Text(l10n.invalidSleepTimes, style: TextStyle(color: theme.colorScheme.error)),
        TextField(controller: _notes, decoration: InputDecoration(labelText: l10n.notesLabel), maxLines: 2),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy || !_valid ? null : _submit, child: Text(l10n.saveButton)),
        if (existing != null)
          DeleteButton(
            enabled: !_busy,
            onConfirmed: () => runAndClose(
              context,
              () => ref.read(illnessRepositoryProvider).deleteIllness(existing.id),
              onDone: () {},
            ),
          ),
      ],
    );
  }
}

class _VisitSheet extends ConsumerStatefulWidget {
  const _VisitSheet({required this.baby, this.existing});

  final Baby baby;
  final DoctorVisit? existing;

  @override
  ConsumerState<_VisitSheet> createState() => _VisitSheetState();
}

class _VisitSheetState extends ConsumerState<_VisitSheet> {
  late final _doctor = TextEditingController(text: widget.existing?.doctor ?? '');
  late final _diagnosis = TextEditingController(text: widget.existing?.diagnosis ?? '');
  late final _advice = TextEditingController(text: widget.existing?.advice ?? '');
  late DateTime _at = widget.existing?.visitedAt ?? DateTime.now();
  var _busy = false;

  @override
  void dispose() {
    _doctor.dispose();
    _diagnosis.dispose();
    _advice.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(illnessRepositoryProvider).saveVisit(
            widget.baby,
            existingId: widget.existing?.id,
            visitedAt: _at,
            doctor: _trimmed(_doctor),
            diagnosis: _trimmed(_diagnosis),
            advice: _trimmed(_advice),
          ),
      onDone: () {},
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existing = widget.existing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.doctorVisit, style: Theme.of(context).textTheme.titleLarge),
        DateField(
          label: l10n.dateLabel,
          date: _at,
          firstDate: widget.baby.birthDate,
          onChanged: (d) => setState(() => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute)),
        ),
        TimeField(label: l10n.timeLabel, time: _at, onChanged: (t) => setState(() => _at = t)),
        TextField(controller: _doctor, decoration: InputDecoration(labelText: l10n.doctorLabel)),
        const SizedBox(height: 8),
        TextField(controller: _diagnosis, decoration: InputDecoration(labelText: l10n.diagnosisLabel)),
        const SizedBox(height: 8),
        TextField(controller: _advice, decoration: InputDecoration(labelText: l10n.adviceLabel), maxLines: 3),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.saveButton)),
        if (existing != null)
          DeleteButton(
            enabled: !_busy,
            onConfirmed: () => runAndClose(
              context,
              () => ref.read(illnessRepositoryProvider).deleteVisit(existing.id),
              onDone: () {},
            ),
          ),
      ],
    );
  }
}

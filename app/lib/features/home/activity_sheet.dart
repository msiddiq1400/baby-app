import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';

/// Add an activity (tummy time, bath, play...), or edit [existing]. A new
/// one can also start a timer instead of being saved with a duration.
Future<void> showActivitySheet(BuildContext context, Baby baby, {Activity? existing, ActivityKind? kind}) =>
    showFormSheet(context, _ActivitySheet(baby: baby, existing: existing, kind: kind));

String activityName(AppLocalizations l10n, ActivityKind kind) => switch (kind) {
  ActivityKind.tummyTime => l10n.activityTummyTime,
  ActivityKind.bath => l10n.activityBath,
  ActivityKind.play => l10n.activityPlay,
  ActivityKind.outdoors => l10n.activityOutdoors,
  ActivityKind.reading => l10n.activityReading,
  ActivityKind.massage => l10n.activityMassage,
  ActivityKind.other => l10n.activityOther,
};

/// "Swimming" for an "other" activity with a label, else the kind's name.
String activityTitle(AppLocalizations l10n, Activity a) =>
    a.kind == ActivityKind.other && (a.label?.isNotEmpty ?? false) ? a.label! : activityName(l10n, a.kind);

IconData activityIcon(ActivityKind kind) => switch (kind) {
  ActivityKind.tummyTime => Icons.child_care_outlined,
  ActivityKind.bath => Icons.bathtub_outlined,
  ActivityKind.play => Icons.toys_outlined,
  ActivityKind.outdoors => Icons.park_outlined,
  ActivityKind.reading => Icons.auto_stories_outlined,
  ActivityKind.massage => Icons.spa_outlined,
  ActivityKind.other => Icons.star_outline,
};

/// The quick duration choices, in minutes.
const activityMinuteChoices = [2, 5, 10, 15, 20, 30, 45, 60];

class _ActivitySheet extends ConsumerStatefulWidget {
  const _ActivitySheet({required this.baby, this.existing, this.kind});

  final Baby baby;
  final Activity? existing;
  final ActivityKind? kind;

  @override
  ConsumerState<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends ConsumerState<_ActivitySheet> {
  late ActivityKind _kind = widget.existing?.kind ?? widget.kind ?? ActivityKind.tummyTime;
  late final _label = TextEditingController(text: widget.existing?.label ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late DateTime _start = widget.existing?.startedAt ?? DateTime.now();

  /// Minutes, or null for "not timed".
  late int? _minutes = switch (widget.existing?.duration(DateTime.now())) {
    null => null,
    final d => d.inMinutes,
  };
  var _busy = false;

  @override
  void dispose() {
    _label.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _do(Future<void> Function(TrackingRepository repo) action) async {
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => action(ref.read(trackingRepositoryProvider)),
      onDone: () => ref.invalidate(todayLogProvider(widget.baby.id)),
    );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _save() => _do(
    (repo) => repo.saveActivity(
      widget.baby,
      existingId: widget.existing?.id,
      kind: _kind,
      startedAt: _start,
      duration: _minutes == null ? null : Duration(minutes: _minutes!),
      label: _label.text,
      notes: _notes.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final existing = widget.existing;
    final running = existing?.isOngoing ?? false;
    // Only one activity timer at a time.
    final otherTimer = ref.watch(todayLogProvider(widget.baby.id)).value?.ongoingActivity;
    final canStartTimer = existing == null && otherTimer == null;
    final minuteChoices = {...activityMinuteChoices, ?_minutes}.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(existing == null ? l10n.addActivity : l10n.editActivity, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final k in ActivityKind.values)
              ChoiceChip(
                avatar: Icon(activityIcon(k), size: 18),
                label: Text(activityName(l10n, k)),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        if (_kind == ActivityKind.other)
          TextField(
            controller: _label,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.activityLabelHint),
          ),
        TimeField(
          label: l10n.activityStartedLabel,
          time: _start,
          firstDate: widget.baby.birthDate,
          onChanged: (t) => setState(() => _start = t),
        ),
        if (running)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.activityRunning, style: theme.textTheme.titleSmall),
          )
        else ...[
          const SizedBox(height: 8),
          Text(l10n.activityHowLong, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: Text(l10n.activityNotTimed),
                selected: _minutes == null,
                onSelected: (_) => setState(() => _minutes = null),
              ),
              for (final m in minuteChoices)
                ChoiceChip(
                  label: Text(l10n.activityMinutes(m)),
                  selected: _minutes == m,
                  onSelected: (_) => setState(() => _minutes = m),
                ),
            ],
          ),
        ],
        TextField(
          controller: _notes,
          maxLength: 500,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.notesLabel),
        ),
        const SizedBox(height: 8),
        if (running)
          FilledButton(
            onPressed: _busy
                ? null
                : () => _do((repo) async {
                    await _saveDetails(repo, existing!);
                    await repo.stopActivityTimer(existing.id, at: DateTime.now());
                  }),
            child: Text(l10n.activityStopNow),
          )
        else
          FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.saveButton)),
        if (canStartTimer)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton.tonalIcon(
              onPressed: _busy
                  ? null
                  : () => _do(
                      (repo) => repo.startActivityTimer(widget.baby, _kind, at: DateTime.now(), label: _label.text),
                    ),
              icon: const Icon(Icons.timer_outlined),
              label: Text(l10n.activityStartTimer),
            ),
          ),
        if (existing != null)
          DeleteButton(
            enabled: !_busy,
            onConfirmed: () => _do((repo) => repo.delete(TrackedTable.activities, existing.id)),
          ),
      ],
    );
  }

  /// Keeps kind, label, start and notes edits when stopping a running timer.
  Future<void> _saveDetails(TrackingRepository repo, Activity existing) =>
      repo.updateActivityDetails(existing.id, kind: _kind, startedAt: _start, label: _label.text, notes: _notes.text);
}

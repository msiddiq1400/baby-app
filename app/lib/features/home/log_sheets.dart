import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/numbers.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';

/// Log a new feed, or edit [existing].
Future<void> showFeedSheet(BuildContext context, Baby baby, {Feed? existing}) =>
    showFormSheet(context, _FeedSheet(baby: baby, existing: existing));

/// Log a new diaper, or edit [existing].
Future<void> showDiaperSheet(BuildContext context, Baby baby, {Diaper? existing}) =>
    showFormSheet(context, _DiaperSheet(baby: baby, existing: existing));

Future<void> showSleepSheet(BuildContext context, Baby baby, Sleep existing) =>
    showFormSheet(context, _SleepSheet(baby: baby, existing: existing));

/// Runs [action], refreshes today's data and closes the sheet.
Future<void> _run(BuildContext context, WidgetRef ref, Baby baby, Future<void> Function() action) =>
    runAndClose(context, action, onDone: () => ref.invalidate(todayLogProvider(baby.id)));

class _FeedSheet extends ConsumerStatefulWidget {
  const _FeedSheet({required this.baby, this.existing});

  final Baby baby;
  final Feed? existing;

  @override
  ConsumerState<_FeedSheet> createState() => _FeedSheetState();
}

class _FeedSheetState extends ConsumerState<_FeedSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _minutes;
  late FeedType _type;
  late BreastSide _side;
  late DateTime _time;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    final feed = widget.existing;
    _type = feed?.type ?? FeedType.breast;
    _side = feed?.side ?? BreastSide.left;
    _time = feed?.endedAt ?? feed?.startedAt ?? DateTime.now();
    _amount = TextEditingController(text: feed?.amountMl?.toString() ?? '');
    final minutes = feed?.endedAt?.difference(feed.startedAt).inMinutes;
    _minutes = TextEditingController(text: minutes == null || minutes == 0 ? '' : '$minutes');
  }

  @override
  void dispose() {
    _amount.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await _run(context, ref, widget.baby, () {
      final isBreast = _type == FeedType.breast;
      return ref.read(trackingRepositoryProvider).saveFeed(
            widget.baby,
            existingId: widget.existing?.id,
            type: _type,
            at: _time,
            side: isBreast ? _side : null,
            amountMl: isBreast ? null : parseLocalizedInt(_amount.text),
            minutes: isBreast ? parseLocalizedInt(_minutes.text) : null,
          );
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBreast = _type == FeedType.breast;
    final existing = widget.existing;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(existing == null ? l10n.logFeed : l10n.editFeed, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SegmentedButton<FeedType>(
            segments: [
              ButtonSegment(value: FeedType.breast, label: Text(l10n.feedTypeBreast)),
              ButtonSegment(value: FeedType.bottleBreastMilk, label: Text(l10n.feedTypeBottleBreastMilk)),
              ButtonSegment(value: FeedType.bottleFormula, label: Text(l10n.feedTypeFormula)),
            ],
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          if (isBreast) ...[
            SegmentedButton<BreastSide>(
              segments: [
                ButtonSegment(value: BreastSide.left, label: Text(l10n.sideLeft)),
                ButtonSegment(value: BreastSide.right, label: Text(l10n.sideRight)),
                ButtonSegment(value: BreastSide.both, label: Text(l10n.sideBoth)),
              ],
              selected: {_side},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _side = s.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minutes,
              decoration: InputDecoration(labelText: l10n.feedMinutes),
              keyboardType: TextInputType.number,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return null;
                final m = parseLocalizedInt(v!);
                return m == null || m < 1 || m > 180 ? l10n.invalidMinutes : null;
              },
            ),
          ] else
            TextFormField(
              controller: _amount,
              decoration: InputDecoration(labelText: l10n.amountMl),
              keyboardType: TextInputType.number,
              autofocus: existing == null,
              validator: (v) {
                final ml = parseLocalizedInt(v ?? '');
                return ml == null || ml < 1 || ml > 1000 ? l10n.invalidAmount : null;
              },
            ),
          TimeField(label: l10n.timeLabel, time: _time, onChanged: (t) => setState(() => _time = t)),
          const SizedBox(height: 8),
          FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.saveButton)),
          if (existing != null)
            DeleteButton(
              enabled: !_busy,
              onConfirmed: () => _run(
                context,
                ref,
                widget.baby,
                () => ref.read(trackingRepositoryProvider).delete(TrackedTable.feeds, existing.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _DiaperSheet extends ConsumerStatefulWidget {
  const _DiaperSheet({required this.baby, this.existing});

  final Baby baby;
  final Diaper? existing;

  @override
  ConsumerState<_DiaperSheet> createState() => _DiaperSheetState();
}

class _DiaperSheetState extends ConsumerState<_DiaperSheet> {
  late bool _wet = widget.existing?.isWet ?? true;
  late bool _dirty = widget.existing?.isDirty ?? false;
  late DateTime _time = widget.existing?.occurredAt ?? DateTime.now();
  var _busy = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    await _run(
      context,
      ref,
      widget.baby,
      () => ref.read(trackingRepositoryProvider).saveDiaper(
            widget.baby,
            existingId: widget.existing?.id,
            at: _time,
            wet: _wet,
            dirty: _dirty,
          ),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSave = _wet || _dirty;
    final existing = widget.existing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(existing == null ? l10n.logDiaper : l10n.editDiaper, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            FilterChip(label: Text(l10n.diaperWet), selected: _wet, onSelected: (v) => setState(() => _wet = v)),
            const SizedBox(width: 8),
            FilterChip(label: Text(l10n.diaperDirty), selected: _dirty, onSelected: (v) => setState(() => _dirty = v)),
          ],
        ),
        if (!canSave)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.chooseDiaper, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        TimeField(label: l10n.timeLabel, time: _time, onChanged: (t) => setState(() => _time = t)),
        const SizedBox(height: 8),
        FilledButton(onPressed: _busy || !canSave ? null : _submit, child: Text(l10n.saveButton)),
        if (existing != null)
          DeleteButton(
            enabled: !_busy,
            onConfirmed: () => _run(
              context,
              ref,
              widget.baby,
              () => ref.read(trackingRepositoryProvider).delete(TrackedTable.diapers, existing.id),
            ),
          ),
      ],
    );
  }
}

class _SleepSheet extends ConsumerStatefulWidget {
  const _SleepSheet({required this.baby, required this.existing});

  final Baby baby;
  final Sleep existing;

  @override
  ConsumerState<_SleepSheet> createState() => _SleepSheetState();
}

class _SleepSheetState extends ConsumerState<_SleepSheet> {
  late SleepKind _kind = widget.existing.kind;
  late DateTime _start = widget.existing.startedAt;
  late DateTime? _end = widget.existing.endedAt;
  var _busy = false;

  bool get _timesValid => _end == null || _end!.isAfter(_start);

  Future<void> _submit() async {
    setState(() => _busy = true);
    await _run(
      context,
      ref,
      widget.baby,
      () => ref
          .read(trackingRepositoryProvider)
          .updateSleep(widget.existing.id, kind: _kind, startedAt: _start, endedAt: _end),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.editSleep, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SegmentedButton<SleepKind>(
          segments: [
            ButtonSegment(value: SleepKind.nap, label: Text(l10n.sleepNap)),
            ButtonSegment(value: SleepKind.night, label: Text(l10n.sleepNight)),
          ],
          selected: {_kind},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _kind = s.first),
        ),
        TimeField(label: l10n.sleepStartLabel, time: _start, onChanged: (t) => setState(() => _start = t)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.stillAsleep),
          value: _end == null,
          onChanged: (asleep) => setState(() => _end = asleep ? null : DateTime.now()),
        ),
        if (_end != null) TimeField(label: l10n.sleepEndLabel, time: _end!, onChanged: (t) => setState(() => _end = t)),
        if (!_timesValid)
          Text(l10n.invalidSleepTimes, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 8),
        FilledButton(onPressed: _busy || !_timesValid ? null : _submit, child: Text(l10n.saveButton)),
        DeleteButton(
          enabled: !_busy,
          onConfirmed: () => _run(
            context,
            ref,
            widget.baby,
            () => ref.read(trackingRepositoryProvider).delete(TrackedTable.sleeps, widget.existing.id),
          ),
        ),
      ],
    );
  }
}

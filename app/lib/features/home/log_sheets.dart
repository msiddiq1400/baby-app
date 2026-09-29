import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/numbers.dart';
import '../../core/reminders.dart';
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
  late final TextEditingController _left;
  late final TextEditingController _right;
  late final (int?, int?) _initialSeconds;
  late FeedType _type;
  late DateTime _time;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    final feed = widget.existing;
    _type = feed?.type ?? FeedType.breast;
    _time = feed?.endedAt ?? feed?.startedAt ?? DateTime.now();
    _amount = TextEditingController(text: feed?.amountMl?.toString() ?? '');
    _initialSeconds = feed == null ? (null, null) : secondsPerSide(feed);
    String minutes(int? seconds) => seconds == null || seconds == 0 ? '' : '${(seconds / 60).round()}';
    _left = TextEditingController(text: minutes(_initialSeconds.$1));
    _right = TextEditingController(text: minutes(_initialSeconds.$2));
  }

  @override
  void dispose() {
    _amount.dispose();
    _left.dispose();
    _right.dispose();
    super.dispose();
  }

  /// Seconds from a minutes field; an unchanged field keeps the exact
  /// seconds a timer recorded.
  int? _seconds(TextEditingController field, int? initial) {
    final minutes = parseLocalizedInt(field.text);
    if (minutes == null) return null;
    if (initial != null && (initial / 60).round() == minutes) return initial;
    return minutes * 60;
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
            amountMl: isBreast ? null : parseLocalizedInt(_amount.text),
            leftSeconds: isBreast ? _seconds(_left, _initialSeconds.$1) : null,
            rightSeconds: isBreast ? _seconds(_right, _initialSeconds.$2) : null,
          );
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _startTimer(BreastSide side) async {
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(trackingRepositoryProvider).startFeedTimer(widget.baby, side, at: DateTime.now()),
      onDone: () {},
    );
    // The running timer is shown as a notification (Android).
    await Reminders.requestPermission();
  }

  String? _validMinutes(String? v) {
    final l10n = AppLocalizations.of(context);
    if ((v ?? '').trim().isEmpty) return null;
    final m = parseLocalizedInt(v!);
    return m == null || m < 1 || m > 180 ? l10n.invalidMinutes : null;
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
            if (existing == null) ...[
              _TimerStart(baby: widget.baby, enabled: !_busy, onStart: _startTimer),
              const SizedBox(height: 20),
              Text(l10n.orEnterMinutes, style: Theme.of(context).textTheme.titleSmall),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _left,
                    decoration: InputDecoration(labelText: l10n.leftMinutes),
                    keyboardType: TextInputType.number,
                    validator: _validMinutes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _right,
                    decoration: InputDecoration(labelText: l10n.rightMinutes),
                    keyboardType: TextInputType.number,
                    validator: _validMinutes,
                  ),
                ),
              ],
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

/// Time per side for an existing feed. Feeds logged before per-side times
/// only have a side and a duration; "both" is split evenly.
@visibleForTesting
(int?, int?) secondsPerSide(Feed feed) {
  if (feed.leftSeconds != null || feed.rightSeconds != null) return (feed.leftSeconds, feed.rightSeconds);
  final total = feed.duration(DateTime.now())?.inSeconds;
  if (total == null) return (null, null);
  return switch (feed.side) {
    BreastSide.left => (total, null),
    BreastSide.right => (null, total),
    BreastSide.both => ((total + 1) ~/ 2, total ~/ 2),
    null => (null, null),
  };
}

/// "Start a timer" with a button per side. The side after the last feed's
/// side is highlighted, since mothers usually alternate.
class _TimerStart extends ConsumerWidget {
  const _TimerStart({required this.baby, required this.enabled, required this.onStart});

  final Baby baby;
  final bool enabled;
  final void Function(BreastSide side) onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (ref.watch(feedTimerProvider(baby.id)).value != null) {
      return Card(
        child: ListTile(leading: const Icon(Icons.timer_outlined), title: Text(l10n.feedTimerAlreadyRunning)),
      );
    }
    final feeds = ref.watch(recentFeedsProvider(baby.id)).value ?? const <Feed>[];
    final last = feeds.reversed.where((f) => f.type == FeedType.breast && f.side != null).firstOrNull?.side;
    final suggested = switch (last) {
      BreastSide.left => BreastSide.right,
      BreastSide.right => BreastSide.left,
      _ => null,
    };

    Widget button(BreastSide side, String label) {
      final onPressed = enabled ? () => onStart(side) : null;
      const icon = Icon(Icons.play_arrow_rounded);
      final text = Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(label));
      return Expanded(
        child: suggested == null || side == suggested
            ? FilledButton.icon(onPressed: onPressed, icon: icon, label: text)
            : FilledButton.tonalIcon(onPressed: onPressed, icon: icon, label: text),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.startFeedTimer, style: Theme.of(context).textTheme.titleSmall),
        if (last != null) Text(l10n.lastSide(sideName(l10n, last)), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        // Left is on the left in every language: it's the mother's side.
        Row(
          textDirection: TextDirection.ltr,
          children: [
            button(BreastSide.left, l10n.sideLeft),
            const SizedBox(width: 12),
            button(BreastSide.right, l10n.sideRight),
          ],
        ),
      ],
    );
  }
}

String sideName(AppLocalizations l10n, BreastSide side) => switch (side) {
      BreastSide.left => l10n.sideLeft,
      BreastSide.right => l10n.sideRight,
      BreastSide.both => l10n.sideBoth,
    };

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

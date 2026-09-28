import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';

Future<void> showFeedSheet(BuildContext context, Baby baby) => _showSheet(context, _FeedSheet(baby: baby));

Future<void> showDiaperSheet(BuildContext context, Baby baby) => _showSheet(context, _DiaperSheet(baby: baby));

Future<void> _showSheet(BuildContext context, Widget sheet) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      // Keep the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: sheet),
    ),
  );
}

/// Shared save handling: runs [action], refreshes today's data, closes the sheet.
Future<void> _save(BuildContext context, WidgetRef ref, Baby baby, Future<void> Function() action) async {
  try {
    await action();
    ref.invalidate(todayLogProvider(baby.id));
    if (context.mounted) Navigator.pop(context);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
    }
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.time, required this.onChanged});

  final DateTime time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(AppLocalizations.of(context).timeLabel),
      trailing: Text(TimeOfDay.fromDateTime(time).format(context), style: Theme.of(context).textTheme.titleMedium),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(time));
        if (picked == null) return;
        var chosen = DateTime(time.year, time.month, time.day, picked.hour, picked.minute);
        // A time later than now means last night, e.g. logging an 11 pm feed after midnight.
        if (chosen.isAfter(DateTime.now())) chosen = chosen.subtract(const Duration(days: 1));
        onChanged(chosen);
      },
    );
  }
}

class _FeedSheet extends ConsumerStatefulWidget {
  const _FeedSheet({required this.baby});

  final Baby baby;

  @override
  ConsumerState<_FeedSheet> createState() => _FeedSheetState();
}

class _FeedSheetState extends ConsumerState<_FeedSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _minutes = TextEditingController();
  var _type = FeedType.breast;
  var _side = BreastSide.left;
  var _time = DateTime.now();
  var _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await _save(context, ref, widget.baby, () {
      final isBreast = _type == FeedType.breast;
      return ref.read(trackingRepositoryProvider).logFeed(
            widget.baby,
            type: _type,
            at: _time,
            side: isBreast ? _side : null,
            amountMl: isBreast ? null : int.parse(_amount.text.trim()),
            minutes: isBreast ? int.tryParse(_minutes.text.trim()) : null,
          );
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBreast = _type == FeedType.breast;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.logFeed, style: Theme.of(context).textTheme.titleLarge),
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
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;
                final m = int.tryParse(text);
                return m == null || m < 1 || m > 180 ? l10n.invalidMinutes : null;
              },
            ),
          ] else
            TextFormField(
              controller: _amount,
              decoration: InputDecoration(labelText: l10n.amountMl),
              keyboardType: TextInputType.number,
              autofocus: true,
              validator: (v) {
                final ml = int.tryParse((v ?? '').trim());
                return ml == null || ml < 1 || ml > 1000 ? l10n.invalidAmount : null;
              },
            ),
          _TimeField(time: _time, onChanged: (t) => setState(() => _time = t)),
          const SizedBox(height: 8),
          FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.saveButton)),
        ],
      ),
    );
  }
}

class _DiaperSheet extends ConsumerStatefulWidget {
  const _DiaperSheet({required this.baby});

  final Baby baby;

  @override
  ConsumerState<_DiaperSheet> createState() => _DiaperSheetState();
}

class _DiaperSheetState extends ConsumerState<_DiaperSheet> {
  var _wet = true;
  var _dirty = false;
  var _time = DateTime.now();
  var _busy = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    await _save(
      context,
      ref,
      widget.baby,
      () => ref.read(trackingRepositoryProvider).logDiaper(widget.baby, at: _time, wet: _wet, dirty: _dirty),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSave = _wet || _dirty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.logDiaper, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            FilterChip(
              label: Text(l10n.diaperWet),
              selected: _wet,
              onSelected: (v) => setState(() => _wet = v),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: Text(l10n.diaperDirty),
              selected: _dirty,
              onSelected: (v) => setState(() => _dirty = v),
            ),
          ],
        ),
        if (!canSave)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.chooseDiaper, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        _TimeField(time: _time, onChanged: (t) => setState(() => _time = t)),
        const SizedBox(height: 8),
        FilledButton(onPressed: _busy || !canSave ? null : _submit, child: Text(l10n.saveButton)),
      ],
    );
  }
}

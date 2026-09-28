import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/numbers.dart';
import '../../data/milk_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';

String milkLocationLabel(AppLocalizations l10n, MilkLocation location) => switch (location) {
      MilkLocation.room => l10n.locationRoom,
      MilkLocation.cooler => l10n.locationCooler,
      MilkLocation.fridge => l10n.locationFridge,
      MilkLocation.freezer => l10n.locationFreezer,
      MilkLocation.thawed => l10n.locationThawed,
    };

/// Log a pumping session (and optionally store the milk), or edit [existing].
Future<void> showPumpingSheet(BuildContext context, Baby baby, {PumpingSession? existing}) =>
    showFormSheet(context, _PumpingSheet(baby: baby, existing: existing));

/// Add milk to the inventory that wasn't logged as a pumping session.
Future<void> showAddMilkSheet(BuildContext context, Baby baby) => showFormSheet(context, _AddMilkSheet(baby: baby));

void _refresh(WidgetRef ref, Baby baby) {
  ref.invalidate(pumpingTodayProvider(baby.id));
  ref.invalidate(milkBagsProvider(baby.id));
}

String? _amountError(AppLocalizations l10n, String? v, {required bool required}) {
  if ((v ?? '').trim().isEmpty) return required ? l10n.invalidAmount : null;
  final ml = parseLocalizedInt(v!);
  return ml == null || ml < 1 || ml > 1000 ? l10n.invalidAmount : null;
}

class _PumpingSheet extends ConsumerStatefulWidget {
  const _PumpingSheet({required this.baby, this.existing});

  final Baby baby;
  final PumpingSession? existing;

  @override
  ConsumerState<_PumpingSheet> createState() => _PumpingSheetState();
}

class _PumpingSheetState extends ConsumerState<_PumpingSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(text: widget.existing?.amountMl?.toString() ?? '');
  late final _minutes = TextEditingController(text: _initialMinutes());
  late BreastSide _side = widget.existing?.side ?? BreastSide.both;
  late DateTime _time = widget.existing?.endedAt ?? widget.existing?.startedAt ?? DateTime.now();

  /// Null = fed right away / not stored. Only offered for new sessions.
  MilkLocation? _storeIn = MilkLocation.fridge;
  var _busy = false;

  String _initialMinutes() {
    final e = widget.existing;
    final m = e?.endedAt?.difference(e.startedAt).inMinutes;
    return m == null || m == 0 ? '' : '$m';
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
    final repo = ref.read(milkRepositoryProvider);
    final amount = parseLocalizedInt(_amount.text);
    final minutes = parseLocalizedInt(_minutes.text);
    final existing = widget.existing;
    await runAndClose(
      context,
      () => existing == null
          ? repo.logPumping(widget.baby, at: _time, side: _side, amountMl: amount, minutes: minutes, storeIn: _storeIn)
          : repo.updatePumping(existing.id, at: _time, side: _side, amountMl: amount, minutes: minutes),
      onDone: () => _refresh(ref, widget.baby),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existing = widget.existing;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(existing == null ? l10n.logPumping : l10n.editPumping, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
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
            controller: _amount,
            decoration: InputDecoration(labelText: l10n.amountMl),
            keyboardType: TextInputType.number,
            autofocus: existing == null,
            // Storing milk needs an amount; a session on its own doesn't.
            validator: (v) => _amountError(l10n, v, required: existing == null && _storeIn != null),
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
          TimeField(label: l10n.timeLabel, time: _time, onChanged: (t) => setState(() => _time = t)),
          if (existing == null) ...[
            Text(l10n.storeMilkIn, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final option in [
                  MilkLocation.fridge,
                  MilkLocation.freezer,
                  MilkLocation.cooler,
                  MilkLocation.room,
                  null,
                ])
                  ChoiceChip(
                    label: Text(option == null ? l10n.notStored : milkLocationLabel(l10n, option)),
                    selected: _storeIn == option,
                    onSelected: (_) => setState(() => _storeIn = option),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.saveButton)),
          if (existing != null)
            DeleteButton(
              enabled: !_busy,
              onConfirmed: () => runAndClose(
                context,
                () => ref.read(milkRepositoryProvider).deletePumping(existing.id),
                onDone: () => _refresh(ref, widget.baby),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddMilkSheet extends ConsumerStatefulWidget {
  const _AddMilkSheet({required this.baby});

  final Baby baby;

  @override
  ConsumerState<_AddMilkSheet> createState() => _AddMilkSheetState();
}

class _AddMilkSheetState extends ConsumerState<_AddMilkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  var _pumpedAt = DateTime.now();
  var _location = MilkLocation.fridge;
  var _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(milkRepositoryProvider).addBag(
            widget.baby,
            amountMl: parseLocalizedInt(_amount.text)!,
            pumpedAt: _pumpedAt,
            location: _location,
          ),
      onDone: () => _refresh(ref, widget.baby),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addStoredMilk, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amount,
            decoration: InputDecoration(labelText: l10n.amountMl),
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (v) => _amountError(l10n, v, required: true),
          ),
          DateField(
            label: l10n.pumpedAtLabel,
            date: _pumpedAt,
            firstDate: widget.baby.birthDate,
            onChanged: (d) => setState(
              () => _pumpedAt = DateTime(d.year, d.month, d.day, _pumpedAt.hour, _pumpedAt.minute),
            ),
          ),
          TimeField(label: l10n.timeLabel, time: _pumpedAt, onChanged: (t) => setState(() => _pumpedAt = t)),
          Wrap(
            spacing: 8,
            children: [
              for (final option in [MilkLocation.fridge, MilkLocation.freezer, MilkLocation.cooler, MilkLocation.room])
                ChoiceChip(
                  label: Text(milkLocationLabel(l10n, option)),
                  selected: _location == option,
                  onSelected: (_) => setState(() => _location = option),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.saveButton)),
        ],
      ),
    );
  }
}

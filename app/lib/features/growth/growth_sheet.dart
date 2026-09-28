import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/numbers.dart';
import '../../data/growth_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';

/// Add a measurement, or edit [existing].
Future<void> showGrowthSheet(BuildContext context, Baby baby, {GrowthMeasurement? existing}) =>
    showFormSheet(context, _GrowthSheet(baby: baby, existing: existing));

class _GrowthSheet extends ConsumerStatefulWidget {
  const _GrowthSheet({required this.baby, this.existing});

  final Baby baby;
  final GrowthMeasurement? existing;

  @override
  ConsumerState<_GrowthSheet> createState() => _GrowthSheetState();
}

class _GrowthSheetState extends ConsumerState<_GrowthSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _weight = TextEditingController(text: _format(widget.existing?.weightG, 1000));
  late final _length = TextEditingController(text: _format(widget.existing?.lengthMm, 10));
  late final _head = TextEditingController(text: _format(widget.existing?.headMm, 10));
  late DateTime _date = widget.existing?.measuredOn ?? DateTime.now();
  var _busy = false;
  var _showEmptyError = false;

  static String _format(int? value, int divisor) => value == null ? '' : '${value / divisor}';

  @override
  void dispose() {
    _weight.dispose();
    _length.dispose();
    _head.dispose();
    super.dispose();
  }

  /// Validator for an optional decimal field within [min]..[max].
  FormFieldValidator<String> _range(double min, double max, String message) => (v) {
        if ((v ?? '').trim().isEmpty) return null;
        final n = parseLocalizedNumber(v!);
        return n == null || n < min || n > max ? message : null;
      };

  int? _scaled(TextEditingController c, int factor) {
    final n = parseLocalizedNumber(c.text);
    return n == null ? null : (n * factor).round();
  }

  Future<void> _submit() async {
    final empty = [_weight, _length, _head].every((c) => c.text.trim().isEmpty);
    setState(() => _showEmptyError = empty);
    if (empty || !_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(growthRepositoryProvider).save(
            widget.baby,
            existingId: widget.existing?.id,
            measuredOn: _date,
            weightG: _scaled(_weight, 1000),
            lengthMm: _scaled(_length, 10),
            headMm: _scaled(_head, 10),
          ),
      onDone: () => ref.invalidate(growthMeasurementsProvider(widget.baby.id)),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existing = widget.existing;
    const decimal = TextInputType.numberWithOptions(decimal: true);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            existing == null ? l10n.addMeasurement : l10n.editMeasurement,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          DateField(
            label: l10n.dateLabel,
            date: _date,
            firstDate: widget.baby.birthDate,
            onChanged: (d) => setState(() => _date = d),
          ),
          TextFormField(
            controller: _weight,
            decoration: InputDecoration(labelText: l10n.weightKgLabel),
            keyboardType: decimal,
            validator: _range(0.3, 40, l10n.invalidWeightKg),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _length,
            decoration: InputDecoration(labelText: l10n.lengthCmLabel),
            keyboardType: decimal,
            validator: _range(20, 130, l10n.invalidLengthCm),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _head,
            decoration: InputDecoration(labelText: l10n.headCmLabel),
            keyboardType: decimal,
            validator: _range(20, 60, l10n.invalidHeadCm),
          ),
          if (_showEmptyError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.enterOneMeasurement, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.saveButton)),
          if (existing != null)
            DeleteButton(
              enabled: !_busy,
              onConfirmed: () => runAndClose(
                context,
                () => ref.read(growthRepositoryProvider).delete(existing.id),
                onDone: () => ref.invalidate(growthMeasurementsProvider(widget.baby.id)),
              ),
            ),
        ],
      ),
    );
  }
}

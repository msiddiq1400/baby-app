import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/numbers.dart';
import '../../data/baby_repository.dart';
import '../../data/models.dart';
import '../../data/photo_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/country_picker.dart';
import '../common/language_menu.dart';
import '../common/sheet.dart';
import '../settings/join_family_dialog.dart';

/// Adds a baby, or edits [existing]. Shown by itself on first run (when
/// there's no baby yet) and pushed from Settings afterwards.
class AddBabyScreen extends ConsumerStatefulWidget {
  const AddBabyScreen({super.key, this.existing, this.familyId});

  final Baby? existing;

  /// Family for a new baby; defaults to the user's (first) family.
  final String? familyId;

  @override
  ConsumerState<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends ConsumerState<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _weight = TextEditingController(text: _format(widget.existing?.birthWeightG, 1000));
  late final _length = TextEditingController(text: _format(widget.existing?.birthLengthMm, 10));
  late final _head = TextEditingController(text: _format(widget.existing?.birthHeadMm, 10));
  late DateTime? _birthDate = widget.existing?.birthDate;
  late String? _sex = widget.existing?.sex;

  /// Required for a new baby: picks the vaccine schedule and emergency
  /// numbers, so it's never guessed (many phones in Pakistan are set to US).
  late String? _country = widget.existing?.countryCode;
  var _busy = false;

  static String _format(int? value, int divisor) => value == null ? '' : '${value / divisor}';

  @override
  void dispose() {
    for (final c in [_name, _weight, _length, _head]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPicker(context, selected: _country);
    if (picked != null) setState(() => _country = picked);
  }

  int? _scaled(TextEditingController c, int factor) {
    final n = parseLocalizedNumber(c.text);
    return n == null ? null : (n * factor).round();
  }

  /// Validator for an optional decimal field within [min]..[max].
  FormFieldValidator<String> _range(double min, double max, String message) => (v) {
    if ((v ?? '').trim().isEmpty) return null;
    final n = parseLocalizedNumber(v!);
    return n == null || n < min || n > max ? message : null;
  };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final repo = ref.read(babyRepositoryProvider);
    try {
      final existing = widget.existing;
      if (existing == null) {
        final id = await repo.addBaby(
          name: _name.text.trim(),
          birthDate: _birthDate!,
          countryCode: _country!,
          familyId: widget.familyId,
          sex: _sex,
          birthWeightG: _scaled(_weight, 1000),
          birthLengthMm: _scaled(_length, 10),
          birthHeadMm: _scaled(_head, 10),
        );
        await selectBaby(ref, id);
      } else {
        await repo.updateBaby(
          existing.id,
          name: _name.text.trim(),
          birthDate: _birthDate!,
          countryCode: _country!,
          sex: _sex,
          birthWeightG: _scaled(_weight, 1000),
          birthLengthMm: _scaled(_length, 10),
          birthHeadMm: _scaled(_head, 10),
        );
      }
      // Pushed from Settings: go back. First run: the shell swaps this out.
      if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existing = widget.existing;
    final dateText = _birthDate == null ? '' : MaterialLocalizations.of(context).formatMediumDate(_birthDate!);
    final countryText = _country == null ? '' : countryLabel(context, _country!);
    const decimal = TextInputType.numberWithOptions(decimal: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? l10n.addBabyTitle : l10n.editBabyTitle),
        actions: [if (!Navigator.of(context).canPop()) const LanguageMenu(showSignOut: true)],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // First run: a caregiver who was invited should join instead
              // of creating a second profile for the same baby.
              if (existing == null && !Navigator.of(context).canPop()) ...[
                OutlinedButton.icon(
                  onPressed: () => showJoinFamilyDialog(context),
                  icon: const Icon(Icons.group_add_outlined),
                  label: Text(l10n.joinFamilyPrompt),
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.babyNameLabel),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              // Read-only field so the date gets normal form validation.
              TextFormField(
                key: ValueKey(dateText),
                initialValue: dateText,
                readOnly: true,
                onTap: _pickBirthDate,
                decoration: InputDecoration(
                  labelText: l10n.birthDateLabel,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                validator: (_) => _birthDate == null ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: ValueKey('country-$countryText'),
                initialValue: countryText,
                readOnly: true,
                onTap: _pickCountry,
                decoration: InputDecoration(
                  labelText: l10n.countryLabel,
                  helperText: l10n.countryHelp,
                  helperMaxLines: 3,
                  suffixIcon: const Icon(Icons.public),
                ),
                validator: (_) => _country == null ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 20),
              Text(l10n.sexLabel, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'female', label: Text(l10n.sexFemale)),
                  ButtonSegment(value: 'male', label: Text(l10n.sexMale)),
                ],
                selected: {?_sex},
                emptySelectionAllowed: true,
                onSelectionChanged: (s) => setState(() => _sex = s.firstOrNull),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weight,
                decoration: InputDecoration(labelText: l10n.birthWeightLabel),
                keyboardType: decimal,
                validator: _range(0.3, 7, l10n.invalidWeight),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _length,
                decoration: InputDecoration(labelText: l10n.birthLengthLabel),
                keyboardType: decimal,
                validator: _range(20, 70, l10n.invalidBirthLength),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _head,
                decoration: InputDecoration(labelText: l10n.birthHeadLabel),
                keyboardType: decimal,
                validator: _range(20, 50, l10n.invalidBirthHead),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.saveButton),
              ),
              if (existing != null)
                DeleteButton(
                  enabled: !_busy,
                  onConfirmed: () async {
                    // Photo files live in Storage, not the database: remove them too.
                    await ref.read(photoRepositoryProvider).deleteAllFor(existing);
                    await ref.read(babyRepositoryProvider).delete(existing.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

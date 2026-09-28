import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/baby_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';

class AddBabyScreen extends ConsumerStatefulWidget {
  const AddBabyScreen({super.key});

  @override
  ConsumerState<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends ConsumerState<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _weight = TextEditingController();
  DateTime? _birthDate;
  String? _sex;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final kg = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
      await ref.read(babyRepositoryProvider).addBaby(
            name: _name.text.trim(),
            birthDate: _birthDate!,
            sex: _sex,
            birthWeightG: kg == null ? null : (kg * 1000).round(),
          );
      ref.invalidate(currentBabyProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateText = _birthDate == null
        ? ''
        : DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(_birthDate!);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addBabyTitle),
        actions: const [LanguageMenu(showSignOut: true)],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final text = (v ?? '').trim();
                  if (text.isEmpty) return null;
                  final kg = double.tryParse(text.replaceAll(',', '.'));
                  return kg == null || kg < 0.3 || kg > 7 ? l10n.invalidWeight : null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

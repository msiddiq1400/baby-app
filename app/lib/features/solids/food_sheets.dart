import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/solids_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/country_picker.dart';
import '../common/sheet.dart';

IconData categoryIcon(String category) => switch (category) {
      'fruit' => Icons.local_florist_outlined,
      'vegetable' => Icons.eco_outlined,
      'grain' => Icons.rice_bowl_outlined,
      'legume' => Icons.soup_kitchen_outlined,
      'protein' => Icons.egg_outlined,
      'dairy' => Icons.icecream_outlined,
      'nut' => Icons.scatter_plot_outlined,
      _ => Icons.block,
    };

String categoryName(AppLocalizations l10n, String category) => switch (category) {
      'fruit' => l10n.categoryFruit,
      'vegetable' => l10n.categoryVegetable,
      'grain' => l10n.categoryGrain,
      'legume' => l10n.categoryLegume,
      'protein' => l10n.categoryProtein,
      'dairy' => l10n.categoryDairy,
      'nut' => l10n.categoryNut,
      _ => l10n.categoryOther,
    };

/// A food's guide (preparation, allergen and choking notes) and the baby's
/// tries of it.
Future<void> showFoodSheet(BuildContext context, Baby baby, FoodGuide guide, Food food) =>
    showFormSheet(context, _FoodSheet(baby: baby, guide: guide, food: food));

class _FoodSheet extends ConsumerWidget {
  const _FoodSheet({required this.baby, required this.guide, required this.food});

  final Baby baby;
  final FoodGuide guide;
  final Food food;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tries = (ref.watch(foodTriesProvider(baby.id)).value ?? const []).where((t) => t.foodId == food.id).toList();
    final hadReaction = tries.any((t) => t.reaction != 'none');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(categoryIcon(food.category), color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(food.name.of(l10n), style: theme.textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 4),
        Text(l10n.fromMonths(food.fromMonths), style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        Text(food.prep.of(l10n)),
        if (food.allergen case final allergen?)
          _Note(
            icon: Icons.warning_amber,
            text: '${l10n.allergenLabel(guide.allergens[allergen]?.of(l10n) ?? allergen)}. ${guide.allergenAdvice.of(l10n)}',
            color: theme.colorScheme.tertiaryContainer,
          ),
        if (food.choking) _Note(icon: Icons.report_outlined, text: l10n.chokingRisk, color: theme.colorScheme.secondaryContainer),
        if (hadReaction) _Note(icon: Icons.error_outline, text: l10n.reactionWarning, color: theme.colorScheme.errorContainer),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => showTrySheet(context, baby, food),
          icon: const Icon(Icons.add),
          label: Text(l10n.logTry),
        ),
        const SizedBox(height: 8),
        for (final t in tries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_opinionIcon(t.opinion)),
            title: Text(MaterialLocalizations.of(context).formatMediumDate(t.triedOn)),
            subtitle: Text([
              if (t.opinion != null) _opinionName(l10n, t.opinion!),
              if (t.reaction != 'none') _reactionName(l10n, t.reaction),
              ?t.notes,
            ].join(' · ')),
            trailing: t.reaction == 'none' ? null : Icon(Icons.warning_amber, color: theme.colorScheme.error),
            onTap: () => showTrySheet(context, baby, food, existing: t),
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        color: color,
        margin: const EdgeInsets.only(top: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Icon(icon, size: 20), const SizedBox(width: 8), Expanded(child: Text(text))],
          ),
        ),
      );
}

IconData _opinionIcon(String? opinion) => switch (opinion) {
      'liked' => Icons.sentiment_very_satisfied,
      'disliked' => Icons.sentiment_dissatisfied,
      'neutral' => Icons.sentiment_neutral,
      _ => Icons.restaurant,
    };

String _opinionName(AppLocalizations l10n, String opinion) => switch (opinion) {
      'liked' => l10n.opinionLiked,
      'disliked' => l10n.opinionDisliked,
      _ => l10n.opinionNeutral,
    };

String _reactionName(AppLocalizations l10n, String reaction) => switch (reaction) {
      'mild' => l10n.reactionMild,
      'severe' => l10n.reactionSevere,
      _ => l10n.reactionNone,
    };

/// Log a try of [food], or edit [existing].
Future<void> showTrySheet(BuildContext context, Baby baby, Food food, {FoodTry? existing}) =>
    showFormSheet(context, _TrySheet(baby: baby, food: food, existing: existing));

class _TrySheet extends ConsumerStatefulWidget {
  const _TrySheet({required this.baby, required this.food, this.existing});

  final Baby baby;
  final Food food;
  final FoodTry? existing;

  @override
  ConsumerState<_TrySheet> createState() => _TrySheetState();
}

class _TrySheetState extends ConsumerState<_TrySheet> {
  late DateTime _date = widget.existing?.triedOn ?? DateTime.now();
  late String? _opinion = widget.existing?.opinion;
  late String _reaction = widget.existing?.reaction ?? 'none';
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  var _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    await runAndClose(
      context,
      () => ref.read(solidsRepositoryProvider).saveTry(
            widget.baby,
            existingId: widget.existing?.id,
            foodId: widget.food.id,
            triedOn: _date,
            opinion: _opinion,
            reaction: _reaction,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
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
        Text(
          '${existing == null ? l10n.logTry : l10n.editTry}: ${widget.food.name.of(l10n)}',
          style: theme.textTheme.titleLarge,
        ),
        DateField(
          label: l10n.dateLabel,
          date: _date,
          firstDate: widget.baby.birthDate,
          onChanged: (d) => setState(() => _date = d),
        ),
        Text(l10n.opinionLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'liked', label: Text(l10n.opinionLiked)),
            ButtonSegment(value: 'neutral', label: Text(l10n.opinionNeutral)),
            ButtonSegment(value: 'disliked', label: Text(l10n.opinionDisliked)),
          ],
          selected: {?_opinion},
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _opinion = s.firstOrNull),
        ),
        const SizedBox(height: 12),
        Text(l10n.reactionLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'none', label: Text(l10n.reactionNone)),
            ButtonSegment(value: 'mild', label: Text(l10n.reactionMild)),
            ButtonSegment(value: 'severe', label: Text(l10n.reactionSevere)),
          ],
          selected: {_reaction},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _reaction = s.first),
        ),
        if (_reaction == 'severe')
          Card(
            color: theme.colorScheme.errorContainer,
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: Icon(Icons.local_hospital, color: theme.colorScheme.onErrorContainer),
              title: Text(l10n.severeReactionNow(emergencyNumberText(context, widget.baby.countryCode)), style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            ),
          ),
        const SizedBox(height: 12),
        TextField(controller: _notes, decoration: InputDecoration(labelText: l10n.notesLabel), maxLines: 2),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.saveButton)),
        if (existing != null)
          DeleteButton(
            enabled: !_busy,
            onConfirmed: () => runAndClose(
              context,
              () => ref.read(solidsRepositoryProvider).deleteTry(existing.id),
              onDone: () {},
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_age.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/solids_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import 'food_sheets.dart';
import 'recipes_screen.dart';

/// Solids tab: readiness and safety guides, the allergen tracker, and the
/// food list with what the baby has tried.
class SolidsScreen extends ConsumerStatefulWidget {
  const SolidsScreen({super.key, required this.baby});

  final Baby baby;

  @override
  ConsumerState<SolidsScreen> createState() => _SolidsScreenState();
}

class _SolidsScreenState extends ConsumerState<SolidsScreen> {
  String? _category;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guide = ref.watch(foodGuideProvider);
    final tries = ref.watch(foodTriesProvider(widget.baby.id)).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.solidsTitle), actions: const [LanguageMenu(showSignOut: true)]),
      body: switch (guide) {
        AsyncData(value: final guide) => _body(context, guide, tries),
        AsyncError() => Center(child: Text(l10n.errorGeneric)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(BuildContext context, FoodGuide guide, List<FoodTry> tries) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final baby = widget.baby;
    final ageMonths = babyAge(baby.birthDate, DateTime.now()).months;
    // Vegetables first: the advice is to start with them, before fruit.
    int rank(String category) => category == 'vegetable' ? 0 : 1;
    final categories = {for (final f in guide.foods) f.category}.toList()
      ..sort((a, b) => rank(a).compareTo(rank(b)));
    final query = _query.trim().toLowerCase();
    final foods = [
      for (final f in guide.foods)
        if ((_category == null || f.category == _category) &&
            (query.isEmpty ||
                f.name.of(l10n).toLowerCase().contains(query) ||
                f.name.english.toLowerCase().contains(query)))
          f,
    ]..sort((a, b) => rank(a.category).compareTo(rank(b.category)));

    Widget guideTile(IconData icon, String title, List<Widget> children, {Color? color}) => Card(
          color: color,
          child: ExpansionTile(
            leading: Icon(icon),
            title: Text(title),
            shape: const Border(),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (ageMonths < 5)
          Card(
            child: ListTile(leading: const Icon(Icons.info_outline), title: Text(l10n.solidsTooYoung)),
          ),
        guideTile(Icons.checklist, l10n.readinessTitle, [Text(guide.readiness.of(l10n))]),
        if (guide.vegFirst case final v?) guideTile(Icons.eco_outlined, l10n.vegFirstTitle, [Text(v.of(l10n))]),
        guideTile(Icons.layers_outlined, l10n.texturesTitle, [
          for (final s in guide.stages) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(s.of(l10n))),
        ]),
        guideTile(Icons.rule, l10n.foodRulesTitle, [
          for (final r in guide.rules) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('• ${r.of(l10n)}')),
        ]),
        guideTile(
          Icons.health_and_safety_outlined,
          l10n.reactionSignsTitle,
          [Text(guide.reactionSigns.of(l10n))],
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        ),
        guideTile(Icons.fact_check_outlined, l10n.beliefsTitle, [
          for (final m in guide.myths)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.beliefLabel}: "${m.belief.of(l10n)}"', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text('${l10n.evidenceLabel}: ${m.evidence.of(l10n)}'),
                ],
              ),
            ),
        ]),
        if (guide.recipes.isNotEmpty)
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(l10n.recipesTitle),
              subtitle: Text(l10n.recipesSubtitle(guide.recipes.length)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(builder: (_) => RecipesScreen(baby: baby, guide: guide)),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(l10n.allergensTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [for (final e in guide.allergens.entries) _AllergenChip(guide: guide, allergen: e.key, tries: tries)],
        ),
        const SizedBox(height: 16),
        Text(l10n.foodsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.searchFoods),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(l10n.categoryAll),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in categories)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: ChoiceChip(
                    label: Text(categoryName(l10n, c)),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                ),
            ],
          ),
        ),
        for (final food in foods) _FoodTile(baby: baby, guide: guide, food: food, tries: tries),
        const SizedBox(height: 16),
        Text(l10n.sourcesLabel(guide.sources), style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.guide, required this.allergen, required this.tries});

  final FoodGuide guide;
  final String allergen;
  final List<FoodTry> tries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final foodIds = {for (final f in guide.foods) if (f.allergen == allergen) f.id};
    final relevant = tries.where((t) => foodIds.contains(t.foodId));
    final (status, icon, color) = relevant.any((t) => t.reaction != 'none')
        ? (l10n.allergenReaction, Icons.warning_amber, colors.errorContainer)
        : relevant.isNotEmpty
            ? (l10n.allergenIntroduced, Icons.check_circle_outline, colors.primaryContainer)
            : (l10n.allergenNotYet, Icons.radio_button_unchecked, colors.surfaceContainerHighest);

    return Chip(
      avatar: Icon(icon, size: 18),
      backgroundColor: color,
      label: Text('${guide.allergens[allergen]!.of(l10n)}: $status'),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.baby, required this.guide, required this.food, required this.tries});

  final Baby baby;
  final FoodGuide guide;
  final Food food;
  final List<FoodTry> tries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final mine = tries.where((t) => t.foodId == food.id).toList();
    final reaction = mine.any((t) => t.reaction != 'none');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(categoryIcon(food.category), color: colors.primary),
      title: Text(food.name.of(l10n)),
      subtitle: Text([
        l10n.fromMonths(food.fromMonths),
        mine.isEmpty ? l10n.notTried : l10n.triedTimes(mine.length),
      ].join(' · ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (food.allergen != null) Icon(Icons.warning_amber, size: 18, color: colors.tertiary),
          if (food.choking) Icon(Icons.report_outlined, size: 18, color: colors.secondary),
          if (reaction)
            Icon(Icons.error, color: colors.error)
          else if (mine.isNotEmpty)
            Icon(Icons.check_circle, color: colors.primary),
        ],
      ),
      onTap: () => showFoodSheet(context, baby, guide, food),
    );
  }
}

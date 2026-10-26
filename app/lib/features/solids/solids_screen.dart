import 'package:flutter/material.dart';

import '../../core/baby_age.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/solids_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/country_picker.dart';
import 'food_sheets.dart';

/// A collapsible guide card.
Widget _guideTile(
  IconData icon,
  String title,
  List<Widget> children, {
  Color? color,
  ExpansibleController? controller,
  ValueChanged<bool>? onExpansionChanged,
}) =>
    Card(
      color: color,
      child: ExpansionTile(
        controller: controller,
        onExpansionChanged: onExpansionChanged,
        leading: Icon(icon),
        title: Text(title),
        shape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

/// Safety first: on the Foods tab, where new foods are given.
Widget _reactionSignsTile(BuildContext context, Baby baby, FoodGuide guide) => _guideTile(
      Icons.health_and_safety_outlined,
      AppLocalizations.of(context).reactionSignsTitle,
      [Text(guide.reactionSigns.of(AppLocalizations.of(context)).replaceAll('{emergency}', emergencyNumberText(context, baby.countryCode)))],
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
    );

// Vegetables first: the advice is to start with them, before fruit.
int _categoryRank(String category) => category == 'vegetable' ? 0 : 1;

/// Solids on the Feeding tab: what the baby has tried, allergens and the
/// food list.
class FoodsView extends StatefulWidget {
  const FoodsView({super.key, required this.baby, required this.guide, required this.tries});

  final Baby baby;
  final FoodGuide guide;
  final List<FoodTry> tries;

  @override
  State<FoodsView> createState() => _FoodsViewState();
}

class _FoodsViewState extends State<FoodsView> {
  String? _category;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final baby = widget.baby;
    final guide = widget.guide;
    final tries = widget.tries;
    final ageMonths = babyAge(baby.birthDate, DateTime.now()).months;

    final triesByFood = <String, List<FoodTry>>{};
    for (final t in tries) {
      (triesByFood[t.foodId] ??= []).add(t);
    }
    DateTime lastTry(Food f) =>
        triesByFood[f.id]!.map((t) => t.triedOn).reduce((a, b) => a.isAfter(b) ? a : b);

    final triedCount = guide.foods.where((f) => triesByFood.containsKey(f.id)).length;
    final introducedAllergens = guide.allergens.keys
        .where((a) => guide.foods.any((f) => f.allergen == a && triesByFood.containsKey(f.id)))
        .length;

    final categories = {for (final f in guide.foods) f.category}.toList()
      ..sort((a, b) => _categoryRank(a).compareTo(_categoryRank(b)));
    final query = _query.trim().toLowerCase();
    final shown = [
      for (final f in guide.foods)
        if ((_category == null || f.category == _category) &&
            (query.isEmpty ||
                f.name.of(l10n).toLowerCase().contains(query) ||
                f.name.english.toLowerCase().contains(query)))
          f,
    ];
    // Tried: most recent first. Not tried: vegetables first, then by age.
    final tried = shown.where((f) => triesByFood.containsKey(f.id)).toList()
      ..sort((a, b) => lastTry(b).compareTo(lastTry(a)));
    final notTried = shown.where((f) => !triesByFood.containsKey(f.id)).toList()
      ..sort((a, b) {
        final byCategory = _categoryRank(a.category).compareTo(_categoryRank(b.category));
        return byCategory != 0 ? byCategory : a.fromMonths.compareTo(b.fromMonths);
      });

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
        );
    Widget tile(Food f) => _FoodTile(
          baby: baby,
          guide: guide,
          food: f,
          tries: triesByFood[f.id] ?? const [],
          ageMonths: ageMonths,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.solidsFoodsProgress(triedCount, guide.foods.length), style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: guide.foods.isEmpty ? 0 : triedCount / guide.foods.length,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.solidsAllergensProgress(introducedAllergens, guide.allergens.length),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        _reactionSignsTile(context, baby, guide),
        const SizedBox(height: 12),
        Text(l10n.allergensTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final a in guide.allergens.keys) _AllergenChip(guide: guide, allergen: a, triesByFood: triesByFood)],
        ),
        const SizedBox(height: 16),
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
        if (tried.isNotEmpty) ...[header(l10n.foodsTried), for (final f in tried) tile(f)],
        if (notTried.isNotEmpty) ...[header(l10n.notTried), for (final f in notTried) tile(f)],
      ],
    );
  }
}

// The allergic-reaction signs are on the Foods tab, where new foods are given.
enum _Guide { readiness, vegFirst, textures, rules, beliefs }

/// The solids guides (readiness, textures, rules...), as an accordion:
/// opening one closes the one that was open.
class SolidsGuidesView extends StatefulWidget {
  const SolidsGuidesView({super.key, required this.baby, required this.guide, required this.tooYoung});

  final Baby baby;
  final FoodGuide guide;
  final bool tooYoung;

  @override
  State<SolidsGuidesView> createState() => _GuidesViewState();
}

class _GuidesViewState extends State<SolidsGuidesView> {
  final _controllers = {for (final g in _Guide.values) g: ExpansibleController()};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _opened(_Guide opened, bool expanded) {
    if (!expanded) return;
    for (final MapEntry(key: g, value: c) in _controllers.entries) {
      if (g != opened && c.isExpanded) c.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final guide = widget.guide;

    Widget tile(_Guide g, IconData icon, String title, List<Widget> children) => _guideTile(
          icon,
          title,
          children,
          controller: _controllers[g],
          onExpansionChanged: (expanded) => _opened(g, expanded),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (widget.tooYoung)
          Card(
            child: ListTile(leading: const Icon(Icons.info_outline), title: Text(l10n.solidsTooYoung)),
          ),
        tile(_Guide.readiness, Icons.checklist, l10n.readinessTitle, [Text(guide.readiness.of(l10n))]),
        if (guide.vegFirst case final v?) tile(_Guide.vegFirst, Icons.eco_outlined, l10n.vegFirstTitle, [Text(v.of(l10n))]),
        tile(_Guide.textures, Icons.layers_outlined, l10n.texturesTitle, [
          for (final s in guide.stages) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(s.of(l10n))),
        ]),
        tile(_Guide.rules, Icons.rule, l10n.foodRulesTitle, [
          for (final r in guide.rules) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('• ${r.of(l10n)}')),
        ]),
        tile(_Guide.beliefs, Icons.fact_check_outlined, l10n.beliefsTitle, [
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
        const SizedBox(height: 16),
        Text(l10n.sourcesLabel(guide.sources), style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// An allergen with its status as an icon and colour (name only, so the
/// chips stay short); the full status is in the tooltip and for screen
/// readers.
class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.guide, required this.allergen, required this.triesByFood});

  final FoodGuide guide;
  final String allergen;
  final Map<String, List<FoodTry>> triesByFood;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final relevant = [
      for (final f in guide.foods)
        if (f.allergen == allergen) ...?triesByFood[f.id],
    ];
    final (status, icon, color) = relevant.any((t) => t.reaction != 'none')
        ? (l10n.allergenReaction, Icons.warning_amber, colors.errorContainer)
        : relevant.isNotEmpty
            ? (l10n.allergenIntroduced, Icons.check_circle_outline, colors.primaryContainer)
            : (l10n.allergenNotYet, Icons.radio_button_unchecked, colors.surfaceContainerHighest);
    final name = guide.allergens[allergen]!.of(l10n);

    return Tooltip(
      message: '$name: $status',
      excludeFromSemantics: true,
      child: Semantics(
        label: '$name: $status',
        excludeSemantics: true,
        child: Chip(
          avatar: Icon(icon, size: 18),
          backgroundColor: color,
          visualDensity: VisualDensity.compact,
          label: Text(name),
        ),
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({
    required this.baby,
    required this.guide,
    required this.food,
    required this.tries,
    required this.ageMonths,
  });

  final Baby baby;
  final FoodGuide guide;
  final Food food;
  final List<FoodTry> tries;
  final int ageMonths;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final reaction = tries.any((t) => t.reaction != 'none');
    // Only say "from N months" while the baby is younger than that.
    final subtitle = tries.isNotEmpty
        ? l10n.triedTimes(tries.length)
        : ageMonths < food.fromMonths
            ? l10n.fromMonths(food.fromMonths)
            : null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(categoryIcon(food.category), color: colors.primary),
      title: Text(food.name.of(l10n)),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (food.allergen != null) Icon(Icons.warning_amber, size: 18, color: colors.tertiary),
          if (food.choking) Icon(Icons.report_outlined, size: 18, color: colors.secondary),
          if (reaction)
            Icon(Icons.error, color: colors.error)
          else if (tries.isNotEmpty)
            Icon(Icons.check_circle, color: colors.primary),
        ],
      ),
      onTap: () => showFoodSheet(context, baby, guide, food),
    );
  }
}

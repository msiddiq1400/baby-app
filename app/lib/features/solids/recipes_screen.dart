import 'package:flutter/material.dart';

import '../../core/baby_age.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'food_sheets.dart';

/// Home-style recipes grouped by age (from 6, 7 and 10 months). Recipes the
/// baby isn't old enough for yet are shown but marked.
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key, required this.baby, required this.guide});

  final Baby baby;
  final FoodGuide guide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ageMonths = babyAge(baby.birthDate, DateTime.now()).months;
    final stages = {for (final r in guide.recipes) r.fromMonths}.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recipesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.recipesRules, style: theme.textTheme.bodyMedium),
          for (final months in stages) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recipesFromMonths(months),
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                  if (ageMonths < months)
                    Text(l10n.recipesNotYet, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            for (final r in guide.recipes.where((r) => r.fromMonths == months))
              _RecipeCard(baby: baby, guide: guide, recipe: r),
          ],
          const SizedBox(height: 16),
          Text(l10n.recipesSource, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.baby, required this.guide, required this.recipe});

  final Baby baby;
  final FoodGuide guide;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final foods = [for (final id in recipe.foods) ?guide.food(id)];

    return Card(
      child: ExpansionTile(
        shape: const Border(),
        leading: const Icon(Icons.restaurant_menu),
        title: Text(recipe.name.of(l10n)),
        subtitle: recipe.allergens.isEmpty
            ? null
            : Text(
                l10n.recipeContains(recipe.allergens.map((a) => guide.allergens[a]?.of(l10n) ?? a).join(', ')),
                style: TextStyle(color: theme.colorScheme.error),
              ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.recipeIngredients, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final i in recipe.ingredients)
            Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• ${i.of(l10n)}')),
          const SizedBox(height: 8),
          Text(l10n.recipeSteps, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final (n, s) in recipe.steps.indexed)
            Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('${n + 1}. ${s.of(l10n)}')),
          if (foods.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.recipeLogTry, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final f in foods)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(f.name.of(l10n)),
                    onPressed: () => showTrySheet(context, baby, f),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

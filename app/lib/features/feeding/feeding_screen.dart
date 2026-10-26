import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_age.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/solids_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import '../common/tab_title.dart';
import '../milk/milk_screen.dart';
import '../solids/recipes_screen.dart';
import '../solids/solids_screen.dart';

/// Feeding tab: breast milk (pumping and the stash), then solids (foods,
/// guides, recipes). Was two tabs, Milk and Solids; one tab keeps the
/// bottom bar to four. Babies too young for solids open on Milk.
class FeedingScreen extends ConsumerWidget {
  const FeedingScreen({super.key, required this.baby});

  final Baby baby;

  /// Tab order.
  static const milkTab = 0, foodsTab = 1, guidesTab = 2, recipesTab = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final guide = ref.watch(foodGuideProvider);
    final tries = ref.watch(foodTriesProvider(baby.id)).value ?? const [];
    final tooYoung = babyAge(baby.birthDate, DateTime.now()).months < 5;

    Widget solids(Widget Function(FoodGuide guide) builder) => switch (guide) {
          AsyncData(value: final guide) => builder(guide),
          AsyncError() => Center(child: Text(l10n.errorGeneric)),
          _ => const Center(child: CircularProgressIndicator()),
        };

    return DefaultTabController(
      length: 4,
      initialIndex: tooYoung ? milkTab : foodsTab,
      child: Scaffold(
        appBar: AppBar(
          title: TabTitle(title: l10n.tabFeeding, baby: baby),
          actions: const [MainActions()],
          bottom: TabBar(
            // Four tabs: in Urdu the labels are wider than a quarter of a
            // small phone, so the bar scrolls rather than squeezing them.
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: l10n.tabMilk),
              Tab(text: l10n.foodsTitle),
              Tab(text: l10n.solidsTabGuides),
              Tab(text: l10n.solidsTabRecipes),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MilkView(baby: baby),
            solids((g) => FoodsView(baby: baby, guide: g, tries: tries)),
            solids((g) => SolidsGuidesView(baby: baby, guide: g, tooYoung: tooYoung)),
            solids((g) => RecipesView(baby: baby, guide: g)),
          ],
        ),
      ),
    );
  }
}

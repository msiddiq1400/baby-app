import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/baby_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../baby/add_baby_screen.dart';
import '../health/health_reminders.dart';

/// Wraps the tabs: shows the add-baby form until there is a baby, then
/// the bottom navigation with the current tab.
class BabyShell extends ConsumerWidget {
  const BabyShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Keep the phone's reminders up to date while the app is open.
    ref.listen(vaccineRemindersProvider, (_, _) {});
    ref.listen(medicineRemindersProvider, (_, _) {});
    return ref.watch(currentBabyProvider).when(
          data: (baby) => baby == null
              ? const AddBabyScreen()
              : Scaffold(
                  body: shell,
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: shell.currentIndex,
                    onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.today_outlined),
                        selectedIcon: const Icon(Icons.today),
                        label: l10n.tabToday,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.show_chart),
                        label: l10n.tabGrowth,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.vaccines_outlined),
                        selectedIcon: const Icon(Icons.vaccines),
                        label: l10n.tabHealth,
                      ),
                    ],
                  ),
                ),
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.errorGeneric),
                  const SizedBox(height: 12),
                  IconButton.filledTonal(
                    onPressed: () => ref.invalidate(currentBabyProvider),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

/// Builds a tab screen for the current baby. The shell guarantees a baby
/// exists; during sign-out it can briefly be gone, so render nothing then.
class WithBaby extends ConsumerWidget {
  const WithBaby({super.key, required this.builder});

  final Widget Function(Baby baby) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(currentBabyProvider).value;
    return baby == null ? const SizedBox.shrink() : builder(baby);
  }
}

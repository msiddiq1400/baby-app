import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/baby_repository.dart';
import '../../data/local_db.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../baby/add_baby_screen.dart';
import '../health/health_reminders.dart';
import '../milk/milk_reminders.dart';
import 'home_widget_sync.dart';
import 'live_timers.dart';
import 'quick_log_bar.dart';

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
    ref.listen(milkRemindersProvider, (_, _) {});
    ref.listen(timerNotificationsProvider, (_, _) {});
    ref.listen(homeWidgetSyncProvider, (_, _) {});

    // Until the first download after signing in has finished, "no baby"
    // might just mean "not synced yet": don't offer to add one.
    final status = ref.watch(syncStatusProvider).value;
    if (status?.hasSynced != true) return const _FirstSync();

    return ref.watch(currentBabyProvider).when(
          data: (baby) => baby == null
              ? const AddBabyScreen()
              : Scaffold(
                  // Offline works the same as online (entries upload later),
                  // so there's no offline notice.
                  body: shell,
                  // Feed / Diaper / Sleep sit above the tabs on every screen.
                  bottomNavigationBar: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuickLogBar(baby: baby),
                      NavigationBar(
                        selectedIndex: shell.currentIndex,
                        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                        destinations: [
                          NavigationDestination(
                            icon: const Icon(Icons.today_outlined),
                            selectedIcon: const Icon(Icons.today),
                            label: l10n.tabToday,
                          ),
                          NavigationDestination(
                            icon: const Icon(Icons.water_drop_outlined),
                            selectedIcon: const Icon(Icons.water_drop),
                            label: l10n.tabMilk,
                          ),
                          NavigationDestination(
                            icon: const Icon(Icons.restaurant_outlined),
                            selectedIcon: const Icon(Icons.restaurant),
                            label: l10n.tabSolids,
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

class _FirstSync extends StatelessWidget {
  const _FirstSync();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(l10n.firstSyncLoading, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l10n.firstSyncNeedsInternet, textAlign: TextAlign.center),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/baby_repository.dart';
import '../../l10n/app_localizations.dart';
import '../baby/add_baby_screen.dart';
import 'dashboard.dart';

/// Shows the dashboard, or the add-baby form if there's no baby yet.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(currentBabyProvider).when(
          data: (baby) => baby == null ? const AddBabyScreen() : Dashboard(baby: baby),
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).errorGeneric),
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

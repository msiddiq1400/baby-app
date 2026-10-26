import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_age.dart';
import '../../data/baby_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

/// App-bar title for a main tab: the tab's name with the baby's name under
/// it, so with two babies it's always clear whose entries these are. With
/// more than one baby, tapping it switches baby.
class TabTitle extends ConsumerWidget {
  const TabTitle({super.key, required this.title, required this.baby});

  final String title;
  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final several = (ref.watch(babiesProvider).value?.length ?? 0) > 1;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, overflow: TextOverflow.ellipsis),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                baby.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            if (several) Icon(Icons.arrow_drop_down, size: 20, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ],
    );
    return several ? InkWell(onTap: () => showBabySwitcher(context, ref), child: content) : content;
  }
}

/// Lists the babies to switch between (only when there's more than one).
void showBabySwitcher(BuildContext context, WidgetRef ref) {
  final babies = ref.read(babiesProvider).value ?? const [];
  if (babies.length < 2) return;
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      // Clear of the phone's navigation buttons.
      minimum: const EdgeInsets.only(bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.switchBaby, style: Theme.of(context).textTheme.titleMedium),
          for (final b in babies)
            ListTile(
              leading: const Icon(Icons.child_care),
              title: Text(b.name),
              subtitle: Text(formatBabyAge(l10n, b.birthDate, DateTime.now())),
              onTap: () {
                selectBaby(ref, b.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}

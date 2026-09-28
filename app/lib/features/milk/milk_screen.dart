import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/milk_repository.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import 'milk_rules.dart';
import 'milk_sheets.dart';

/// Milk tab: pumping today, the stored-milk inventory, and storage guidance.
class MilkScreen extends ConsumerWidget {
  const MilkScreen({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bags = ref.watch(milkBagsProvider(baby.id));
    final pumping = ref.watch(pumpingTodayProvider(baby.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.milkTitle), actions: const [LanguageMenu(showSignOut: true)]),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.refresh(milkBagsProvider(baby.id).future),
          ref.refresh(pumpingTodayProvider(baby.id).future),
        ]),
        child: switch ((bags, pumping)) {
          (AsyncData(value: final bags), AsyncData(value: final sessions)) =>
            _MilkBody(baby: baby, bags: bags, sessions: sessions),
          (AsyncError(), _) || (_, AsyncError()) => ListView(
              children: [
                Padding(padding: const EdgeInsets.all(32), child: Text(l10n.errorGeneric, textAlign: TextAlign.center)),
              ],
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _MilkBody extends StatelessWidget {
  const _MilkBody({required this.baby, required this.bags, required this.sessions});

  final Baby baby;
  final List<MilkBag> bags;
  final List<PumpingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final pumpedMl = sessions.fold(0, (sum, s) => sum + (s.amountMl ?? 0));
    final attention = bags.where((b) => milkNeedsAttention(b, now)).length;
    int total(MilkLocation l) => bags.where((b) => b.location == l).fold(0, (sum, b) => sum + b.amountMl);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _TotalCard(label: l10n.locationFridge, ml: total(MilkLocation.fridge) + total(MilkLocation.thawed))),
            Expanded(child: _TotalCard(label: l10n.locationFreezer, ml: total(MilkLocation.freezer))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(l10n.pumpedToday(pumpedMl, sessions.length), style: theme.textTheme.bodyLarge),
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showPumpingSheet(context, baby),
                icon: const Icon(Icons.water_drop_outlined),
                label: Text(l10n.logPumping),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => showAddMilkSheet(context, baby),
                icon: const Icon(Icons.add),
                label: Text(l10n.addStoredMilk),
              ),
            ),
          ],
        ),
        if (attention > 0)
          Card(
            color: theme.colorScheme.errorContainer,
            margin: const EdgeInsets.only(top: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.milkNeedsAttention(attention), style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            ),
          ),
        const SizedBox(height: 8),
        if (bags.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l10n.noStoredMilk, textAlign: TextAlign.center),
          ),
        // Shortest-lasting places first; within each, the milk to use first on top.
        for (final location in const [
          MilkLocation.room,
          MilkLocation.cooler,
          MilkLocation.thawed,
          MilkLocation.fridge,
          MilkLocation.freezer,
        ])
          if (bags.any((b) => b.location == location)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(milkLocationLabel(l10n, location), style: theme.textTheme.titleMedium),
            ),
            for (final bag in sortByUseBy([for (final b in bags) if (b.location == location) b]))
              _BagTile(baby: baby, bag: bag, now: now),
          ],
        if (sessions.isNotEmpty) ...[
          const Divider(height: 32),
          for (final s in sessions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(s.amountMl == null ? l10n.logPumping : '${s.amountMl} ml'),
              trailing: Text(TimeOfDay.fromDateTime(s.startedAt).format(context)),
              onTap: () => showPumpingSheet(context, baby, existing: s),
            ),
        ],
        const Divider(height: 32),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.storageGuideTitle),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          expandedAlignment: AlignmentDirectional.centerStart,
          children: [Text(l10n.storageGuide)],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.power_off_outlined),
          title: Text(l10n.loadSheddingTitle),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          expandedAlignment: AlignmentDirectional.centerStart,
          children: [Text(l10n.loadSheddingGuide)],
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.label, required this.ml});

  final String label;
  final int ml;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            Text(AppLocalizations.of(context).storedMilkTotal(ml), style: theme.textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

enum _BagAction { use, discard }

/// One bag: amount, when pumped, use-by, and a menu to use / move / discard.
class _BagTile extends ConsumerWidget {
  const _BagTile({required this.baby, required this.bag, required this.now});

  final Baby baby;
  final MilkBag bag;
  final DateTime now;

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
      ref.invalidate(milkBagsProvider(baby.id));
      ref.invalidate(todayLogProvider(baby.id));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
      }
    }
  }

  Future<void> _onSelected(BuildContext context, WidgetRef ref, Object choice) async {
    final milk = ref.read(milkRepositoryProvider);
    switch (choice) {
      case _BagAction.use:
        // Using a bag also logs the feed on the Today tab.
        await _run(context, ref, () async {
          await ref.read(trackingRepositoryProvider).saveFeed(
                baby,
                type: FeedType.bottleBreastMilk,
                at: DateTime.now(),
                amountMl: bag.amountMl,
              );
          await milk.finish(bag, used: true);
        });
      case _BagAction.discard:
        await _run(context, ref, () => milk.finish(bag, used: false));
      case MilkLocation to:
        await _run(context, ref, () => milk.move(bag, to));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dates = MaterialLocalizations.of(context);
    final useBy = milkUseBy(bag);
    final expired = useBy.isBefore(now);
    String when(DateTime t) => '${dates.formatShortMonthDay(t)}, ${TimeOfDay.fromDateTime(t).format(context)}';

    final moveLabels = {
      MilkLocation.fridge: l10n.moveToFridge,
      MilkLocation.cooler: l10n.moveToCooler,
      MilkLocation.freezer: l10n.moveToFreezer,
      MilkLocation.thawed: l10n.thawMilk,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        expired ? Icons.warning_amber : Icons.local_drink_outlined,
        color: expired ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text('${bag.amountMl} ml · ${l10n.pumpedOn(when(bag.pumpedAt))}'),
      subtitle: Text(
        [
          expired ? l10n.milkExpired : l10n.useBy(when(useBy)),
          if (bag.location == MilkLocation.thawed) l10n.noRefreeze,
        ].join(' · '),
        style: TextStyle(color: milkNeedsAttention(bag, now) ? theme.colorScheme.error : null),
      ),
      trailing: PopupMenuButton<Object>(
        onSelected: (choice) => _onSelected(context, ref, choice),
        itemBuilder: (context) => [
          if (!expired) PopupMenuItem(value: _BagAction.use, child: Text(l10n.useForFeed)),
          if (!expired)
            for (final to in milkMoves(bag.location)) PopupMenuItem(value: to, child: Text(moveLabels[to]!)),
          PopupMenuItem(value: _BagAction.discard, child: Text(l10n.throwAway)),
        ],
      ),
    );
  }
}

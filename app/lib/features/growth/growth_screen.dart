import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/who_growth.dart';
import '../../data/baby_repository.dart';
import '../../data/growth_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import 'growth_chart.dart';
import 'growth_points.dart';
import 'growth_sheet.dart';
import 'milestones_view.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key, required this.baby});

  final Baby baby;

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> with SingleTickerProviderStateMixin {
  var _metric = GrowthMetric.weight;
  late final _tabs = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final baby = widget.baby;
    final measurements = ref.watch(growthMeasurementsProvider(baby.id));
    final who = ref.watch(whoGrowthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.growthTitle),
        actions: const [LanguageMenu(showSignOut: true)],
        bottom: TabBar(controller: _tabs, tabs: [Tab(text: l10n.tabCharts), Tab(text: l10n.tabMilestones)]),
      ),
      // Adding measurements belongs to the charts tab only.
      floatingActionButton: _tabs.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => showGrowthSheet(context, baby),
              icon: const Icon(Icons.add),
              label: Text(l10n.addMeasurement),
            )
          : null,
      body: TabBarView(
        controller: _tabs,
        children: [
          RefreshIndicator(
            onRefresh: () => ref.refresh(growthMeasurementsProvider(baby.id).future),
            child: switch ((measurements, who)) {
              (AsyncData(value: final list), AsyncData(value: final who)) => _GrowthBody(
                  baby: baby,
                  measurements: list,
                  who: who,
                  metric: _metric,
                  onMetricChanged: (m) => setState(() => _metric = m),
                ),
              (AsyncError(), _) || (_, AsyncError()) => ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.errorGeneric, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
          MilestonesView(baby: baby),
        ],
      ),
    );
  }
}

class _GrowthBody extends ConsumerWidget {
  const _GrowthBody({
    required this.baby,
    required this.measurements,
    required this.who,
    required this.metric,
    required this.onMetricChanged,
  });

  final Baby baby;
  final List<GrowthMeasurement> measurements;
  final WhoGrowth who;
  final GrowthMetric metric;
  final ValueChanged<GrowthMetric> onMetricChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final points = growthPoints(baby, measurements, metric);
    final ageNow = WhoGrowth.ageInMonths(baby.birthDate, DateTime.now());

    return ListView(
      // Room at the bottom so the add button doesn't cover the last row.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        SegmentedButton<GrowthMetric>(
          segments: [
            ButtonSegment(value: GrowthMetric.weight, label: Text(l10n.metricWeight)),
            ButtonSegment(value: GrowthMetric.length, label: Text(l10n.metricLength)),
            ButtonSegment(value: GrowthMetric.head, label: Text(l10n.metricHead)),
          ],
          selected: {metric},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onMetricChanged(s.first),
        ),
        const SizedBox(height: 12),
        if (baby.sex == null) _ChooseSex(baby: baby),
        _LatestCard(baby: baby, who: who, metric: metric, points: points),
        const SizedBox(height: 8),
        GrowthChart(who: who, sex: baby.sex, metric: metric, points: points, ageNowMonths: ageNow),
        const SizedBox(height: 8),
        if (baby.sex != null) Text(l10n.curvesLegend, style: theme.textTheme.bodySmall),
        if (ageNow > WhoGrowth.maxMonths) Text(l10n.whoAgeLimit, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(l10n.percentileExplain, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        if (points.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l10n.noMeasurements, textAlign: TextAlign.center),
          ),
        // History, newest first; tap to edit.
        for (final p in points.reversed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(formatGrowthValue(metric, p.value)),
            subtitle: Text(
              p.measurement == null ? l10n.atBirth : MaterialLocalizations.of(context).formatMediumDate(p.date),
            ),
            trailing: p.measurement == null ? null : const Icon(Icons.edit_outlined, size: 20),
            onTap: p.measurement == null ? null : () => showGrowthSheet(context, baby, existing: p.measurement),
          ),
      ],
    );
  }
}

/// Latest value, its WHO percentile, and the change since the one before.
class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.baby, required this.who, required this.metric, required this.points});

  final Baby baby;
  final WhoGrowth who;
  final GrowthMetric metric;
  final List<GrowthPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final latest = points.last;
    final previous = points.length > 1 ? points[points.length - 2] : null;
    final sex = baby.sex;
    final showPercentile = sex != null && latest.months <= WhoGrowth.maxMonths;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatGrowthValue(metric, latest.value), style: theme.textTheme.headlineMedium),
            if (showPercentile)
              Text(l10n.percentileValue(who.percentile(sex, metric, latest.months, latest.value).round().toString())),
            if (previous != null)
              Text(
                l10n.changeSince(
                  formatGrowthChange(metric, latest.value - previous.value),
                  previous.measurement == null
                      ? l10n.atBirth
                      : MaterialLocalizations.of(context).formatMediumDate(previous.date),
                ),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the baby's sex wasn't entered: WHO curves differ for girls
/// and boys, so ask before drawing them.
class _ChooseSex extends ConsumerWidget {
  const _ChooseSex({required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    Future<void> choose(String sex) async {
      try {
        await ref.read(babyRepositoryProvider).setSex(baby.id, sex);
        ref.invalidate(currentBabyProvider);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
        }
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.chooseSexForChart),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(onPressed: () => choose('female'), child: Text(l10n.sexFemale)),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => choose('male'), child: Text(l10n.sexMale)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

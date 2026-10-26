import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/topic_icons.dart';
import '../../core/weight_velocity.dart';
import '../../core/who_growth.dart';
import '../../data/baby_repository.dart';
import '../../data/growth_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import '../common/tab_title.dart';
import 'growth_chart.dart';
import 'growth_check.dart';
import 'growth_points.dart';
import 'growth_sheet.dart';
import 'milestones_view.dart';
import 'photos_view.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key, required this.baby});

  final Baby baby;

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> with SingleTickerProviderStateMixin {
  var _metric = GrowthMetric.weight;
  late final _tabs = TabController(length: 3, vsync: this)..addListener(() => setState(() {}));

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
        title: TabTitle(title: l10n.growthTitle, baby: baby),
        actions: const [MainActions()],
        bottom: TabBar(
          controller: _tabs,
          tabs: [Tab(text: l10n.tabCharts), Tab(text: l10n.tabMilestones), Tab(text: l10n.tabPhotos)],
        ),
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
          PhotosView(baby: baby),
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
    final check = checkGrowth(
      baby: baby,
      measurements: measurements,
      who: who,
      weightGain: ref.watch(weightVelocityProvider).value?.check(baby, measurements),
    );

    return ListView(
      // Room at the bottom so the add button doesn't cover the last row.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        // All three measures at once, so a problem shows whichever tab is open.
        _GrowthCheckCard(result: check, onShowMetric: onMetricChanged),
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
        if (metric == GrowthMetric.weight) _WeightGainCard(baby: baby, measurements: measurements),
        const SizedBox(height: 8),
        GrowthChart(who: who, sex: baby.sex, metric: metric, points: points, ageNowMonths: ageNow),
        const SizedBox(height: 8),
        if (baby.sex != null) const _Legend(),
        if (ageNow > WhoGrowth.maxMonths)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.whoAgeLimit, style: theme.textTheme.bodyMedium),
          ),
        Card(
          margin: const EdgeInsets.only(top: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.percentileExplainTitle),
            shape: const Border(),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedAlignment: AlignmentDirectional.centerStart,
            children: [Text(l10n.percentileExplain, style: theme.textTheme.bodyLarge)],
          ),
        ),
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
/// Weight gained over about the last month against the WHO velocity
/// standard; hidden until there are two weights 3 to 6 weeks apart.
class _WeightGainCard extends ConsumerWidget {
  const _WeightGainCard({required this.baby, required this.measurements});

  final Baby baby;
  final List<GrowthMeasurement> measurements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final check = ref.watch(weightVelocityProvider).value?.check(baby, measurements);
    if (check == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (note, color) = switch (check.band) {
      GainBand.slow => (l10n.weightGainSlow, theme.colorScheme.tertiaryContainer),
      GainBand.fast => (l10n.weightGainFast, null),
      GainBand.usual => (l10n.weightGainUsual, null),
    };

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.weightGainTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.weightGainSummary(check.gainPerMonthG.toString(), check.daysApart)),
            Text(
              l10n.weightGainRange(check.p5.toString(), check.p95.toString(), check.p50.toString()),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(note),
          ],
        ),
      ),
    );
  }
}

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
    // Whole numbers between 1 and 99: "0 in 100" or "100 in 100" reads oddly.
    final percentile =
        showPercentile ? who.percentile(sex, metric, latest.months, latest.value).round().clamp(1, 99) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatGrowthValue(metric, latest.value), style: theme.textTheme.headlineMedium),
            if (showPercentile) ...[
              Text(l10n.percentileValue(percentile.toString()), style: theme.textTheme.titleMedium),
              Text(
                switch (metric) {
                  GrowthMetric.weight => l10n.percentileMeaningWeight(percentile.toString()),
                  GrowthMetric.length => l10n.percentileMeaningLength(percentile.toString()),
                  GrowthMetric.head => l10n.percentileMeaningHead(percentile.toString()),
                },
                style: theme.textTheme.bodyLarge,
              ),
            ],
            if (previous != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.changeSince(
                    formatGrowthChange(metric, latest.value - previous.value),
                    previous.measurement == null
                        ? l10n.atBirth
                        : MaterialLocalizations.of(context).formatMediumDate(previous.date),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The verdict on top of the charts: talk to a doctor, mention it at the
/// next check-up, or growing as expected; with the reasons in plain words.
/// Tapping a reason shows that measure's chart.
class _GrowthCheckCard extends StatelessWidget {
  const _GrowthCheckCard({required this.result, required this.onShowMetric});

  final GrowthCheckResult result;
  final ValueChanged<GrowthMetric> onShowMetric;

  @override
  Widget build(BuildContext context) {
    if (!result.hasEnoughData) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (title, body, icon, background, foreground) = switch (result.concern) {
      GrowthConcern.doctor => (
          l10n.growthCheckDoctorTitle,
          l10n.growthCheckDoctorBody,
          TopicIcons.doctorVisit,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      GrowthConcern.mention => (
          l10n.growthCheckMentionTitle,
          l10n.growthCheckMentionBody,
          Icons.info_outline,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      GrowthConcern.none => (
          l10n.growthCheckOkTitle,
          l10n.growthCheckOkBody,
          Icons.check_circle_outline,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
    };
    String measure(GrowthMetric m) => switch (m) {
          GrowthMetric.weight => l10n.growthMeasureWeight,
          GrowthMetric.length => l10n.growthMeasureLength,
          GrowthMetric.head => l10n.growthMeasureHead,
        };
    String reason(GrowthFlag f) => switch (f.kind) {
          GrowthFlagKind.belowRange => l10n.growthFlagBelowRange(measure(f.metric)),
          GrowthFlagKind.aboveRange => l10n.growthFlagAboveRange(measure(f.metric)),
          GrowthFlagKind.fallingAcross => l10n.growthFlagFallingAcross(measure(f.metric)),
          GrowthFlagKind.risingAcross => l10n.growthFlagRisingAcross(measure(f.metric)),
          GrowthFlagKind.belowBirthWeight => l10n.growthFlagBelowBirthWeight,
          GrowthFlagKind.slowGain => l10n.growthFlagSlowGain,
        };
    final text = theme.textTheme.bodyLarge?.copyWith(color: foreground);

    return Card(
      color: background,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.growthCheckTitle, style: theme.textTheme.labelLarge?.copyWith(color: foreground)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 28, color: foreground),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleLarge?.copyWith(color: foreground))),
              ],
            ),
            const SizedBox(height: 8),
            for (final f in result.flags)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onShowMetric(f.metric),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ', style: text),
                      Expanded(child: Text(reason(f), style: text?.copyWith(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ),
            if (result.flags.isNotEmpty) const SizedBox(height: 8),
            Text(body, style: text),
            if (result.concern != GrowthConcern.none) ...[
              const SizedBox(height: 8),
              Text(l10n.growthCheckTypo, style: theme.textTheme.bodyMedium?.copyWith(color: foreground)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Key for the chart: the baby's line and the WHO curves.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget item(Color color, double thickness, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: thickness,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: theme.textTheme.bodyMedium)),
          ],
        );
    return Wrap(
      spacing: 20,
      runSpacing: 6,
      children: [
        item(theme.colorScheme.primary, 4, l10n.legendYourBaby),
        item(theme.colorScheme.outline, 2, l10n.legendWhoCurves),
      ],
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

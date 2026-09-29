import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/baby_age.dart';
import '../../data/growth_repository.dart';
import '../../data/medication_repository.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart';
import '../../data/vaccine_repository.dart';
import '../../l10n/app_localizations.dart';
import '../health/medicine_plan.dart';
import '../health/vaccine_plan.dart';
import '../reports/reports_screen.dart';
import 'insights.dart';

/// "At a glance": hunger guide, sleep pattern, awake time, what's due in
/// Health, and latest weight. Each line only shows when there's enough data.
class GlanceCard extends ConsumerWidget {
  const GlanceCard({super.key, required this.baby, required this.now});

  final Baby baby;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String time(DateTime t) => TimeOfDay.fromDateTime(t).format(context);
    String date(DateTime t) => MaterialLocalizations.of(context).formatShortMonthDay(t);

    final feeds = ref.watch(recentFeedsProvider(baby.id)).value ?? const [];
    final sleeps = ref.watch(recentSleepsProvider(baby.id)).value ?? const [];
    final schedule = ref.watch(vaccineScheduleProvider).value ?? const [];
    final given = ref.watch(vaccinationsProvider(baby.id)).value ?? const [];
    final medications = ref.watch(medicationsProvider(baby.id)).value ?? const [];
    final doses = ref.watch(recentDosesProvider(baby.id)).value ?? const [];
    final growth = ref.watch(growthMeasurementsProvider(baby.id)).value ?? const [];

    final lines = <(IconData, String, String?, VoidCallback?)>[];

    if (hungerEstimate(feeds) case final h?) {
      lines.add((
        Icons.local_drink_outlined,
        l10n.hungerEstimate(formatDuration(l10n, h.usualGap), time(h.nextAround)),
        l10n.hungerDisclaimer,
        null,
      ));
    }

    if (usualDailySleep(sleeps, now) case final usual?) {
      lines.add((
        Icons.bedtime_outlined,
        l10n.sleepUsual(formatDuration(l10n, usual), formatDuration(l10n, sleepOnDay(sleeps, now, now))),
        null,
        null,
      ));
    }

    final wake = wakeWindow(sleeps, now);
    if (wake.awakeFor case final awake? when awake.inHours < 12) {
      lines.add((
        Icons.wb_sunny_outlined,
        l10n.awakeFor(formatDuration(l10n, awake)),
        wake.usualAwake == null ? null : l10n.usuallyAwake(formatDuration(l10n, wake.usualAwake!)),
        null,
      ));
    }

    final visits = planVisits(baby.birthDate, schedule, given);
    final overdue = visits.where((v) => v.status(now) == VisitStatus.overdue).toList();
    final next = visits.where((v) => v.status(now) != VisitStatus.done).firstOrNull;
    void openHealth() => context.go('/health');
    if (overdue.isNotEmpty) {
      lines.add((
        Icons.vaccines,
        l10n.vaccinesOverdueLine(overdue.map((v) => visitLabel(l10n, v)).join(', ')),
        null,
        openHealth,
      ));
    } else if (next != null && next.dueDate.difference(now).inDays <= 30) {
      lines.add((
        Icons.vaccines_outlined,
        l10n.nextVisit(visitLabel(l10n, next), date(next.dueDate)),
        null,
        openHealth,
      ));
    }

    final slots = [for (final m in medications) ...slotsOn(m, now, doses)];
    if (slots.isNotEmpty) {
      final recorded = slots.where((s) => s.record != null).length;
      lines.add((Icons.medication_outlined, l10n.medsTodayLine(recorded, slots.length), null, openHealth));
    }

    if (growth.where((g) => g.weightG != null).lastOrNull case final w?) {
      lines.add((
        Icons.monitor_weight_outlined,
        l10n.sumWeight('${(w.weightG! / 1000).toStringAsFixed(2)} kg', date(w.measuredOn)),
        null,
        () => context.go('/growth'),
      ));
    }

    if (lines.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(l10n.atAGlance, style: theme.textTheme.titleMedium),
            ),
            for (final (icon, text, detail, onTap) in lines)
              ListTile(
                dense: true,
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(text),
                subtitle: detail == null ? null : Text(detail),
                trailing: onTap == null ? null : const Icon(Icons.chevron_right),
                onTap: onTap,
              ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              dense: true,
              leading: Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
              title: Text(l10n.seeReports, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute<void>(builder: (_) => ReportsScreen(baby: baby))),
            ),
          ],
        ),
      ),
    );
  }
}

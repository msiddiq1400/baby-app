import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/baby_age.dart';
import '../../core/l10n_lookup.dart';
import '../../data/content.dart';
import '../../data/journal_repository.dart';
import '../../data/models.dart';
import '../../data/vaccine_repository.dart';
import '../../l10n/app_localizations.dart';
import '../growth/growth_sheet.dart';
import '../health/doctor_summary.dart';
import '../health/illness_sheets.dart';
import '../health/symptom_sheet.dart';
import '../health/vaccination_sheet.dart';
import '../health/vaccine_plan.dart';
import '../home/log_sheets.dart';
import '../home/timeline.dart';
import '../milk/milk_sheets.dart';
import '../reports/report_stats.dart';
import '../solids/food_sheets.dart';

/// Every day since birth, one page each: swipe (or use the arrows or the
/// calendar) to go back in time. Today is the first page.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key, required this.baby, this.initialDay});

  final Baby baby;
  final DateTime? initialDay;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final DateTime _today;
  late final int _pageCount;
  late final PageController _pages;
  late int _page;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    final birth = widget.baby.birthDate;
    final days = _daysBetween(DateTime(birth.year, birth.month, birth.day), _today);
    _pageCount = days < 0 ? 1 : days + 1;
    _page = widget.initialDay == null ? 0 : _pageFor(widget.initialDay!);
    _pages = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  // Calendar days, safe across daylight-saving changes.
  static int _daysBetween(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  DateTime _dayAt(int page) => DateTime(_today.year, _today.month, _today.day - page);
  int _pageFor(DateTime day) => _daysBetween(day, _today).clamp(0, _pageCount - 1);

  void _go(int page) =>
      _pages.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  Future<void> _pickDate() async {
    final birth = widget.baby.birthDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dayAt(_page),
      firstDate: _dayAt(_pageCount - 1).isAfter(birth) ? birth : _dayAt(_pageCount - 1),
      lastDate: _today,
    );
    if (picked != null) _pages.jumpToPage(_pageFor(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final day = _dayAt(_page);
    final label = switch (_page) {
      0 => l10n.tabToday,
      1 => l10n.yesterday,
      _ => DateFormat.EEEE(dateLocale(l10n)).format(day),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.journalTitle),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month_outlined), tooltip: l10n.pickDate, onPressed: _pickDate),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.olderDay,
                  onPressed: _page < _pageCount - 1 ? () => _go(_page + 1) : null,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Text(label, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            MaterialLocalizations.of(context).formatMediumDate(day),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.newerDay,
                  onPressed: _page > 0 ? () => _go(_page - 1) : null,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            // Page 0 is today; older days are to the left (to the right in
            // Urdu), like turning back the pages of a diary.
            child: PageView.builder(
              controller: _pages,
              reverse: true,
              itemCount: _pageCount,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (context, page) => JournalDayView(baby: widget.baby, day: _dayAt(page)),
            ),
          ),
        ],
      ),
    );
  }
}

/// One day: totals, the things with a date only (vaccines, measurements,
/// foods, milestones), then everything with a time, in order.
class JournalDayView extends ConsumerWidget {
  const JournalDayView({super.key, required this.baby, required this.day});

  final Baby baby;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final journal = ref.watch(journalDayProvider((babyId: baby.id, day: day)));
    return switch (journal) {
      AsyncData(:final value) => _DayContent(baby: baby, journal: value),
      AsyncError() => Center(child: Text(l10n.errorGeneric)),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Entry {
  const _Entry(this.time, this.icon, this.text, [this.onTap, this.color]);

  final DateTime? time;
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Color? color;
}

class _DayContent extends ConsumerWidget {
  const _DayContent({required this.baby, required this.journal});

  final Baby baby;
  final JournalDay journal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final realNow = DateTime.now();
    final d = journal.day;
    final isToday = d == DateTime(realNow.year, realNow.month, realNow.day);
    // For a past day, "now" is the end of that day (for sleeps still going).
    final now = isToday ? realNow : DateTime(d.year, d.month, d.day, 23, 59, 59);

    if (journal.isEmpty) {
      return Center(
        child: Padding(padding: const EdgeInsets.all(32), child: Text(l10n.nothingOnDay, textAlign: TextAlign.center)),
      );
    }

    final foods = ref.watch(foodGuideProvider).value;
    final milestones = ref.watch(milestoneGuideProvider).value;
    final schedule = ref.watch(vaccineScheduleProvider(baby.countryCode)).value ?? const <VaccineDose>[];
    final log = journal.log;

    final dated = <_Entry>[
      for (final v in journal.vaccinations)
        if (v.isOther)
          _Entry(
            null,
            Icons.vaccines_outlined,
            v.vaccineName ?? v.vaccineCode,
            () => showEditOtherVaccineSheet(context, baby, v),
          )
        else if (schedule.where((s) => s.code == v.vaccineCode).firstOrNull case final dose)
          _Entry(
            null,
            Icons.vaccines_outlined,
            dose == null ? v.vaccineCode : doseTitle(dose),
            dose == null ? null : () => showEditVaccinationSheet(context, baby, dose, v),
          ),
      for (final g in journal.growth)
        _Entry(
          null,
          Icons.monitor_weight_outlined,
          [
            if (g.weightG != null) '${l10n.metricWeight} ${(g.weightG! / 1000).toStringAsFixed(2)} kg',
            if (g.lengthMm != null) '${l10n.metricLength} ${(g.lengthMm! / 10).toStringAsFixed(1)} cm',
            if (g.headMm != null) '${l10n.metricHead} ${(g.headMm! / 10).toStringAsFixed(1)} cm',
          ].join(' · '),
          () => showGrowthSheet(context, baby, existing: g),
        ),
      for (final m in journal.milestones)
        _Entry(
          null,
          Icons.emoji_events_outlined,
          milestones?.ages.expand((a) => a.milestones).where((x) => x.id == m.milestoneId).firstOrNull?.text.of(l10n) ??
              l10n.tabMilestones,
        ),
      for (final t in journal.foodTries)
        if (foods?.food(t.foodId) case final food?)
          _Entry(
            null,
            Icons.restaurant_outlined,
            [
              food.name.of(l10n),
              if (t.opinion case final o?)
                switch (o) {
                  'liked' => l10n.opinionLiked,
                  'disliked' => l10n.opinionDisliked,
                  _ => l10n.opinionNeutral,
                },
              if (t.reaction == 'mild') l10n.reactionMild,
              if (t.reaction == 'severe') l10n.reactionSevere,
            ].join(' · '),
            () => showTrySheet(context, baby, food, existing: t),
            t.reaction == 'none' ? null : theme.colorScheme.error,
          ),
    ];

    final timed = <_Entry>[
      for (final f in log.feeds)
        _Entry(f.startedAt, Icons.local_drink_outlined, feedEntryText(l10n, f, now), () => showFeedSheet(context, baby, existing: f)),
      for (final x in log.diapers)
        _Entry(x.occurredAt, Icons.baby_changing_station_outlined, diaperEntryText(l10n, x),
            () => showDiaperSheet(context, baby, existing: x)),
      for (final s in log.sleeps)
        _Entry(s.startedAt, Icons.bedtime_outlined, sleepEntryText(l10n, s), () => showSleepSheet(context, baby, s)),
      for (final p in journal.pumping)
        _Entry(
          p.startedAt,
          Icons.water_drop_outlined,
          [
            l10n.pumpingEntry,
            if (p.side != null) sideName(l10n, p.side!),
            if (p.amountMl != null) '${p.amountMl} ml',
          ].join(' · '),
          () => showPumpingSheet(context, baby, existing: p),
        ),
      for (final (:dose, :medicine) in journal.doses)
        _Entry(
          dose.givenAt,
          Icons.medication_outlined,
          '$medicine · ${dose.skipped ? l10n.doseSkipped : l10n.doseGiven}',
        ),
      for (final s in journal.symptoms)
        _Entry(
          s.occurredAt,
          Icons.thermostat_outlined,
          [
            symptomName(l10n, s.symptom),
            if (s.temperatureC != null) displayTemperature(s.temperatureC!),
            if (s.severity != null) severityName(l10n, s.severity!),
          ].join(' · '),
          () => showSymptomSheet(context, baby, existing: s),
        ),
      for (final v in journal.visits)
        _Entry(
          v.visitedAt,
          Icons.local_hospital_outlined,
          [l10n.doctorVisit, if (v.doctor != null) v.doctor!, if (v.diagnosis != null) v.diagnosis!].join(' · '),
          () => showDoctorVisitSheet(context, baby, existing: v),
        ),
    ]..sort((a, b) => a.time!.compareTo(b.time!));

    final stats = dailyStats(feeds: log.feeds, diapers: log.diapers, sleeps: log.sleeps, days: 1, now: now).single;
    final totals = [
      if (stats.feeds > 0) (Icons.local_drink_outlined, '${stats.feeds} ${l10n.feeds}'),
      if (stats.bottleMl > 0) (Icons.local_drink, '${stats.bottleMl} ml'),
      if (stats.nursingSeconds > 0)
        (Icons.timer_outlined, formatDuration(l10n, Duration(seconds: stats.nursingSeconds))),
      if (stats.diapers > 0) (Icons.baby_changing_station_outlined, l10n.diaperCounts(stats.wet, stats.dirty)),
      if (stats.sleep > Duration.zero) (Icons.bedtime_outlined, formatDuration(l10n, stats.sleep)),
    ];

    Widget tile(_Entry e) => ListTile(
          dense: true,
          leading: Icon(e.icon, color: e.color ?? theme.colorScheme.primary),
          title: Text(e.text, style: e.color == null ? null : TextStyle(color: e.color)),
          trailing: e.time == null
              ? null
              : Text(
                  // A sleep that began the evening before shows that day's date.
                  e.time!.isBefore(d)
                      ? '${MaterialLocalizations.of(context).formatShortMonthDay(e.time!)} '
                          '${TimeOfDay.fromDateTime(e.time!).format(context)}'
                      : TimeOfDay.fromDateTime(e.time!).format(context),
                ),
          onTap: e.onTap,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (totals.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (icon, text) in totals) Chip(avatar: Icon(icon, size: 18), label: Text(text)),
            ],
          ),
        if (dated.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.onThisDay, style: theme.textTheme.titleMedium),
          Card(
            child: Column(children: [for (final e in dated) tile(e)]),
          ),
        ],
        if (timed.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (final e in timed) tile(e),
        ],
      ],
    );
  }
}

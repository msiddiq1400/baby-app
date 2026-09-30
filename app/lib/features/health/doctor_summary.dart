import 'package:intl/intl.dart';

import '../../core/baby_age.dart';
import '../../core/l10n_lookup.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

String symptomName(AppLocalizations l10n, String code) => switch (code) {
      'fever' => l10n.symptomFever,
      'cough' => l10n.symptomCough,
      'runny_nose' => l10n.symptomRunnyNose,
      'vomiting' => l10n.symptomVomiting,
      'diarrhea' => l10n.symptomDiarrhea,
      'constipation' => l10n.symptomConstipation,
      'rash' => l10n.symptomRash,
      'teething' => l10n.symptomTeething,
      'feeding_refusal' => l10n.symptomFeedingRefusal,
      'crying' => l10n.symptomCrying,
      'congestion' => l10n.symptomCongestion,
      _ => l10n.symptomOther,
    };

String severityName(AppLocalizations l10n, int severity) => switch (severity) {
      1 => l10n.severityMild,
      2 => l10n.severityModerate,
      _ => l10n.severitySevere,
    };

/// "38.4°C (101.1°F)": both, since home thermometers in Pakistan often show °F.
String formatTemperature(double celsius) =>
    '${celsius.toStringAsFixed(1)}°C (${(celsius * 9 / 5 + 32).toStringAsFixed(1)}°F)';

/// [formatTemperature] for the screen: kept left-to-right inside Urdu text
/// (Unicode isolate marks U+2066 ... U+2069), where it would otherwise be
/// jumbled. The doctor summary text uses the plain version.
String displayTemperature(double celsius) =>
    '${String.fromCharCode(0x2066)}${formatTemperature(celsius)}${String.fromCharCode(0x2069)}';

/// One symptom across the period: when first and last noted, how often,
/// and the highest temperature if any was recorded.
class SymptomSpan {
  SymptomSpan(this.symptom, this.first) : last = first;

  final String symptom;
  final DateTime first;
  DateTime last;
  int count = 0;
  double? maxTemperature;
  DateTime? maxTemperatureAt;
}

/// Spans in the order symptoms first appeared.
List<SymptomSpan> symptomSpans(List<SymptomLog> logs) {
  final spans = <String, SymptomSpan>{};
  for (final log in [...logs]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt))) {
    final span = spans.putIfAbsent(log.symptom, () => SymptomSpan(log.symptom, log.occurredAt))
      ..last = log.occurredAt
      ..count += 1;
    final t = log.temperatureC;
    if (t != null && (span.maxTemperature == null || t > span.maxTemperature!)) {
      span.maxTemperature = t;
      span.maxTemperatureAt = log.occurredAt;
    }
  }
  return spans.values.toList();
}

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// Count per calendar day from [from] through [now]'s day, in order.
List<(DateTime, int)> countPerDay(Iterable<DateTime> times, DateTime from, DateTime now) {
  final counts = <DateTime, int>{};
  for (var d = _day(from); !d.isAfter(_day(now)); d = DateTime(d.year, d.month, d.day + 1)) {
    counts[d] = 0;
  }
  for (final t in times) {
    final d = _day(t);
    if (counts.containsKey(d)) counts[d] = counts[d]! + 1;
  }
  return [for (final e in counts.entries) (e.key, e.value)];
}

/// Average per day over the whole days [from, to); null when nothing was
/// logged then (e.g. the app wasn't used yet), so no misleading "usually 0".
double? averagePerDay(Iterable<DateTime> times, DateTime from, DateTime to) {
  final inRange = times.where((t) => !t.isBefore(from) && t.isBefore(to)).length;
  final days = _day(to).difference(_day(from)).inDays;
  return inRange == 0 || days <= 0 ? null : inRange / days;
}

class DoctorSummaryInput {
  const DoctorSummaryInput({
    required this.baby,
    required this.now,
    required this.from,
    required this.symptoms,
    required this.feeds,
    required this.diapers,
    required this.medications,
    required this.doses,
    this.latestWeight,
  });

  final Baby baby;
  final DateTime now;

  /// Start of the period (midnight). Feeds and diapers should also cover the
  /// 7 days before it, used as the "usually" comparison.
  final DateTime from;
  final List<SymptomLog> symptoms;
  final List<Feed> feeds;
  final List<Diaper> diapers;
  final List<Medication> medications;
  final List<MedicationDose> doses;
  final GrowthMeasurement? latestWeight;
}

/// Plain text a parent can show or send to the pediatrician.
String buildDoctorSummary(DoctorSummaryInput input, AppLocalizations l10n) {
  final locale = dateLocale(l10n);
  final dayFormat = DateFormat('d MMM', locale);
  final whenFormat = DateFormat('EEE d MMM, h:mm a', locale);
  final from = input.from;
  final now = input.now;
  final baselineFrom = DateTime(from.year, from.month, from.day - 7);
  final lines = <String>[];

  lines
    ..add(l10n.sumTitle(input.baby.name))
    ..add(l10n.sumAge(formatBabyAge(l10n, input.baby.birthDate, now)))
    ..add(l10n.sumPeriod(dayFormat.format(from), dayFormat.format(now)));
  if (input.latestWeight case final w? when w.weightG != null) {
    lines.add(l10n.sumWeight('${(w.weightG! / 1000).toStringAsFixed(2)} kg', dayFormat.format(w.measuredOn)));
  }

  final periodSymptoms = input.symptoms.where((s) => !s.occurredAt.isBefore(from)).toList();
  final spans = symptomSpans(periodSymptoms);
  if (spans.isNotEmpty) {
    lines
      ..add('')
      ..add(l10n.sumSymptoms);
    for (final span in spans) {
      var line = '• ${l10n.sumSymptomLine(
        symptomName(l10n, span.symptom),
        whenFormat.format(span.first),
        whenFormat.format(span.last),
        span.count,
      )}';
      if (span.maxTemperature case final t?) {
        line += '; ${l10n.sumHighestTemp(formatTemperature(t), whenFormat.format(span.maxTemperatureAt!))}';
      }
      lines.add(line);
    }
  }

  // Per-day counts, today marked as partial, compared with the week before.
  String perDayLine(Iterable<DateTime> times, String Function(String) label) {
    final days = countPerDay(times, from, now);
    final parts = [
      for (final (day, count) in days)
        _day(day) == _day(now) ? l10n.sumTodaySoFar(count) : '${dayFormat.format(day)} $count',
    ];
    final usual = averagePerDay(times, baselineFrom, from);
    final usualText = usual == null ? '' : ' (${l10n.sumUsually(usual.round().toString())})';
    return label(parts.join(' · ')) + usualText;
  }

  final feedTimes = input.feeds.map((f) => f.startedAt);
  final wetTimes = input.diapers.where((d) => d.isWet).map((d) => d.occurredAt);
  final dirtyTimes = input.diapers.where((d) => d.isDirty).map((d) => d.occurredAt);
  if (input.feeds.isNotEmpty || input.diapers.isNotEmpty) {
    lines
      ..add('')
      ..add(perDayLine(feedTimes, l10n.sumFeedsPerDay))
      ..add(perDayLine(wetTimes, l10n.sumWetPerDay))
      ..add(perDayLine(dirtyTimes, l10n.sumDirtyPerDay));
  }

  final periodDoses = input.doses.where((d) => !d.skipped && !d.givenAt.isBefore(from)).toList();
  final medsGiven = [
    for (final m in input.medications)
      if (periodDoses.any((d) => d.medicationId == m.id)) m,
  ];
  if (medsGiven.isNotEmpty) {
    lines
      ..add('')
      ..add(l10n.sumMedicines);
    for (final m in medsGiven) {
      final given = periodDoses.where((d) => d.medicationId == m.id).toList()
        ..sort((a, b) => a.givenAt.compareTo(b.givenAt));
      lines.add('• ${l10n.sumMedicineLine(m.name, m.prescribedDose, given.length, whenFormat.format(given.last.givenAt))}');
    }
  }

  if (periodSymptoms.isNotEmpty) {
    lines
      ..add('')
      ..add(l10n.sumEntries);
    for (final s in [...periodSymptoms]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt))) {
      final details = [
        symptomName(l10n, s.symptom),
        if (s.temperatureC case final t?) formatTemperature(t),
        if (s.severity case final sev?) severityName(l10n, sev),
      ].join(', ');
      final notes = s.notes == null ? '' : ': "${s.notes}"';
      lines.add('• ${whenFormat.format(s.occurredAt)} · $details$notes');
    }
  }

  lines
    ..add('')
    ..add(l10n.sumFooter);
  return lines.join('\n');
}

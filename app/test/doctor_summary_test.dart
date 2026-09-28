import 'package:baby_app/data/models.dart';
import 'package:baby_app/features/health/doctor_summary.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

SymptomLog log(String symptom, DateTime at, {double? temp, int? severity, String? notes}) =>
    SymptomLog(id: '$symptom$at', symptom: symptom, occurredAt: at, temperatureC: temp, severity: severity, notes: notes);

Feed feed(DateTime at) => Feed(id: '$at', type: FeedType.breast, startedAt: at);
Diaper diaper(DateTime at, {bool wet = true, bool dirty = false}) =>
    Diaper(id: '$at', occurredAt: at, isWet: wet, isDirty: dirty);

/// [perDay] events on each of [days] days starting at [start], at 6:00, 7:00...
List<DateTime> events(DateTime start, int days, int perDay) => [
      for (var d = 0; d < days; d++)
        for (var i = 0; i < perDay; i++) DateTime(start.year, start.month, start.day + d, 6 + i),
    ];

void main() {
  setUpAll(initializeDateFormatting);
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('temperature shows °C and °F', () {
    expect(formatTemperature(38.4), '38.4°C (101.1°F)');
  });

  test('symptom spans: first, last, count and highest temperature', () {
    final spans = symptomSpans([
      log('fever', DateTime(2026, 9, 27, 2), temp: 38.4),
      log('fever', DateTime(2026, 9, 26, 20), temp: 38.1),
      log('cough', DateTime(2026, 9, 27, 9)),
      log('fever', DateTime(2026, 9, 28, 8), temp: 37.6),
    ]);
    expect(spans.map((s) => s.symptom), ['fever', 'cough']);
    final fever = spans.first;
    expect(fever.first, DateTime(2026, 9, 26, 20));
    expect(fever.last, DateTime(2026, 9, 28, 8));
    expect(fever.count, 3);
    expect(fever.maxTemperature, 38.4);
    expect(fever.maxTemperatureAt, DateTime(2026, 9, 27, 2));
  });

  test('count per day includes empty days; average skips periods with no data', () {
    final counts = countPerDay(
      [DateTime(2026, 9, 26, 8), DateTime(2026, 9, 26, 12), DateTime(2026, 9, 28, 9)],
      DateTime(2026, 9, 26),
      DateTime(2026, 9, 28, 15),
    );
    expect(counts.map((c) => c.$2), [2, 0, 1]);
    expect(averagePerDay(events(DateTime(2026, 9, 19), 7, 7), DateTime(2026, 9, 19), DateTime(2026, 9, 26)), 7);
    expect(averagePerDay([], DateTime(2026, 9, 19), DateTime(2026, 9, 26)), isNull);
  });

  test('summary reads like the plan example', () {
    final baby = Baby(id: 'b', familyId: 'f', name: 'Aisha', birthDate: DateTime(2026, 4, 8), sex: 'female');
    final from = DateTime(2026, 9, 26);
    final now = DateTime(2026, 9, 28, 15);
    final text = buildDoctorSummary(
      DoctorSummaryInput(
        baby: baby,
        now: now,
        from: from,
        symptoms: [
          log('fever', DateTime(2026, 9, 26, 20), temp: 38.1),
          log('fever', DateTime(2026, 9, 27, 2), temp: 38.4, severity: 2, notes: 'fussy'),
        ],
        // Usually 7 feeds and 6 wet diapers; during the illness 5 and 4.
        feeds: [
          for (final t in events(DateTime(2026, 9, 19), 7, 7)) feed(t),
          for (final t in events(from, 2, 5)) feed(t),
          for (final t in events(DateTime(2026, 9, 28), 1, 2)) feed(t),
        ],
        diapers: [
          for (final t in events(DateTime(2026, 9, 19), 7, 6)) diaper(t),
          for (final t in events(from, 2, 4)) diaper(t),
        ],
        medications: [
          Medication(
            id: 'm',
            name: 'Paracetamol',
            prescribedDose: '2.5 ml',
            doseTimes: const [],
            asNeeded: true,
            startDate: from,
          ),
        ],
        doses: [
          MedicationDose(id: 'd1', medicationId: 'm', givenAt: DateTime(2026, 9, 27, 3), skipped: false),
          MedicationDose(id: 'd2', medicationId: 'm', givenAt: DateTime(2026, 9, 27, 9), skipped: true),
        ],
        latestWeight: GrowthMeasurement(id: 'g', measuredOn: DateTime(2026, 9, 20), weightG: 7250),
      ),
      l10n,
    );

    expect(text, contains('Health summary: Aisha'));
    expect(text, contains('Age: 5 months, 20 days'));
    expect(text, contains('Latest weight: 7.25 kg (20 Sep)'));
    expect(text, contains('Fever: from Sat 26 Sep, 8:00 PM to Sun 27 Sep, 2:00 AM (2 entries); '
        'highest 38.4°C (101.1°F) on Sun 27 Sep, 2:00 AM'));
    expect(text, contains('Feeds per day: 26 Sep 5 · 27 Sep 5 · today so far 2 (usually about 7)'));
    expect(text, contains('Wet diapers per day: 26 Sep 4 · 27 Sep 4 · today so far 0 (usually about 6)'));
    expect(text, contains('Paracetamol (2.5 ml): 1 dose, last Sun 27 Sep, 3:00 AM'));
    expect(text, contains('Sun 27 Sep, 2:00 AM · Fever, 38.4°C (101.1°F), Moderate: "fussy"'));
  });
}

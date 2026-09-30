import 'package:baby_app/data/illness_repository.dart';
import 'package:baby_app/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 9, 26, 23, 30);

  test('day 1 is the day it started, counted in calendar days', () {
    final illness = Illness(id: 'i', startedAt: start);
    expect(illness.dayNumber(start), 1);
    // Half an hour later it's the next calendar day: day 2.
    expect(illness.dayNumber(DateTime(2026, 9, 27, 0, 5)), 2);
    expect(illness.dayNumber(DateTime(2026, 9, 30, 9)), 5);
    expect(illness.ongoing, isTrue);
    expect(illness.days(DateTime(2026, 9, 30, 9)), 5);
  });

  test('a recovered illness lasted until the day it ended', () {
    final illness = Illness(id: 'i', startedAt: start, recoveredAt: DateTime(2026, 9, 29, 10));
    expect(illness.ongoing, isFalse);
    expect(illness.days(DateTime(2026, 12, 1)), 4);
  });

  test('episode summary: symptoms by frequency, last and highest temperature, doses today', () {
    SymptomLog s(String code, int day, int hour, [double? temp]) =>
        SymptomLog(id: '$code$day$hour', symptom: code, occurredAt: DateTime(2026, 9, day, hour), temperatureC: temp);
    final episode = IllnessEpisode(
      illness: Illness(id: 'i', startedAt: start),
      symptoms: [
        s('fever', 27, 8, 38.4),
        s('cough', 27, 9),
        s('fever', 28, 8, 39.1),
        s('fever', 29, 20, 37.9),
      ],
      doses: [
        (
          dose: MedicationDose(id: 'a', medicationId: 'm', givenAt: DateTime(2026, 9, 29, 8), skipped: false),
          medicine: 'Paracetamol',
        ),
        (
          dose: MedicationDose(id: 'b', medicationId: 'm', givenAt: DateTime(2026, 9, 29, 14), skipped: true),
          medicine: 'Paracetamol',
        ),
      ],
    );
    expect(episode.symptomCodes, ['fever', 'cough']);
    expect(episode.lastTemperature!.temperatureC, 37.9);
    expect(episode.highestTemperature!.temperatureC, 39.1);
    // A skipped dose doesn't count.
    expect(episode.dosesOn(DateTime(2026, 9, 29, 23)), 1);
  });
}

import 'package:baby_app/core/optional_vaccines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 27);
  List<OptionalVaccine> opt(String c, DateTime birth, {DateTime? on, Set<String> given = const {}}) =>
      optionalVaccines(c, birth, on ?? today, given);
  OptionalVaccine? rsv(List<OptionalVaccine> l) => l.where((v) => v.kind == OptionalKind.rsv).firstOrNull;
  OptionalVaccine? flu(List<OptionalVaccine> l) => l.where((v) => v.kind == OptionalKind.flu).firstOrNull;

  test('Pakistan: nothing optional (not offered to all babies)', () {
    expect(opt('PK', DateTime(2026, 9, 1)), isEmpty);
  });

  group('RSV', () {
    test('born in the season: due at birth, shown until the season ends', () {
      final v = rsv(opt('US', DateTime(2026, 10, 10)))!;
      expect(v.dueDate, DateTime(2026, 10, 10));
      expect(v.showUntil, DateTime(2027, 3, 31));
    });

    test('born before the season and under 8 months at its start: catch-up on 1 Oct', () {
      final v = rsv(opt('US', DateTime(2026, 5, 1), on: DateTime(2026, 8, 1)))!;
      expect(v.dueDate, DateTime(2026, 10, 1));
    });

    test('too old at the season start: none', () {
      expect(rsv(opt('US', DateTime(2026, 1, 15).subtract(const Duration(days: 300)), on: DateTime(2026, 8, 1))), isNull);
    });

    test('season over and not given: missed, so not shown; given: always shown', () {
      expect(rsv(opt('US', DateTime(2026, 1, 15))), isNull);
      expect(rsv(opt('US', DateTime(2026, 1, 15), given: {'RSV'})), isNotNull);
    });

    test('UAE: at birth only, no catch-up', () {
      expect(rsv(opt('AE', DateTime(2026, 9, 5)))!.dueDate, DateTime(2026, 9, 5));
      expect(rsv(opt('AE', DateTime(2026, 6, 1), on: DateTime(2026, 7, 1))), isNull);
    });

    test('Netherlands: catch-up on 15 Sep; Ireland: born 29 Feb counts as in season', () {
      expect(rsv(opt('NL', DateTime(2026, 5, 1), on: DateTime(2026, 6, 1)))!.dueDate, DateTime(2026, 9, 15));
      expect(rsv(opt('IE', DateTime(2028, 2, 29), on: DateTime(2028, 2, 29)))!.dueDate, DateTime(2028, 2, 29));
    });

    test('UK: mothers get the vaccine in pregnancy instead, so nothing for the baby', () {
      expect(rsv(opt('GB', DateTime(2026, 10, 10))), isNull);
    });
  });

  group('flu', () {
    test('over 6 months when the campaign starts: due then, first time = 2 doses', () {
      final v = flu(opt('US', DateTime(2026, 1, 1)))!;
      expect(v.code, 'FLU-2026');
      expect(v.dueDate, DateTime(2026, 9, 1));
      expect(v.firstFlu, isTrue);
      expect(fluSeasonLabel('US', 2026), '2026–27');
    });

    test('turns 6 months during the season: due on that day', () {
      expect(flu(opt('US', DateTime(2026, 6, 1)))!.dueDate, DateTime(2026, 12, 1));
    });

    test('a flu vaccine recorded before: not the first time', () {
      final v = flu(opt('US', DateTime(2024, 1, 1), given: {'FLU-2025'}))!;
      expect(v.code, 'FLU-2026');
      expect(v.firstFlu, isFalse);
    });

    test("this season's given: shown as done", () {
      final v = flu(opt('US', DateTime(2025, 1, 1), given: {'FLU-2026'}))!;
      expect(v.code, 'FLU-2026');
    });

    test('UK: from age 2, nasal spray, one dose', () {
      final v = flu(opt('GB', DateTime(2025, 1, 1)))!;
      expect(v.dueDate, DateTime(2027, 1, 1));
      expect(v.nasal, isTrue);
      expect(v.firstFlu, isFalse);
      expect(flu(opt('GB', DateTime(2026, 6, 1))), isNull);
    });

    test('Australia: southern season from April, label is one year', () {
      final v = flu(opt('AU', DateTime(2026, 3, 1)))!;
      expect(v.dueDate, DateTime(2027, 4, 1));
      expect(fluSeasonLabel('AU', 2027), '2027');
    });

    test('Bahrain: only up to 5 years', () {
      expect(flu(opt('BH', DateTime(2021, 1, 1))), isNull);
    });
  });
}

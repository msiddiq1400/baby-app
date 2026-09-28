import 'package:baby_app/core/numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plain and comma decimals', () {
    expect(parseLocalizedNumber('7.25'), 7.25);
    expect(parseLocalizedNumber(' 7,25 '), 7.25);
  });

  test('Urdu and Arabic-Indic digits', () {
    expect(parseLocalizedNumber('۷٫۲۵'), 7.25);
    expect(parseLocalizedNumber('١٢٠'), 120);
    expect(parseLocalizedInt('۱۶۰'), 160);
  });

  test('rejects non-numbers and fractions for ints', () {
    expect(parseLocalizedNumber('abc'), isNull);
    expect(parseLocalizedInt('12.5'), isNull);
  });
}

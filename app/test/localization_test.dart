import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

void main() {
  Future<String> shortDate(WidgetTester tester, Locale locale) async {
    late String text;
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: Builder(
          builder: (context) {
            text = MaterialLocalizations.of(context).formatShortMonthDay(DateTime(2026, 9, 16));
            return const SizedBox();
          },
        ),
      ),
    );
    return text;
  }

  testWidgets('Roman Urdu dates use Latin script, Urdu keeps Urdu script', (tester) async {
    expect(await shortDate(tester, const Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn')), 'Sep 16');
    expect(await shortDate(tester, const Locale('en')), 'Sep 16');
    expect(await shortDate(tester, const Locale('ur')), isNot(contains('Sep')));
  });
}

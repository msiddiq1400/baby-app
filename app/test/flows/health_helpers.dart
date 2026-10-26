// Helpers for the Growth and Health flow tests (growth_flow_test.dart,
// health_flow_test.dart): tab navigation, form fields, the delete dialog,
// the date picker, seeding rows, and the vaccine schedules from the real
// Supabase migrations.

import 'dart:io';

import 'package:baby_app/app/app.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:uuid/uuid.dart';

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ur = lookupAppLocalizations(const Locale('ur'));
const _uuid = Uuid();

/// Like [FlowEnv.pumpApp], with extra provider overrides on top.
Future<void> pumpAppWith(WidgetTester tester, FlowEnv env, List<Override> extra) async {
  tester.view.physicalSize = const Size(1080, 2316);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(overrides: [...env.overrides, ...extra], child: const BabyApp()));
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
  await settle(tester);
}

/// Opens a main tab from the bottom bar.
Future<void> openTab(WidgetTester tester, String label) =>
    tapAndSettle(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));

/// Opens an inner tab (e.g. Health > Medicines).
Future<void> openInnerTab(WidgetTester tester, String label) =>
    tapAndSettle(tester, find.descendant(of: find.byType(TabBar), matching: find.text(label)));

/// Types into the text field labelled [label] (TextField or TextFormField).
Future<void> typeInto(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextField, label);
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, text);
  await tester.pump();
}

/// The Save button of the open form sheet.
Future<void> tapSave(WidgetTester tester) => tapAndSettle(tester, find.widgetWithText(FilledButton, en.saveButton).last);

/// Taps the form's Delete button and confirms in the dialog.
Future<void> deleteAndConfirm(WidgetTester tester) async {
  await tapAndSettle(tester, find.widgetWithText(TextButton, en.deleteButton).last);
  await tapAndSettle(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text(en.deleteButton)));
}

/// In an open date picker, goes to [day]'s month and picks it, then OK.
Future<void> pickDate(WidgetTester tester, DateTime day, {DateTime? shown}) async {
  final from = shown ?? DateTime.now();
  final months = (from.year - day.year) * 12 + from.month - day.month;
  for (var i = 0; i < months; i++) {
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('${day.day}').last);
  await tester.pump();
  await tester.tap(find.text('OK'));
  await settle(tester);
}

/// "2026-10-26" (how dates are stored).
String isoDay(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

DateTime today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime daysAgo(int days) {
  final t = today();
  return DateTime(t.year, t.month, t.day - days);
}

/// UTC timestamp text like the app stores ("2026-10-26T09:00:00.000Z").
String utcText(DateTime t) => t.toUtc().toIso8601String();

/// Inserts a row for the test baby (family and baby ids filled in) and
/// returns its id.
Future<String> seedRow(WidgetTester tester, FlowEnv env, String table, Map<String, Object?> values) async {
  final row = {'id': _uuid.v4(), 'family_id': env.familyId, 'baby_id': env.babyId, ...values};
  await env.exec(
    tester,
    'INSERT INTO $table (${row.keys.join(', ')}) VALUES (${List.filled(row.length, '?').join(', ')})',
    row.values.toList(),
  );
  return row['id'] as String;
}

final _scheduleRow = RegExp(
  r"\('([A-Z]{2})',\s*'([^']+)',\s*'([^']*)',\s*(null|'[^']*'),\s*(\d+),\s*'(day|week|month)',\s*(\d+),",
);

/// Fills the phone's vaccine_schedule table from the real migrations, as
/// the first sync would.
Future<void> seedVaccineSchedules(FlowEnv env) async {
  final sql = [
    File('../supabase/migrations/20260928000002_vaccine_schedule.sql').readAsStringSync(),
    File('../supabase/migrations/20261001000001_countries.sql').readAsStringSync(),
  ].join('\n');
  final rows = _scheduleRow.allMatches(sql).toList();
  if (rows.length < 20) throw StateError('Vaccine schedule rows not found in the migrations (${rows.length})');
  await env.db.writeTransaction((tx) async {
    for (final m in rows) {
      final label = m[4] == 'null' ? null : m[4]!.substring(1, m[4]!.length - 1);
      await tx.execute(
        'INSERT INTO vaccine_schedule (id, country_code, code, name, dose_label, due_age_value, due_age_unit, sort_order, verified) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)',
        [_uuid.v4(), m[1], m[2], m[3], label, int.parse(m[5]!), m[6], int.parse(m[7]!)],
      );
    }
  });
}

/// Pumps until [finder] finds [count] widgets (default: at least one), for
/// screens that update from a database watch a little after the action.
/// Fails the test if it never happens.
Future<void> waitFor(WidgetTester tester, Finder finder, {int? count, int max = 60}) async {
  bool ok() {
    final n = finder.evaluate().length;
    return count == null ? n > 0 : n == count;
  }

  for (var i = 0; i < max && !ok(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, count == null ? findsWidgets : findsNWidgets(count));
}

/// Waits until [finder] finds nothing.
Future<void> waitForNone(WidgetTester tester, Finder finder) => waitFor(tester, finder, count: 0);

/// The vertical list on screen (not the sideways tab pager).
final _verticalScrollable = find.byWidgetPredicate(
  (w) => w is Scrollable && axisDirectionToAxis(w.axisDirection) == Axis.vertical,
);

/// Scrolls the list until [finder] is built and visible (lists only build
/// what's near the screen).
Future<void> scrollTo(WidgetTester tester, Finder finder, {double delta = 300}) async {
  await tester.scrollUntilVisible(finder, delta, scrollable: _verticalScrollable.first);
  await tester.pump();
}

/// Scrolls the list back to the top.
Future<void> scrollToTop(WidgetTester tester) async {
  await tester.drag(_verticalScrollable.first, const Offset(0, 5000));
  await settle(tester);
}

/// All the text on screen, joined (for "contains" checks across widgets).
String screenText(WidgetTester tester) => [
      for (final e in find.byType(Text).evaluate()) (e.widget as Text).data ?? (e.widget as Text).textSpan?.toPlainText() ?? '',
      for (final e in find.byType(SelectableText).evaluate())
        (e.widget as SelectableText).data ?? (e.widget as SelectableText).textSpan?.toPlainText() ?? '',
    ].join('\n');

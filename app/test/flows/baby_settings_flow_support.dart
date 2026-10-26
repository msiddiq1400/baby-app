// Helpers shared by the babies / settings / family / account / help flow
// tests (candidates for harness.dart):
// - fakes for the phone plugins these flows touch (notifications, dialer,
//   share sheet), so sign-out and tap-to-call work in tests;
// - pumpPalna: the whole app like env.pumpApp, plus a photo repository on the
//   fake Supabase (the app's provider reads Supabase.instance directly);
// - restart, Settings and form helpers.

import 'dart:convert';

import 'package:baby_app/app/app.dart';
import 'package:baby_app/core/countries.dart';
import 'package:baby_app/core/reminders.dart';
import 'package:baby_app/data/photo_repository.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ur = lookupAppLocalizations(const Locale('ur'));
final roman = lookupAppLocalizations(const Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'));

/// Calls the app made to the phone's dialer, share sheet and notifications.
class PluginCalls {
  final launched = <String>[];
  final shared = <String>[];
  final notifications = <String>[];
}

/// Installs fakes for the platform plugins; call in main() before the
/// tests (setUpAll). Reminders keep their first init for the whole file, so
/// this must run before any app is pumped.
PluginCalls fakePlugins() {
  final calls = PluginCalls();
  setUpAll(() async {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    // Notifications: the plugin isn't registered in tests; register the
    // Android one and answer its channel.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    messenger.setMockMethodCallHandler(const MethodChannel('dexterous.com/flutter/local_notifications'), (call) async {
      calls.notifications.add(call.method);
      return switch (call.method) {
        'initialize' || 'requestNotificationsPermission' => true,
        'pendingNotificationRequests' || 'getActiveNotifications' => <Object?>[],
        _ => null,
      };
    });
    messenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), (call) async {
      if (call.method == 'launch') calls.launched.add((call.arguments as Map)['url'] as String);
      return true;
    });
    messenger.setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/share'), (call) async {
      if (call.method == 'share') calls.shared.add((call.arguments as Map)['text'] as String);
      return 'dev.fluttercommunity.plus/share/success';
    });
    // Reminders sets itself up once per run and keeps that future. Finish it
    // here, on the real clock: started inside a test, it can be left
    // half-done when that test ends, and every later sign-out would wait on
    // it forever.
    await Reminders.cancelAll();
  });
  setUp(() {
    calls.launched.clear();
    calls.shared.clear();
    calls.notifications.clear();
  });
  return calls;
}

/// The whole app, like env.pumpApp, with the photo repository on the fake
/// Supabase (deleting a baby deletes its photos too).
Future<void> pumpPalna(WidgetTester tester, FlowEnv env) async {
  tester.view.physicalSize = const Size(1080, 2316);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        photoRepositoryProvider.overrideWith(
          (ref) => PhotoRepository(env.db, ref.watch(photoQueueProvider), ref.watch(photoFolderProvider), env.supabase),
        ),
      ],
      child: const BabyApp(),
    ),
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
  await settle(tester);
}

/// Closes the app and opens it again on the same phone database.
Future<void> restartPalna(WidgetTester tester, FlowEnv env) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester);
  await pumpPalna(tester, env);
}

/// Pumps (half a second of app time per round) until [done] is true, then
/// settles. For flows that wait on timers longer than settle() covers, e.g.
/// the server client's retries when offline, or signing out.
Future<void> waitUntil(WidgetTester tester, bool Function() done, {int max = 120}) async {
  for (var i = 0; i < max && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 500));
  }
  await settle(tester);
}

/// Marks every local change as uploaded (as if the phone had synced).
Future<void> markAllUploaded(WidgetTester tester, FlowEnv env) async {
  await tester.runAsync(() async {
    while (true) {
      final batch = await env.db.getCrudBatch(limit: 1000);
      if (batch == null) break;
      await batch.complete();
    }
  });
}

/// Opens Settings from the top bar of a main tab.
Future<void> openSettings(WidgetTester tester, [AppLocalizations? l10n]) =>
    tapAndSettle(tester, find.byTooltip((l10n ?? en).settingsTitle));

/// Scrolls a long screen until [finder] is visible, then taps it.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tapAndSettle(tester, finder);
}

/// Opens the birth-date picker and takes its OK (the picker starts on the
/// current date, or today); with [date], types that date first.
Future<void> pickBirthDate(WidgetTester tester, String fieldLabel, {DateTime? date}) async {
  await tapAndSettle(tester, find.widgetWithText(TextFormField, fieldLabel));
  final dialog = find.byType(DatePickerDialog);
  final material = MaterialLocalizations.of(tester.element(dialog));
  if (date != null) {
    await tapAndSettle(tester, find.byTooltip(material.inputDateModeButtonLabel));
    await tester.enterText(find.descendant(of: dialog, matching: find.byType(TextField)), material.formatCompactDate(date));
    await tester.pump();
  }
  await tapAndSettle(tester, find.text(material.okButtonLabel));
}

/// Opens the country picker and chooses [code] (searching if it isn't one of
/// the main ones at the top).
Future<void> pickCountry(WidgetTester tester, String fieldLabel, String code, {String language = 'en', String? script}) async {
  await tapAndSettle(tester, find.widgetWithText(TextFormField, fieldLabel));
  final name = countryName(code, language, scriptCode: script);
  if (!featuredCountries.contains(code)) {
    await tester.enterText(find.descendant(of: find.byType(BottomSheet), matching: find.byType(TextField)), name);
    await settle(tester);
  }
  // The tile, not the search box (which holds the same text).
  await tapAndSettle(tester, find.descendant(of: find.byType(BottomSheet), matching: find.widgetWithText(ListTile, name)));
}

/// Runs a read while the app keeps running. env.rows waits inside
/// runAsync, which can deadlock when the screen's own database watches need
/// the fake clock to hand their connections back (e.g. on Feeding); this
/// starts the query on the fake clock and pumps until it's done.
Future<List<Map<String, Object?>>> query(WidgetTester tester, FlowEnv env, String sql, [List<Object?> params = const []]) async {
  List<Map<String, Object?>>? result;
  Object? error;
  env.db.getAll(sql, params).then(
        (rows) => result = [for (final r in rows) Map<String, Object?>.of(r)],
        onError: (Object e) => error = e,
      );
  for (var i = 0; i < 400 && result == null && error == null; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 20));
  }
  if (error != null) throw error!;
  return result ?? (throw StateError('Query did not finish: $sql'));
}

/// The baby rows (oldest first).
Future<List<Map<String, Object?>>> babyRows(WidgetTester tester, FlowEnv env) => query(
      tester,
      env,
      'SELECT id, family_id, name, birth_date, sex, birth_weight_g, birth_length_mm, birth_head_mm, country_code, deleted_at '
      'FROM babies ORDER BY julianday(created_at), name',
    );

/// An on-phone setting's stored value (null if never set).
Future<Object?> settingValue(WidgetTester tester, FlowEnv env, String key) async {
  final rows = await query(tester, env, 'SELECT value FROM app_settings WHERE id = ?', [key]);
  return rows.isEmpty ? null : rows.single['value'];
}

/// Tables with local changes waiting to upload.
Future<Set<String>> pendingTables(WidgetTester tester, FlowEnv env) async {
  final rows = await query(tester, env, 'SELECT data FROM ps_crud');
  return {for (final r in rows) (jsonDecode(r['data']! as String) as Map)['type'] as String};
}

/// Fake server replies that carry their request. MockClient passes on the
/// response's `request`, and Supabase's database client reads it
/// (`response.request!`), so FakeServer.json alone fails for /rest calls.
http.Response reply(SentRequest r, Object? body, {int status = 200}) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
      request: http.Request(r.method, r.url),
    );

/// An empty success (what a void database function returns).
http.Response noContent(SentRequest r) => http.Response('', 204, request: http.Request(r.method, r.url));

String dateOnlyText(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

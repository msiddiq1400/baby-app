// Shared setup for the flow tests: the real app (router, screens, forms,
// repositories) on a real on-phone database, with Supabase faked by an HTTP
// stub so no network is used. Each test gets a fresh, empty database.
//
//   late FlowEnv env;
//   setUp(() async => env = await FlowEnv.open());
//   tearDown(() => env.close());
//
//   testWidgets('...', (tester) async {
//     await env.pumpApp(tester);
//     await tester.tap(find.text('Feed'));
//     await settle(tester);
//     ...
//     expect(await env.rows(tester, 'SELECT * FROM feeds'), hasLength(1));
//   });
//
// Database work is real I/O, so it runs inside tester.runAsync; widget
// tests use a fake clock otherwise. settle() alternates the two until the
// database's change notifications have reached the screen.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:baby_app/app/app.dart';
import 'package:baby_app/core/providers.dart';
import 'package:baby_app/core/reminders.dart';
import 'package:baby_app/data/baby_repository.dart';
import 'package:baby_app/data/local_db.dart';
import 'package:baby_app/data/local_schema.dart';
import 'package:baby_app/data/photo_repository.dart';
import 'package:baby_app/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meta/meta.dart' show isTest;
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_app.dart';

export '../test_app.dart' show loadAppFonts;

const testUserId = '00000000-0000-4000-8000-000000000001';
const testEmail = 'sana@example.com';

/// Call once per test file (fonts, date formats).
void setUpFlowTests() {
  setUpAll(() async {
    await initializeDateFormatting();
    await loadAppFonts();
    await _fakePlatformPlugins();
  });
  // A cached asset load from an earlier test belongs to that test's fake
  // clock and never completes in the next one.
  setUp(rootBundle.clear);
}

/// Answers the phone plugins the app calls (notifications, dialer, share
/// sheet), so flows don't fail on a missing plugin. A test that wants to
/// check a call sets its own handler on the same channel.
Future<void> _fakePlatformPlugins() async {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  AndroidFlutterLocalNotificationsPlugin.registerWith();
  messenger.setMockMethodCallHandler(const MethodChannel('dexterous.com/flutter/local_notifications'), (call) async {
    return switch (call.method) {
      'initialize' || 'requestNotificationsPermission' => true,
      'pendingNotificationRequests' || 'getActiveNotifications' => <Object?>[],
      _ => null,
    };
  });
  messenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), (_) async => true);
  // Android home-screen widget: accept its data.
  messenger.setMockMethodCallHandler(const MethodChannel('home_widget'), (_) async => true);
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/share'),
    (_) async => 'dev.fluttercommunity.plus/share/success',
  );
  // Reminders sets itself up once per run and keeps that future. Finish it
  // here, on the real clock: started inside a test, it can be left half-done
  // when that test ends, and every later sign-out would wait on it forever.
  await Reminders.cancelAll();
}

/// A request the app sent to the fake Supabase server.
class SentRequest {
  SentRequest(this.method, this.url, this.body, [this.headers = const {}]);

  final String method;
  final Uri url;
  final String body;
  final Map<String, String> headers;

  String get path => url.path;
  Object? get json => body.isEmpty ? null : jsonDecode(body);

  @override
  String toString() => '$method $url $body';
}

/// May return a Future, e.g. to keep the app waiting and check its busy state.
typedef FakeHandler = FutureOr<http.Response> Function(SentRequest request);

/// Stands in for Supabase (auth, database API, RPCs, storage). Unhandled
/// requests answer 501, so a test notices a call it didn't expect.
class FakeServer {
  final requests = <SentRequest>[];
  final _handlers = <(String, String, FakeHandler)>[];

  /// Answers [method] requests whose path starts with [pathPrefix] (the
  /// newest matching handler wins). E.g. on('POST', '/rest/v1/rpc/create_family_invite', ...).
  void on(String method, String pathPrefix, FakeHandler handler) => _handlers.insert(0, (method, pathPrefix, handler));

  /// JSON response helper.
  static http.Response json(Object? body, {int status = 200}) =>
      http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

  /// Requests to paths starting with [pathPrefix].
  List<SentRequest> sent(String pathPrefix, {String? method}) => [
        for (final r in requests)
          if (r.path.startsWith(pathPrefix) && (method == null || r.method == method)) r,
      ];

  late final http.Client client = MockClient((request) async {
    final sent = SentRequest(request.method, request.url, request.body, request.headers);
    requests.add(sent);
    for (final (method, prefix, handler) in _handlers) {
      if (method == request.method && request.url.path.startsWith(prefix)) {
        return _withRequest(await handler(sent), request);
      }
    }
    return _withRequest(json({'message': 'No fake for ${request.method} ${request.url.path}'}, status: 501), request);
  });

  // Supabase's database client reads response.request, so every reply
  // carries the request it answers.
  static http.Response _withRequest(http.Response r, http.BaseRequest request) => r.request != null
      ? r
      : http.Response.bytes(r.bodyBytes, r.statusCode, headers: r.headers, reasonPhrase: r.reasonPhrase, request: request);
}

Map<String, Object?> fakeUserJson({String id = testUserId, String email = testEmail}) => {
      'id': id,
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': email,
      'app_metadata': {'provider': 'email', 'providers': ['email']},
      'user_metadata': <String, Object?>{},
      'identities': <Object?>[],
      'created_at': '2026-09-01T00:00:00Z',
    };

/// A session that doesn't expire during the test.
Map<String, Object?> fakeSessionJson({String id = testUserId, String email = testEmail}) {
  final expires = DateTime.now().add(const Duration(days: 1));
  return {
    'access_token': 'test-access-token',
    'refresh_token': 'test-refresh-token',
    'token_type': 'bearer',
    'expires_in': 86400,
    'expires_at': expires.millisecondsSinceEpoch ~/ 1000,
    'user': fakeUserJson(id: id, email: email),
  };
}

// The app waits for the first download; tests start already synced.
// ignore: invalid_use_of_internal_member
final _synced = SyncStatus(
  connected: true,
  connecting: false,
  lastSyncedAt: DateTime(2026, 10, 1),
  downloadProgress: null,
  downloading: false,
  uploading: false,
  downloadError: null,
  uploadError: null,
  priorityStatusEntries: const [],
  streamSubscriptions: null,
  lastAppliedCheckpoint: null,
);

class FlowEnv {
  FlowEnv._(this.dir, this.db, this.server, this.supabase);

  final Directory dir;
  final PowerSyncDatabase db;
  final FakeServer server;
  final SupabaseClient supabase;

  /// Set by [seedBaby]: the baby and family every test starts with.
  String? babyId;
  String? familyId;

  /// A fresh database and fake server. [signedIn] restores a session for
  /// [testUserId]; [baby] adds one baby (Aisha, 5 months, Pakistan) so the
  /// app opens on Today.
  static Future<FlowEnv> open({bool signedIn = true, bool baby = true}) async {
    final dir = await Directory.systemTemp.createTemp('palna_flow');
    final db = PowerSyncDatabase(schema: localSchema, path: '${dir.path}/test.db');
    await db.initialize();
    final server = FakeServer();
    final supabase = SupabaseClient(
      'http://supabase.test',
      'test-anon-key',
      httpClient: server.client,
      authOptions: const AuthClientOptions(autoRefreshToken: false, authFlowType: AuthFlowType.implicit),
    );
    final env = FlowEnv._(dir, db, server, supabase);
    if (signedIn) await supabase.auth.recoverSession(jsonEncode(fakeSessionJson()));
    if (baby) await env.seedBaby();
    return env;
  }

  /// Adds a baby the way the app does (a new family on first use).
  Future<String> seedBaby({
    String name = 'Aisha',
    DateTime? birthDate,
    String country = 'PK',
    String sex = 'female',
    int? birthWeightG = 3200,
  }) async {
    final now = DateTime.now();
    final id = await BabyRepository(db).addBaby(
      name: name,
      createdBy: testUserId,
      birthDate: birthDate ?? DateTime(now.year, now.month - 5, now.day - 20),
      countryCode: country,
      sex: sex,
      birthWeightG: birthWeightG,
    );
    babyId ??= id;
    familyId ??= (await db.get('SELECT family_id FROM babies WHERE id = ?', [id]))['family_id'] as String;
    return id;
  }

  /// Gives the family Palna Pro, as the server would after a purchase
  /// (families.pro_until; todos.txt 38b).
  Future<void> makePro() => db.execute("UPDATE families SET pro_until = 'infinity' WHERE id = ?", [familyId]);

  /// Saves an on-phone setting (language, chosen baby, theme) before the app starts.
  Future<void> setting(String key, String? value) => SettingsRepository(db).set(key, value);

  List<Override> get overrides => [
        powerSyncProvider.overrideWithValue(db),
        supabaseProvider.overrideWithValue(supabase),
        syncStatusProvider.overrideWith((ref) => Stream.value(_synced)),
        photoFolderProvider.overrideWithValue('${dir.path}/photos'),
        photoQueueProvider.overrideWith((ref) => createPhotoQueue(db, supabase, '${dir.path}/photos')),
      ];

  /// Pumps the whole app (router, tabs, Feed / Diaper / Sleep bar) and
  /// waits until the first screen has loaded.
  /// [extra] replaces more providers, e.g. a fake push device.
  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(1080, 2316),
    double ratio = 2.75,
    List<Override> extra = const [],
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = ratio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(overrides: [...overrides, ...extra], child: const BabyApp()));
    _unmountAtEnd(tester);
    await settle(tester);
  }

  /// Pumps one screen (not the whole app) with the real database behind it.
  Future<void> pumpScreen(WidgetTester tester, Widget screen, {Locale locale = const Locale('en')}) async {
    tester.view.physicalSize = const Size(1080, 2316);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: testApp(locale: locale, home: screen)));
    _unmountAtEnd(tester);
    await settle(tester);
  }

  /// Removes the app at the end of the test and lets its database watches
  /// finish cancelling, so the database can close.
  void _unmountAtEnd(WidgetTester tester) => addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        for (var i = 0; i < 5; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump(const Duration(milliseconds: 100));
        }
      });

  /// Runs a query while the app keeps running. Started on the fake clock and
  /// pumped until done: waiting inside runAsync instead can deadlock when
  /// the screen's own database watches need the fake clock to hand their
  /// connections back.
  Future<List<Map<String, Object?>>> rows(WidgetTester tester, String sql, [List<Object?> params = const []]) async {
    final result = await _whilePumping(tester, () => db.getAll(sql, params), sql);
    return [for (final r in result) Map<String, Object?>.of(r)];
  }

  /// Runs a write (real I/O, so inside runAsync) and lets the app see it.
  Future<void> exec(WidgetTester tester, String sql, [List<Object?> params = const []]) async {
    await tester.runAsync(() => db.execute(sql, params));
    await settle(tester);
  }

  /// Local changes waiting to upload (what PowerSync would send).
  Future<List<CrudEntry>> pendingUploads(WidgetTester tester) async {
    final batch = await _whilePumping(tester, () => db.getCrudBatch(limit: 1000), 'pending uploads');
    return batch?.crud ?? const [];
  }

  Future<void> close() async {
    // A watch cancelled on the fake clock can leave the close waiting; don't
    // hang the whole run on it.
    await db.close().timeout(const Duration(seconds: 5), onTimeout: () {});
    supabase.dispose();
    try {
      await dir.delete(recursive: true);
    } on FileSystemException {
      // Windows can hold the file a moment longer; it's a temp folder.
    }
  }
}

/// Runs [work] (started on the fake clock) and pumps until it finishes.
Future<T> _whilePumping<T>(WidgetTester tester, Future<T> Function() work, String what) async {
  var done = false;
  late T result;
  Object? error;
  StackTrace? stack;
  work().then((r) {
    result = r;
    done = true;
  }, onError: (Object e, StackTrace s) {
    error = e;
    stack = s;
    done = true;
  });
  for (var i = 0; i < 500 && !done; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 20));
  }
  if (error != null) Error.throwWithStackTrace(error!, stack!);
  if (!done) throw StateError('Database work did not finish: $what');
  return result;
}

/// A widget test for a flow. Same as testWidgets, but at the end it removes
/// the app and lets its database watches finish cancelling inside the test,
/// so no timer is left pending (flutter_test fails a test for that).
@isTest
void flowWidgets(String description, WidgetTesterCallback body, {bool? skip}) => testWidgets(
      description,
      (tester) async {
        await body(tester);
        await tester.pumpWidget(const SizedBox());
        for (var i = 0; i < 6; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
          await tester.pump(const Duration(milliseconds: 100));
        }
      },
      skip: skip,
    );

/// Pumps (half a second of app time per round) until [done] is true, then
/// settles: for flows that wait on longer timers (retries when offline).
Future<void> pumpUntil(WidgetTester tester, bool Function() done, {int max = 120}) async {
  for (var i = 0; i < max && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 500));
  }
  await settle(tester);
}

/// Lets database work and change notifications reach the screen: real
/// time for the I/O, fake time for the widget timers and animations. Keeps
/// going until there's no loading spinner and the screen has stopped
/// changing for a few rounds (at least [rounds] rounds, at most [max]).
Future<void> settle(WidgetTester tester, {int rounds = 4, int max = 80}) async {
  String? last;
  var same = 0;
  for (var i = 0; i < max; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await tester.pump(const Duration(milliseconds: 100));
    final now = _screenSignature();
    same = now == last ? same + 1 : 0;
    last = now;
    // No animation running (a sheet closing, a page opening), nothing
    // loading, and the same screen three rounds in a row.
    final animating = tester.binding.transientCallbackCount > 0;
    if (i >= rounds - 1 && same >= 3 && !animating && find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
}

/// What the screen shows: every text, and how many routes and dialogs.
String _screenSignature() {
  final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').join('|');
  final editable = find.byType(EditableText).evaluate().map((e) => (e.widget as EditableText).controller.text).join('|');
  final routes = find.byType(ModalBarrier).evaluate().length;
  return '$routes#$texts#$editable';
}

/// Taps [finder] (scrolling it into view first) and settles.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

/// Types into the text field with [label] (its decoration label).
Future<void> enterField(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, text);
  await tester.pump();
}

/// No exception and no layout overflow happened.
void expectNoErrors(WidgetTester tester) => expect(tester.takeException(), isNull);

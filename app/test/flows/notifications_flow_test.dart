// Family updates (push notifications), the phone's side: Settings >
// Notifications saves the choices on the phone, and the app tells the server
// where and what to send (register_device) on start, when a choice changes
// and when Firebase rotates the token; signing out stops them
// (unregister_device). Firebase is replaced by a fake device; the server by
// the fake Supabase.

import 'dart:async';

import 'package:baby_app/data/settings_repository.dart';
import 'package:baby_app/features/notifications/notifications_screen.dart';
import 'package:baby_app/features/notifications/push.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'harness.dart';

final en = lookupAppLocalizations(const Locale('en'));

class FakePushDevice implements PushDevice {
  String? currentToken = 'fake-fcm-token-0123456789-abcdef';
  final refresh = StreamController<String>.broadcast();
  var permissionAsked = 0;

  @override
  String get platform => 'android';

  @override
  Future<bool> requestPermission() async {
    permissionAsked++;
    return true;
  }

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> get onTokenRefresh => refresh.stream;

  @override
  Future<String> timeZone() async => 'Asia/Karachi';
}

const _register = '/rest/v1/rpc/register_device';
const _unregister = '/rest/v1/rpc/unregister_device';

void main() {
  setUpFlowTests();

  late FlowEnv env;
  late FakePushDevice device;
  setUp(() async {
    env = await FlowEnv.open();
    device = FakePushDevice();
    for (final path in [_register, _unregister]) {
      env.server.on('POST', path, (_) => http.Response('', 204));
    }
  });
  tearDown(() => env.close());

  Future<void> pumpWithPush(WidgetTester tester) =>
      env.pumpApp(tester, extra: [pushDeviceProvider.overrideWithValue(device)]);

  List<Map<String, Object?>> registrations() =>
      [for (final r in env.server.sent(_register, method: 'POST')) (r.json! as Map).cast<String, Object?>()];

  Future<void> openNotifications(WidgetTester tester) async {
    await tapAndSettle(tester, find.byTooltip(en.settingsTitle));
    await tapAndSettle(tester, find.widgetWithText(ListTile, en.notificationsTitle));
  }

  /// Waits until the app has sent a registration with [key] = [value]
  /// (sending happens a moment after the setting is saved).
  Future<void> sent(WidgetTester tester, String key, Object? value) async {
    bool done() => registrations().isNotEmpty && registrations().last[key] == value;
    await pumpUntil(tester, done, max: 40);
    expect(registrations().last, containsPair(key, value));
  }

  Finder switchFor(String title) => find.widgetWithText(SwitchListTile, title);
  bool isOn(WidgetTester tester, String title) => tester.widget<SwitchListTile>(switchFor(title)).value;

  group('registering this phone', () {
    flowWidgets('on start: token, platform, language, time zone and every kind on', (tester) async {
      await pumpWithPush(tester);
      expectNoErrors(tester);
      expect(device.permissionAsked, greaterThan(0));
      expect(registrations().last, {
        'p_token': device.currentToken,
        'p_platform': 'android',
        'p_locale': 'en',
        'p_time_zone': 'Asia/Karachi',
        'p_notify_feeds': true,
        'p_notify_sleep': true,
        'p_notify_medicines': true,
        'p_quiet_from': null,
        'p_quiet_to': null,
      });
    });

    flowWidgets('the app in Urdu asks for Urdu, Roman Urdu for ur-Latn', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await pumpWithPush(tester);
      expect(registrations().last['p_locale'], 'ur');
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur_Latn'));
      await sent(tester, 'p_locale', 'ur-Latn');
    });

    flowWidgets('a new token from Firebase is sent to the server', (tester) async {
      await pumpWithPush(tester);
      device.refresh.add('rotated-fcm-token-9876543210-zyxwvu');
      await settle(tester);
      await sent(tester, 'p_token', 'rotated-fcm-token-9876543210-zyxwvu');
    });

    flowWidgets('offline, the app keeps working (and tries again later)', (tester) async {
      env.server.on('POST', _register, (_) => throw http.ClientException('Network is unreachable'));
      await pumpWithPush(tester);
      expectNoErrors(tester);
      expect(find.text(en.tabToday), findsWidgets);
    });

    flowWidgets('no Firebase on this phone: nothing is sent', (tester) async {
      await env.pumpApp(tester);
      expect(registrations(), isEmpty);
    });
  });

  group('Settings > Notifications', () {
    flowWidgets('every kind starts on; switching one off is saved and sent', (tester) async {
      await pumpWithPush(tester);
      await openNotifications(tester);
      expectNoErrors(tester);
      expect(isOn(tester, en.feeds), isTrue);
      expect(isOn(tester, en.sleep), isTrue);
      expect(isOn(tester, en.pushMedicines), isTrue);

      await tapAndSettle(tester, switchFor(en.sleep));
      // The switch follows the saved setting, a moment after the tap.
      await pumpUntil(tester, () => !isOn(tester, en.sleep), max: 20);
      expect(isOn(tester, en.sleep), isFalse);
      final saved = await env.rows(tester, 'SELECT value FROM app_settings WHERE id = ?', [SettingKeys.notifySleep]);
      expect(saved.single['value'], '0');
      await sent(tester, 'p_notify_sleep', false);
      expect(registrations().last, containsPair('p_notify_feeds', true));

      // And back on.
      await tapAndSettle(tester, switchFor(en.sleep));
      await sent(tester, 'p_notify_sleep', true);
    });

    flowWidgets('quiet hours: on suggests 10 pm to 7 am, off clears them', (tester) async {
      await pumpWithPush(tester);
      await openNotifications(tester);
      expect(find.text(en.quietHoursOff), findsOneWidget);
      expect(find.text(en.quietFrom), findsNothing);

      await tapAndSettle(tester, switchFor(en.quietHours));
      await sent(tester, 'p_quiet_from', 22 * 60);
      expect(registrations().last, containsPair('p_quiet_to', 7 * 60));
      expect(find.text(en.quietFrom), findsOneWidget);
      expect(find.text(en.quietTo), findsOneWidget);
      expect(find.text(en.quietHoursOn('10:00 PM', '7:00 AM')), findsOneWidget);

      await tapAndSettle(tester, switchFor(en.quietHours));
      await sent(tester, 'p_quiet_from', null);
      expect(registrations().last, containsPair('p_quiet_to', null));
      expect(find.text(en.quietFrom), findsNothing);
    });

    flowWidgets('changing when quiet hours start uses the time picker', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.quietHours, PushPrefs.encodeQuiet(22 * 60, 7 * 60)));
      await pumpWithPush(tester);
      await openNotifications(tester);
      await tapAndSettle(tester, find.widgetWithText(ListTile, en.quietFrom));
      expect(find.byType(TimePickerDialog), findsOneWidget);
      // Switch to typing and enter 9:30 PM.
      await tapAndSettle(tester, find.byIcon(Icons.keyboard_outlined));
      final fields = find.descendant(of: find.byType(TimePickerDialog), matching: find.byType(TextField));
      await tester.enterText(fields.at(0), '9');
      await tester.enterText(fields.at(1), '30');
      await tapAndSettle(tester, find.text('OK'));
      await sent(tester, 'p_quiet_from', 21 * 60 + 30);
      expect(registrations().last, containsPair('p_quiet_to', 7 * 60));
    });

    flowWidgets('without push on this phone it says so, and the choices are still saved', (tester) async {
      await env.pumpApp(tester);
      await openNotifications(tester);
      expect(find.text(en.pushUnavailable), findsOneWidget);
      await tapAndSettle(tester, switchFor(en.feeds));
      final saved = await env.rows(tester, 'SELECT value FROM app_settings WHERE id = ?', [SettingKeys.notifyFeeds]);
      expect(saved.single['value'], '0');
    });

    flowWidgets('the screen builds in Urdu', (tester) async {
      await tester.runAsync(() => env.setting(SettingKeys.locale, 'ur'));
      await env.pumpScreen(tester, const NotificationsScreen(), locale: const Locale('ur'));
      expectNoErrors(tester);
      expect(find.text(lookupAppLocalizations(const Locale('ur')).quietHours), findsOneWidget);
    });
  });

  group('signing out', () {
    flowWidgets('tells the server to stop sending to this phone, before signing out', (tester) async {
      env.server.on('POST', '/auth/v1/logout', (_) => http.Response('', 204));
      // Everything already uploaded, so no "not uploaded yet" warning.
      await tester.runAsync(() async {
        while (true) {
          final batch = await env.db.getCrudBatch(limit: 1000);
          if (batch == null) break;
          await batch.complete();
        }
      });
      await pumpWithPush(tester);
      await tapAndSettle(tester, find.byTooltip(en.settingsTitle));
      await tester.scrollUntilVisible(find.text(en.signOut), 300, scrollable: find.byType(Scrollable).first);
      await tapAndSettle(tester, find.text(en.signOut));
      await pumpUntil(tester, () => env.supabase.auth.currentSession == null);

      final unregister = env.server.sent(_unregister, method: 'POST');
      expect(unregister.single.json, {'p_token': device.currentToken});
      final order = env.server.requests.map((r) => r.path).toList();
      expect(order.indexOf(_unregister), lessThan(order.indexOf('/auth/v1/logout')));
      expect(find.text(en.signInTitle), findsOneWidget);
    });
  });
}

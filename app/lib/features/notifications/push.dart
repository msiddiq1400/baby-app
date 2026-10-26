import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/config/firebase_config.dart';
import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../data/settings_repository.dart';

// Push notifications between family phones: when someone else in the family
// logs a feed, a sleep or a medicine dose, the server (Edge Function
// notify-family) sends this phone a notification. The phone tells the
// server where to send them (its Firebase push token) and what this person
// wants: which kinds, quiet hours, language and time zone. Settings are kept
// on the phone (app_settings) and sent again whenever they change.

/// What this person wants to be told about, on this phone.
@immutable
class PushPrefs {
  const PushPrefs({this.feeds = true, this.sleep = true, this.medicines = true, this.quietFrom, this.quietTo});

  final bool feeds;
  final bool sleep;
  final bool medicines;

  /// Quiet hours in minutes after midnight, both set or both null. From
  /// later than to means overnight (e.g. 22:00 to 07:00).
  final int? quietFrom;
  final int? quietTo;

  bool get hasQuietHours => quietFrom != null && quietTo != null;

  /// Suggested when quiet hours are first switched on.
  static const defaultQuietFrom = 22 * 60;
  static const defaultQuietTo = 7 * 60;

  /// '1320-420' (22:00 to 07:00), or null for none.
  static String? encodeQuiet(int? from, int? to) => from == null || to == null ? null : '$from-$to';

  static (int?, int?) decodeQuiet(String? value) {
    final parts = value?.split('-');
    if (parts == null || parts.length != 2) return (null, null);
    final from = int.tryParse(parts[0]);
    final to = int.tryParse(parts[1]);
    if (from == null || to == null || from < 0 || from > 1439 || to < 0 || to > 1439) return (null, null);
    return (from, to);
  }

  static TimeOfDay timeOf(int minutes) => TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  @override
  bool operator ==(Object other) =>
      other is PushPrefs &&
      other.feeds == feeds &&
      other.sleep == sleep &&
      other.medicines == medicines &&
      other.quietFrom == quietFrom &&
      other.quietTo == quietTo;

  @override
  int get hashCode => Object.hash(feeds, sleep, medicines, quietFrom, quietTo);
}

/// The saved settings; null while they're loading. A kind is on unless it
/// was switched off ('0').
final pushPrefsProvider = Provider<PushPrefs?>((ref) {
  final values = [
    for (final key in [SettingKeys.notifyFeeds, SettingKeys.notifySleep, SettingKeys.notifyMedicines, SettingKeys.quietHours])
      ref.watch(settingProvider(key)),
  ];
  if (values.any((v) => !v.hasValue)) return null;
  final (from, to) = PushPrefs.decodeQuiet(values[3].value);
  return PushPrefs(
    feeds: values[0].value != '0',
    sleep: values[1].value != '0',
    medicines: values[2].value != '0',
    quietFrom: from,
    quietTo: to,
  );
});

/// Saves one kind on or off.
Future<void> setPushKind(WidgetRef ref, String key, bool on) =>
    ref.read(settingsRepositoryProvider).set(key, on ? null : '0');

/// Saves quiet hours (null, null to switch them off).
Future<void> setQuietHours(WidgetRef ref, int? from, int? to) =>
    ref.read(settingsRepositoryProvider).set(SettingKeys.quietHours, PushPrefs.encodeQuiet(from, to));

/// The phone's side of push: its Firebase token, permission, time zone.
/// Tests replace it with a fake.
abstract class PushDevice {
  /// 'android' or 'ios'.
  String get platform;

  /// Asks to show notifications (iOS, Android 13+). True when allowed.
  Future<bool> requestPermission();

  /// Where the server sends this phone's pushes; null if Firebase can't
  /// give one (e.g. no Google Play services).
  Future<String?> token();

  Stream<String> get onTokenRefresh;

  /// IANA time zone, e.g. 'Asia/Karachi', for quiet hours.
  Future<String> timeZone();
}

/// Set in main() when Firebase started; without it the app runs without push.
abstract final class PushSetup {
  static bool available = false;

  /// Starts Firebase if this build has its settings. Never throws.
  static Future<void> start() async {
    final options = FirebaseConfig.current;
    if (options == null) return;
    try {
      await Firebase.initializeApp(options: options);
      available = true;
      await FamilyNotifications.createChannel();
      // With the app open the phone doesn't show pushes itself: put them up.
      FirebaseMessaging.onMessage.listen((message) {
        final n = message.notification;
        if (n == null) return;
        FamilyNotifications.show(
          title: n.title ?? '',
          body: n.body ?? '',
          tag: message.data['record_id'] as String? ?? message.messageId ?? '${n.title}${n.body}',
        ).ignore();
      });
    } catch (e) {
      debugPrint('Push not available: $e');
    }
  }
}

class _FirebasePushDevice implements PushDevice {
  final _messaging = FirebaseMessaging.instance;

  @override
  String get platform => Platform.isIOS ? 'ios' : 'android';

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<String> timeZone() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      return 'UTC';
    }
  }
}

/// This phone's push side, or null when push isn't available.
final pushDeviceProvider = Provider<PushDevice?>((ref) => PushSetup.available ? _FirebasePushDevice() : null);

/// The language for notifications: the app's chosen one, else the phone's.
/// As the server expects it: 'en', 'ur' or 'ur-Latn'.
final pushLocaleProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider) ?? PlatformDispatcher.instance.locale;
  if (locale.languageCode != 'ur') return 'en';
  return locale.scriptCode == 'Latn' ? 'ur-Latn' : 'ur';
});

/// Tells the server where to send this person's family updates, and what
/// they want, whenever they sign in, the token changes or a setting
/// changes. Kept alive by the main screen. Offline, it fails and Riverpod
/// tries again later.
final pushRegistrationProvider = FutureProvider<void>((ref) async {
  final device = ref.watch(pushDeviceProvider);
  final user = ref.watch(currentUserIdProvider);
  final prefs = ref.watch(pushPrefsProvider);
  final locale = ref.watch(pushLocaleProvider);
  if (device == null || user == null || prefs == null) return;

  final supabase = ref.read(supabaseProvider);
  Future<void> register(String token) async => supabase.rpc<void>('register_device', params: {
        'p_token': token,
        'p_platform': device.platform,
        'p_locale': locale,
        'p_time_zone': await device.timeZone(),
        'p_notify_feeds': prefs.feeds,
        'p_notify_sleep': prefs.sleep,
        'p_notify_medicines': prefs.medicines,
        'p_quiet_from': prefs.quietFrom,
        'p_quiet_to': prefs.quietTo,
      });

  final sub = device.onTokenRefresh.listen((t) => register(t).catchError((Object e) {
        debugPrint('Push: could not register new token: $e');
      }));
  ref.onDispose(sub.cancel);

  await device.requestPermission();
  final token = await device.token();
  if (token != null) await register(token);
});

/// Stops family updates to this phone; called before signing out, while
/// still signed in (the next person to sign in here registers it for
/// themselves). Gives up quietly offline: the next sign-in on this phone
/// takes the token over anyway, and deleting an account drops its tokens.
Future<void> unregisterPush(PushDevice? device, SupabaseClient supabase) async {
  if (device == null) return;
  try {
    final token = await device.token().timeout(const Duration(seconds: 5));
    if (token == null) return;
    await supabase.rpc<void>('unregister_device', params: {'p_token': token}).timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Push: could not unregister: $e');
  }
}

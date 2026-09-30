import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// A notification to show at [at] (phone's local time).
class Reminder {
  const Reminder({required this.key, required this.at, required this.title, required this.body});

  /// Stable name within its group, e.g. 'PK-6w-due'; also the source of the id.
  final String key;
  final DateTime at;
  final String title;
  final String body;
}

/// Local notifications scheduled on the phone, so reminders work offline.
/// Reminders are managed in groups (e.g. 'vaccines'): each update replaces
/// the whole group, so nothing stale is left behind.
abstract final class Reminders {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void>? _ready;

  static Future<void> _init() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      // Falls back to UTC; reminders still fire, at a shifted hour.
      debugPrint('Reminders: could not read time zone: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        // One-colour moon (res/drawable/ic_notification.xml, kept by res/raw/keep.xml).
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        // Permission is asked for explicitly (see requestPermission), not at startup.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  static Future<void> _ensureReady() => _ready ??= _init();

  /// Asks to show notifications (Android 13+ and iOS). Safe to call often:
  /// the system only asks once.
  static Future<void> requestPermission() async {
    try {
      await _ensureReady();
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      // Never let a permission prompt break the screen that asked for it.
      debugPrint('Reminders: permission request failed: $e');
    }
  }

  /// Removes every reminder, e.g. on sign-out.
  static Future<void> cancelAll() async {
    await _ensureReady();
    await _plugin.cancelAll();
  }

  /// Cancels every pending reminder in [group] and schedules [reminders]
  /// (those in the past are skipped).
  static Future<void> replaceGroup(String group, List<Reminder> reminders) async {
    await _ensureReady();
    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (pending.payload?.startsWith('$group:') ?? false) await _plugin.cancel(id: pending.id);
    }

    final now = DateTime.now();
    for (final r in reminders) {
      if (!r.at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: notificationId('$group:${r.key}'),
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        title: r.title,
        body: r.body,
        payload: '$group:${r.key}',
        // Inexact is fine for "around 9 am" and needs no special permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Reminders',
            channelDescription: 'Vaccine and medicine reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}

/// A running feeding or sleep timer, shown as an ongoing notification with a
/// live clock so it's visible with the app closed. Android only: iPhones
/// need a Live Activity for this (todo 37).
abstract final class TimerNotifications {
  static bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Shows or updates the timer [key]. With [runningSince] the clock counts
  /// up from then; without it (paused) only [body] is shown.
  static Future<void> show(String key, {required String title, required String body, DateTime? runningSince}) async {
    if (!_supported) return;
    await Reminders._ensureReady();
    await Reminders._plugin.show(
      id: notificationId('timer:$key'),
      title: title,
      body: body,
      payload: 'timer:$key',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'timers',
          'Timers',
          channelDescription: 'Feeding and sleep timers that are running',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          silent: true,
          showWhen: runningSince != null,
          usesChronometer: runningSince != null,
          when: runningSince?.millisecondsSinceEpoch,
        ),
      ),
    );
  }

  static Future<void> cancel(String key) async {
    if (!_supported) return;
    await Reminders._ensureReady();
    await Reminders._plugin.cancel(id: notificationId('timer:$key'));
  }
}

/// Stable 31-bit id from a string (FNV-1a), so the same reminder always gets
/// the same notification id across app restarts.
@visibleForTesting
int notificationId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

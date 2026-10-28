import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crash reports (Firebase Crashlytics, project palna-care; todos.txt 14c).
///
/// Only release builds send them; debug builds and tests never do. A report
/// holds the error, where in the code it happened, and the phone model and
/// system version. It doesn't hold names, emails or anything logged about a
/// baby (privacy policy: "Crash reports").
abstract final class CrashReports {
  /// Call after Firebase has started ([firebaseReady]). Never throws.
  static Future<void> start({required bool firebaseReady}) async {
    if (!firebaseReady) return;
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);
      if (!kReleaseMode) return;

      // Errors in Flutter's own work (building, layout, painting).
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        crashlytics.recordFlutterFatalError(details);
        previous?.call(details);
      };
      // Everything else nobody caught (async code, plugins).
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('Crash reports not available: $e');
    }
  }
}

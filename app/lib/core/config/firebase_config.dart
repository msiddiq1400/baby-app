import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase settings for push notifications between family phones
/// (project "Palna"). These are public app identifiers, not secrets: they
/// only let the app ask Firebase for a push address. Sending pushes needs
/// the server's service account, which never leaves Supabase.
///
/// Firebase project palna-care (owner msiddiq17328@gmail.com), apps "Palna
/// Android" and "Palna iOS". With a value missing the app runs without push
/// (everything else works the same).
abstract final class FirebaseConfig {
  static const _projectId = 'palna-care';
  static const _senderId = '21861410022';
  static const _androidApiKey = 'AIzaSyDEd3ZDR51No_L207cALurUs-oJeLC_7zs';
  static const _androidAppId = '1:21861410022:android:e0b0cdbcb85bc30afcc727';
  static const _iosApiKey = 'AIzaSyBBkL5e6OjQvwiJ2qd0FPamnUC_mhb6eQc';
  static const _iosAppId = '1:21861410022:ios:713ad18cdb02dea4fcc727';

  /// Options for this platform, or null when push isn't set up for it.
  static FirebaseOptions? get current {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android when _androidAppId.isNotEmpty => const FirebaseOptions(
          apiKey: _androidApiKey,
          appId: _androidAppId,
          messagingSenderId: _senderId,
          projectId: _projectId,
        ),
      TargetPlatform.iOS when _iosAppId.isNotEmpty => const FirebaseOptions(
          apiKey: _iosApiKey,
          appId: _iosAppId,
          messagingSenderId: _senderId,
          projectId: _projectId,
          iosBundleId: 'com.palnacare.app',
        ),
      _ => null,
    };
  }
}

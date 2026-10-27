/// Server settings, injected at build time with
/// `flutter run --dart-define-from-file=env/dev.json`.
///
/// Moving from Supabase Cloud to the self-hosted VPS only means pointing
/// these at the new server; no code changes.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// PowerSync instance that syncs the phone's database with Supabase.
  static const powersyncUrl = String.fromEnvironment('POWERSYNC_URL');

  /// Google OAuth client IDs (public, not secrets). Empty hides Google sign-in.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  /// RevenueCat public SDK keys (appl_... / goog_..., not secrets) for Palna
  /// Pro (todos.txt 38b). Empty: the upgrade screen says plans aren't
  /// available yet.
  static const revenueCatAppleKey = String.fromEnvironment('REVENUECAT_APPLE_KEY');
  static const revenueCatGoogleKey = String.fromEnvironment('REVENUECAT_GOOGLE_KEY');

  /// RevenueCat Test Store key (test_..., public): pretend purchases for
  /// trying Palna Pro. Used by debug builds only, never in a release.
  static const revenueCatTestKey = String.fromEnvironment('REVENUECAT_TEST_KEY');

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty || powersyncUrl.isEmpty) {
      throw StateError(
        'Missing server config. Run with --dart-define-from-file=env/dev.json '
        '(copy env/example.json to get started).',
      );
    }
  }
}

/// Server settings, injected at build time with
/// `flutter run --dart-define-from-file=env/dev.json`.
///
/// Moving from Supabase Cloud to the self-hosted VPS only means pointing
/// these at the new server; no code changes.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Google OAuth client IDs (public, not secrets). Empty hides Google sign-in.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'Missing server config. Run with --dart-define-from-file=env/dev.json '
        '(copy env/example.json to get started).',
      );
    }
  }
}

/// Server settings, injected at build time with
/// `flutter run --dart-define-from-file=env/dev.json`.
///
/// Moving from Supabase Cloud to the self-hosted VPS only means pointing
/// these at the new server; no code changes.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Where links in sign-up emails send people back to. Registered in
  /// AndroidManifest.xml, Info.plist and the Supabase redirect URL list.
  static const authRedirectUrl = 'app.babyapp://login-callback';

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'Missing server config. Run with --dart-define-from-file=env/dev.json '
        '(copy env/example.json to get started).',
      );
    }
  }
}

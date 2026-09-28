import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';

/// Native Google sign-in: the phone's own account picker returns an ID
/// token, which Supabase verifies and turns into a session.
abstract final class GoogleAuth {
  static Future<void>? _initialized;

  /// Hidden until the Google client IDs are in env/*.json.
  static bool get isConfigured => Env.googleWebClientId.isNotEmpty;

  /// Returns false if the person closed the account picker.
  static Future<bool> signIn(SupabaseClient db) async {
    final google = GoogleSignIn.instance;
    await (_initialized ??= google.initialize(
      // Android asks Google for a token meant for this (web) client, which is
      // the one registered with Supabase. iOS additionally needs its own client.
      serverClientId: Env.googleWebClientId,
      clientId: Env.googleIosClientId.isEmpty ? null : Env.googleIosClientId,
    ));

    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) throw const AuthException('Google did not return an ID token.');
    await db.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
    return true;
  }

  /// Forget the chosen Google account so the picker shows again next time.
  static Future<void> signOut() async {
    if (_initialized != null) await GoogleSignIn.instance.signOut();
  }
}

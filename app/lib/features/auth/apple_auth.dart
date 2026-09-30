import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Native Sign in with Apple (iPhone only; the App Store requires it next to
/// Google). Apple returns an ID token, which Supabase verifies against the
/// nonce made here.
abstract final class AppleAuth {
  static bool get isAvailable => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Returns false if the person closed Apple's sheet.
  static Future<bool> signIn(SupabaseClient db) async {
    final rawNonce = _randomNonce();
    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return false;
      rethrow;
    }

    final idToken = credential.identityToken;
    if (idToken == null) throw const AuthException('Apple did not return an ID token.');
    final response = await db.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    // Apple shares the name only on the very first sign-in and it isn't in
    // the token, so save it now: family members see who logged what.
    final name = [credential.givenName, credential.familyName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    final user = response.user;
    if (name.isNotEmpty && user != null) {
      try {
        await db.auth.updateUser(UserAttributes(data: {'full_name': name}));
        await db.from('profiles').update({'display_name': name}).eq('id', user.id);
      } catch (_) {
        // Signed in either way; the name can be missing without harm.
      }
    }
    return true;
  }

  static String _randomNonce([int length = 32]) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

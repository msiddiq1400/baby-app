import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/settings_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange,
);

/// The signed-in user's id, or null. Data providers watch this so they reset
/// when someone signs out or a different user signs in.
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

/// Ticks every minute so "2h 10m ago" style labels stay current.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});

/// Language chosen in the app, saved on the phone; null follows the phone's
/// language.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => _decode(ref.watch(settingProvider(SettingKeys.locale)).value);

  Future<void> set(Locale? locale) async {
    state = locale;
    await ref.read(settingsRepositoryProvider).set(SettingKeys.locale, _encode(locale));
  }

  static String? _encode(Locale? l) => l == null ? null : [l.languageCode, ?l.scriptCode].join('_');

  static Locale? _decode(String? v) => switch (v) {
        'en' => const Locale('en'),
        'ur' => const Locale('ur'),
        'ur_Latn' => const Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
        _ => null,
      };
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

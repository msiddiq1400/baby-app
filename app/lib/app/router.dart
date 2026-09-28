import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(supabaseProvider).auth;
  final authChanges = _StreamListenable(auth.onAuthStateChange);
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    refreshListenable: authChanges,
    redirect: (context, state) {
      final signedIn = auth.currentSession != null;
      final onAuthPage = const {'/sign-in', '/verify'}.contains(state.matchedLocation);
      if (!signedIn) return onAuthPage ? null : '/sign-in';
      if (onAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
      GoRoute(
        path: '/verify',
        builder: (context, state) => VerifyCodeScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
    ],
  );
});

/// Re-runs the router's redirect whenever the stream emits.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

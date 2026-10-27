import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';

/// Buying Palna Pro through Apple / Google billing, with RevenueCat
/// (todos.txt 38b). RevenueCat knows each person by their Supabase user id,
/// and its webhook tells our server (supabase/functions/revenuecat), which
/// gives the whole family Pro.
///
/// RevenueCat setup (dashboard): entitlement "pro"; products
/// palna_pro_monthly and palna_pro_yearly (7-day free trial) in the
/// "default" offering as the Monthly and Annual packages.
abstract final class ProStore {
  static const entitlement = 'pro';

  static bool _started = false;

  /// This build has a RevenueCat key for this platform.
  static String get _apiKey {
    if (kIsWeb) return '';
    // Debug builds: RevenueCat's Test Store, if this build has its key.
    if (kDebugMode && Env.revenueCatTestKey.isNotEmpty) return Env.revenueCatTestKey;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => Env.revenueCatAppleKey,
      TargetPlatform.android => Env.revenueCatGoogleKey,
      _ => '',
    };
  }

  static bool get available => _started;

  /// Configures RevenueCat and follows sign-in / sign-out. Never throws;
  /// without a key Pro just can't be bought on this build.
  static Future<void> start(SupabaseClient supabase) async {
    if (_apiKey.isEmpty) return;
    try {
      final config = PurchasesConfiguration(_apiKey)..appUserID = supabase.auth.currentUser?.id;
      await Purchases.configure(config);
      _started = true;
      supabase.auth.onAuthStateChange.listen((state) async {
        try {
          final user = state.session?.user;
          if (user != null) {
            await Purchases.logIn(user.id);
          } else if (state.event == AuthChangeEvent.signedOut && !await Purchases.isAnonymous) {
            await Purchases.logOut();
          }
        } catch (e) {
          debugPrint('RevenueCat sign-in: $e');
        }
      });
    } catch (e) {
      debugPrint('RevenueCat not available: $e');
    }
  }

  /// The monthly and yearly options, or null when they can't be loaded
  /// (offline, or not set up yet).
  static Future<({Package? monthly, Package? yearly})?> packages() async {
    if (!_started) return null;
    try {
      final offering = (await Purchases.getOfferings()).current;
      if (offering == null) return null;
      return (monthly: offering.monthly, yearly: offering.annual);
    } catch (e) {
      debugPrint('RevenueCat offerings: $e');
      return null;
    }
  }

  static bool isPro(CustomerInfo info) => info.entitlements.active.containsKey(entitlement);

  /// Buys [package]. True: Pro is on. False: cancelled. Throws on errors.
  static Future<bool> buy(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return isPro(result.customerInfo);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  /// "Restore purchases": true when the store account has Pro.
  static Future<bool> restore() async => isPro(await Purchases.restorePurchases());

  /// Pro on this phone's store account right now (null: unknown).
  static Future<bool?> currentlyPro() async {
    if (!_started) return null;
    try {
      return isPro(await Purchases.getCustomerInfo());
    } catch (_) {
      return null;
    }
  }

  /// Where to manage or cancel the subscription (the store's page).
  static Future<String?> managementUrl() async {
    if (!_started) return null;
    try {
      return (await Purchases.getCustomerInfo()).managementURL;
    } catch (_) {
      return null;
    }
  }

  /// Asks our server to fetch the new state from RevenueCat now, so the
  /// family's other phones get Pro within seconds. Best effort: the webhook
  /// does the same a moment later.
  static Future<void> tellServer(SupabaseClient supabase) async {
    try {
      await supabase.functions.invoke('revenuecat').timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('revenuecat refresh: $e');
    }
  }
}

/// The signed-in person's own Pro on RevenueCat, checked when the app
/// starts (covers the moments before the server's family flag syncs).
final storeEntitlementProvider = FutureProvider<bool>((ref) async => await ProStore.currentlyPro() ?? false);

/// Pro bought or restored on this phone in this session (shown at once,
/// before the server's family flag syncs back).
class StoreProNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool pro) => state = pro;
}

final storeProProvider = NotifierProvider<StoreProNotifier, bool>(StoreProNotifier.new);

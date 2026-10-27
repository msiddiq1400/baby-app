import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/baby_repository.dart';
import '../../data/local_db.dart';
import '../../data/settings_repository.dart';
import 'store.dart';

/// Palna Pro (todos.txt 38b). One person buys it and the whole family gets
/// it. The server keeps families.pro_until and enforces the first two
/// limits; the rest are checked here.
abstract final class PlanLimits {
  static const freeBabies = 1;
  static const freePhotosPerMonth = 1;
  static const proPhotosPerMonth = 10;
  static const freeReportDays = 7;
}

/// The server's "infinity" (no end date) and anything unreadable.
DateTime? parseProUntil(Object? value) => switch (value) {
  'infinity' => DateTime.utc(9999),
  final String s => DateTime.tryParse(s),
  _ => null,
};

/// When the family's Pro ends (null: Free), as synced from the server.
final familyProUntilProvider = StreamProvider.family<DateTime?, String>(
  (ref, familyId) => ref
      .watch(powerSyncProvider)
      .watch('SELECT pro_until FROM families WHERE id = ?', parameters: [familyId])
      .map((rows) => rows.isEmpty ? null : parseProUntil(rows.first['pro_until'])),
);

/// Whether the selected baby's family has Pro: from the server, or right
/// after a purchase on this phone (before the server has caught up).
final isProProvider = Provider<bool>((ref) {
  if (ref.watch(storeProProvider)) return true;
  final baby = ref.watch(currentBabyProvider).value;
  if (baby == null) return false;
  final until = ref.watch(familyProUntilProvider(baby.familyId)).value;
  return until != null && until.isAfter(DateTime.now());
});

/// The family's Pro end date, for "Pro until ..." (null: Free or no end).
final proUntilProvider = Provider<DateTime?>((ref) {
  final baby = ref.watch(currentBabyProvider).value;
  if (baby == null) return null;
  final until = ref.watch(familyProUntilProvider(baby.familyId)).value;
  return until == null || until.year >= 9999 ? null : until;
});

/// The colour theme: the one chosen on this phone while the family has Pro,
/// otherwise navy.
final themeAccentProvider = Provider<ThemeAccent>((ref) {
  if (!ref.watch(isProProvider)) return ThemeAccent.navy;
  final chosen = ref.watch(settingProvider(SettingKeys.themeAccent)).value;
  return ThemeAccent.values.firstWhere((a) => a.name == chosen, orElse: () => ThemeAccent.navy);
});

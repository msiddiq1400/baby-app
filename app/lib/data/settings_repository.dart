import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import 'local_db.dart';

/// Small settings kept only on this phone (never synced), e.g. the chosen
/// language and which baby is shown. Cleared on sign-out with the rest of
/// the phone's data.
class SettingsRepository {
  SettingsRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<String?> watch(String key) => _db
      .watch('SELECT value FROM app_settings WHERE id = ?', parameters: [key])
      .map((rows) => rows.isEmpty ? null : rows.first['value'] as String?);

  Future<void> set(String key, String? value) {
    return _db.writeTransaction((tx) async {
      final existing = await tx.getOptional('SELECT id FROM app_settings WHERE id = ?', [key]);
      if (existing == null) {
        await tx.execute('INSERT INTO app_settings (id, value) VALUES (?, ?)', [key, value]);
      } else {
        await tx.execute('UPDATE app_settings SET value = ? WHERE id = ?', [value, key]);
      }
    });
  }
}

final settingsRepositoryProvider = Provider((ref) => SettingsRepository(ref.watch(powerSyncProvider)));

final settingProvider = StreamProvider.family<String?, String>(
  (ref, key) => ref.watch(settingsRepositoryProvider).watch(key),
);

abstract final class SettingKeys {
  static const locale = 'locale';
  static const babyId = 'baby_id';
  static const themeMode = 'theme_mode';

  /// Colour theme (Palna Pro): 'rose', 'sage', 'lavender'; null = navy.
  static const themeAccent = 'theme_accent';

  // Family updates (push): '0' when switched off, otherwise on.
  static const notifyFeeds = 'notify_feeds';
  static const notifySleep = 'notify_sleep';
  static const notifyMedicines = 'notify_medicines';

  /// Quiet hours as 'from-to' minutes after midnight, e.g. '1320-420'.
  static const quietHours = 'quiet_hours';
}

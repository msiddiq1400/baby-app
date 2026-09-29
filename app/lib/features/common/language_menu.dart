import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../data/local_db.dart';
import '../../l10n/app_localizations.dart';
import '../auth/google_auth.dart';
import '../settings/help_screen.dart';
import '../settings/settings_screen.dart';

/// App-bar menu for switching between English, Urdu and Roman Urdu,
/// optionally with a sign-out entry.
class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key, this.showSignOut = false});

  final bool showSignOut;

  static const _languages = [
    (Locale('en'), 'English'),
    (Locale('ur'), 'اردو'),
    (Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'), 'Roman Urdu'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context);
    return PopupMenuButton<VoidCallback>(
      icon: const Icon(Icons.more_vert),
      tooltip: l10n.language,
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        for (final (locale, label) in _languages)
          CheckedPopupMenuItem(
            value: () => ref.read(localeProvider.notifier).set(locale),
            checked: locale == current,
            child: Text(label),
          ),
        if (showSignOut) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: () => Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute<void>(builder: (_) => const HelpScreen())),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.emergency_outlined, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.helpTitle),
            ),
          ),
          PopupMenuItem(
            value: () => Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settingsTitle),
            ),
          ),
          PopupMenuItem(
            value: () async {
              if (!await _confirmSignOut(context, ref)) return;
              await Reminders.cancelAll();
              await GoogleAuth.signOut();
              await ref.read(supabaseProvider).auth.signOut();
            },
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
              title: Text(l10n.signOut),
            ),
          ),
        ],
      ],
    );
  }

  /// Signing out wipes the phone's database, so warn if offline changes
  /// haven't uploaded yet.
  Future<bool> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final pending = await ref.read(powerSyncProvider).getNextCrudTransaction() != null;
    if (!pending || !context.mounted) return true;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsyncedSignOutTitle),
        content: Text(l10n.unsyncedSignOutBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.signOutAnyway)),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

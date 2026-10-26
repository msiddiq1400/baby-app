import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../data/local_db.dart';
import '../../l10n/app_localizations.dart';
import '../auth/google_auth.dart';
import '../notifications/push.dart';
import '../settings/help_screen.dart';
import '../settings/settings_screen.dart';

/// The app's languages, each named in its own language.
const appLanguages = [
  (Locale('en'), 'English'),
  (Locale('ur'), 'اردو'),
  (Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'), 'Roman Urdu'),
];

/// Signs out, after a warning if offline changes haven't uploaded yet
/// (signing out wipes the phone's database). [beforeSignOut] runs once
/// it's confirmed, e.g. to close the screen it was started from.
Future<void> signOut(BuildContext context, WidgetRef ref, {VoidCallback? beforeSignOut}) async {
  if (!await _confirmSignOut(context, ref)) return;
  // Read before closing anything: a closed screen's ref can't be used.
  final supabase = ref.read(supabaseProvider);
  final auth = supabase.auth;
  final pushDevice = ref.read(pushDeviceProvider);
  beforeSignOut?.call();
  await Reminders.cancelAll();
  // While still signed in: stop family updates to this phone.
  await unregisterPush(pushDevice, supabase);
  await GoogleAuth.signOut();
  try {
    await auth.signOut();
  } on AuthException {
    // Offline: the phone is signed out already (the session is cleared
    // first); only telling the server failed, and the token expires anyway.
  }
}

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

/// App-bar buttons on the main tabs: emergency help (always in sight) and
/// settings (babies, family, language, sign out).
class MainActions extends StatelessWidget {
  const MainActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open(Widget screen) =>
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => screen));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "SOS" rather than a star-of-life symbol, which looked like the
        // settings gear next to it.
        IconButton(
          icon: Icon(Icons.sos, color: Theme.of(context).colorScheme.error),
          tooltip: l10n.helpTitle,
          onPressed: () => open(const HelpScreen()),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n.settingsTitle,
          onPressed: () => open(const SettingsScreen()),
        ),
      ],
    );
  }
}

/// App-bar menu for switching between English, Urdu and Roman Urdu, used
/// before there's a baby (sign-in, first baby). With [showSignOut] it also
/// has help, settings and sign out.
class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key, this.showSignOut = false});

  final bool showSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context);
    return PopupMenuButton<VoidCallback>(
      icon: const Icon(Icons.more_vert),
      tooltip: l10n.language,
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        for (final (locale, label) in appLanguages)
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
              leading: Icon(Icons.sos, color: Theme.of(context).colorScheme.error),
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
            value: () => signOut(context, ref),
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../l10n/app_localizations.dart';
import '../auth/google_auth.dart';

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
            value: () async {
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
}

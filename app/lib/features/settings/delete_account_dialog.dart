import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';
import '../../core/reminders.dart';
import '../../data/family_repository.dart';
import '../../l10n/app_localizations.dart';
import '../auth/google_auth.dart';

/// Explains what will be deleted, asks the user to type DELETE, then deletes
/// the account on the server and signs out (which also wipes the phone's copy).
Future<void> showDeleteAccountDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _DeleteAccountDialog());

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  static const _word = 'DELETE';

  final _confirm = TextEditingController();
  String? _error;
  var _busy = false;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  bool get _confirmed => _confirm.text.trim().toUpperCase() == _word;

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(familyRepositoryProvider).deleteMyAccount();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l10n.deleteAccountFailed;
        });
      }
      return;
    }
    // Read before the dialog closes; `ref` can't be used after that.
    final auth = ref.read(supabaseProvider).auth;
    if (mounted) Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
    await Reminders.cancelAll();
    await GoogleAuth.signOut();
    // The login no longer exists, so only the local session is cleared.
    await auth.signOut(scope: SignOutScope.local);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
      title: Text(l10n.deleteAccount),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.deleteAccountBody),
            const SizedBox(height: 16),
            TextField(
              controller: _confirm,
              enabled: !_busy,
              textCapitalization: TextCapitalization.characters,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.deleteAccountTypeHint, errorText: _error, errorMaxLines: 3),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.cancelButton)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: theme.colorScheme.onError),
          onPressed: _busy || !_confirmed ? null : _delete,
          child: _busy
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.deleteAccountButton),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

/// Whether the signed-in user has an email-and-password login (people who
/// only use Google have no password to change).
bool hasPasswordLogin(User? user) {
  final providers = user?.appMetadata['providers'];
  if (providers is List) return providers.contains('email');
  return user?.appMetadata['provider'] == 'email';
}

/// Whether to offer "Change password" (tests replace this).
final canChangePasswordProvider = Provider<bool>(
  (ref) => hasPasswordLogin(ref.watch(supabaseProvider).auth.currentUser),
);

Future<void> showChangePasswordDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _ChangePasswordDialog());

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _again = TextEditingController();
  String? _error;
  var _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(supabaseProvider).auth.updateUser(UserAttributes(password: _password.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
      Navigator.pop(context);
    } on AuthException catch (e) {
      // e.g. "New password should be different from the old password."
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l10n.passwordNotChanged);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.changePassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _password,
              obscureText: true,
              autofocus: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(labelText: l10n.newPasswordLabel),
              validator: (v) => (v ?? '').length < 6 ? l10n.passwordTooShort : null,
            ),
            TextFormField(
              controller: _again,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.repeatPasswordLabel, errorText: _error, errorMaxLines: 3),
              validator: (v) => v != _password.text ? l10n.passwordsDontMatch : null,
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.cancelButton)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.saveButton)),
      ],
    );
  }
}

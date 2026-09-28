import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _isSignUp = false;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = ref.read(supabaseProvider).auth;
    try {
      if (_isSignUp) {
        await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {'full_name': _name.text.trim()},
        );
      } else {
        await auth.signInWithPassword(email: _email.text.trim(), password: _password.text);
      }
      // The router moves on by itself once the session changes.
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      if (mounted) _showError(AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(actions: const [LanguageMenu()]),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.child_care, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.signInTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(l10n.signInSubtitle, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  if (_isSignUp) ...[
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(labelText: l10n.nameLabel),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: l10n.emailLabel),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch((v ?? '').trim()) ? null : l10n.invalidEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(labelText: l10n.passwordLabel),
                    obscureText: true,
                    autofillHints: [_isSignUp ? AutofillHints.newPassword : AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) => (v ?? '').length < 6 ? l10n.passwordTooShort : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isSignUp ? l10n.signUpButton : l10n.signInButton),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(_isSignUp ? l10n.switchToSignIn : l10n.switchToSignUp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

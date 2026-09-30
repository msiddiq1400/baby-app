import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

/// "Forgot password?": emails a 6-digit code, then sets a new password.
/// Entering the code signs the user in, and the new password is saved in the
/// same step (the app then moves on to the home screen by itself).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.email = ''});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  static const _codeLength = 6;
  static const _resendWait = 60;

  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  final _code = TextEditingController();
  final _password = TextEditingController();
  var _codeSent = false;
  var _busy = false;
  var _resendSecondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendSecondsLeft = _resendWait);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) timer.cancel();
      if (mounted) setState(() => _resendSecondsLeft--);
    });
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      // Supabase doesn't say whether the address has an account, so this
      // "succeeds" either way (nobody can use it to find out who signed up).
      await ref.read(supabaseProvider).auth.resetPasswordForEmail(_email.text.trim());
      if (!mounted) return;
      setState(() => _codeSent = true);
      _startResendTimer();
      _showMessage(AppLocalizations.of(context).codeSent);
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage(AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    // Read these before signing in: the app leaves this screen as soon as
    // the code is accepted.
    final auth = ref.read(supabaseProvider).auth;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await auth.verifyOTP(type: OtpType.recovery, email: _email.text.trim(), token: _code.text);
    } on AuthException {
      _code.clear();
      if (mounted) {
        setState(() => _busy = false);
        _showMessage(l10n.invalidCode);
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        _showMessage(l10n.errorGeneric);
      }
      return;
    }
    try {
      await auth.updateUser(UserAttributes(password: _password.text));
      messenger.showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
    } catch (_) {
      // Signed in, but the new password wasn't saved: it can be set again
      // from Settings.
      messenger.showSnackBar(SnackBar(content: Text(l10n.passwordNotChanged)));
    }
    if (mounted) setState(() => _busy = false);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(Icons.lock_reset, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(l10n.resetTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                _codeSent ? l10n.resetCodeSentHelp : l10n.resetHelp,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _email,
                enabled: !_codeSent && !_busy,
                decoration: InputDecoration(labelText: l10n.emailLabel),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textDirection: TextDirection.ltr,
                validator: (v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch((v ?? '').trim()) ? null : l10n.invalidEmail,
                onFieldSubmitted: (_) => _codeSent ? null : _sendCode(),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _code,
                  enabled: !_busy,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_codeLength),
                  ],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 10),
                  decoration: InputDecoration(labelText: l10n.codeLabel, counterText: ''),
                  validator: (v) => (v ?? '').length == _codeLength ? null : l10n.invalidCode,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  enabled: !_busy,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(labelText: l10n.newPasswordLabel),
                  validator: (v) => (v ?? '').length < 6 ? l10n.passwordTooShort : null,
                  onFieldSubmitted: (_) => _setPassword(),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : (_codeSent ? _setPassword : _sendCode),
                child: _busy
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_codeSent ? l10n.setPasswordButton : l10n.sendCodeButton),
              ),
              if (_codeSent)
                TextButton(
                  onPressed: _busy || _resendSecondsLeft > 0 ? null : _sendCode,
                  child: Text(_resendSecondsLeft > 0 ? l10n.resendIn(_resendSecondsLeft) : l10n.resendCode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

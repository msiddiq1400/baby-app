import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

/// Confirms a new account with the 6-digit code from the sign-up email.
class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  static const _codeLength = 6;

  /// Matches the server's minimum time between emails to the same person.
  static const _resendWait = 60;

  final _code = TextEditingController();
  var _busy = false;
  var _resendSecondsLeft = _resendWait;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendSecondsLeft = _resendWait);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) timer.cancel();
      setState(() => _resendSecondsLeft--);
    });
  }

  Future<void> _verify() async {
    if (_code.text.length != _codeLength || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(supabaseProvider).auth.verifyOTP(
            type: OtpType.signup,
            email: widget.email,
            token: _code.text,
          );
      // Signed in now; the router moves on to the app.
    } on AuthException {
      _code.clear();
      if (mounted) _showMessage(AppLocalizations.of(context).invalidCode);
    } catch (_) {
      if (mounted) _showMessage(AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(supabaseProvider).auth.resend(type: OtpType.signup, email: widget.email);
      _startResendTimer();
      if (mounted) _showMessage(AppLocalizations.of(context).codeSent);
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage(AppLocalizations.of(context).errorGeneric);
    }
  }

  /// Wraps [text] in Unicode left-to-right isolate marks (U+2066 ... U+2069).
  static String _leftToRight(String text) =>
      '${String.fromCharCode(0x2066)}$text${String.fromCharCode(0x2069)}';

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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.mark_email_read_outlined, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.verifyTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            // The email address is always left-to-right, even inside Urdu text.
            Text(
              l10n.verifySubtitle(_leftToRight(widget.email)),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _code,
              autofocus: true,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_codeLength),
              ],
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 12),
              decoration: InputDecoration(labelText: l10n.codeLabel, counterText: ''),
              // Submit as soon as all six digits are in.
              onChanged: (value) {
                if (value.length == _codeLength) _verify();
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.verifyButton),
            ),
            TextButton(
              onPressed: _resendSecondsLeft > 0 ? null : _resend,
              child: Text(_resendSecondsLeft > 0 ? l10n.resendIn(_resendSecondsLeft) : l10n.resendCode),
            ),
          ],
        ),
      ),
    );
  }
}

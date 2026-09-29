import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/family_repository.dart';
import '../../l10n/app_localizations.dart';

/// Asks for an invite code and joins that family. Returns true on success.
Future<bool> showJoinFamilyDialog(BuildContext context) async =>
    await showDialog<bool>(context: context, builder: (_) => const _JoinFamilyDialog()) ?? false;

class _JoinFamilyDialog extends ConsumerStatefulWidget {
  const _JoinFamilyDialog();

  @override
  ConsumerState<_JoinFamilyDialog> createState() => _JoinFamilyDialogState();
}

class _JoinFamilyDialogState extends ConsumerState<_JoinFamilyDialog> {
  final _code = TextEditingController();
  String? _error;
  var _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(familyRepositoryProvider).acceptInvite(_code.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.joinedFamily)));
      Navigator.pop(context, true);
    } on InvalidInviteException {
      setState(() => _error = l10n.invalidInvite);
    } catch (_) {
      setState(() => _error = l10n.familyOffline);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.joinFamily),
      content: TextField(
        controller: _code,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(6),
        ],
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 6),
        decoration: InputDecoration(labelText: l10n.inviteCodeLabel, errorText: _error, errorMaxLines: 3),
        onSubmitted: (_) => _join(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
        FilledButton(onPressed: _busy ? null : _join, child: Text(l10n.joinButton)),
      ],
    );
  }
}

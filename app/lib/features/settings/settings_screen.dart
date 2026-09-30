import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/baby_age.dart';
import '../../data/baby_repository.dart';
import '../../data/family_repository.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../baby/add_baby_screen.dart';
import '../../core/providers.dart';
import 'change_password_dialog.dart';
import 'delete_account_dialog.dart';
import 'join_family_dialog.dart';

/// Babies, family members and invites.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final babies = ref.watch(babiesProvider).value ?? const [];
    final current = ref.watch(currentBabyProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _Header(l10n.babiesSection),
          for (final baby in babies)
            ListTile(
              leading: Icon(
                baby.id == current?.id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: theme.colorScheme.primary,
              ),
              title: Text(baby.name),
              subtitle: Text(formatBabyAge(l10n, baby.birthDate, DateTime.now())),
              onTap: () => selectBaby(ref, baby.id),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => AddBabyScreen(existing: baby)),
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.addAnotherBaby),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => AddBabyScreen(familyId: current?.familyId)),
            ),
          ),
          const Divider(height: 32),
          _Header(l10n.familySection),
          if (current != null) _FamilySection(baby: current),
          ListTile(
            leading: const Icon(Icons.group_add_outlined),
            title: Text(l10n.joinFamily),
            onTap: () => showJoinFamilyDialog(context),
          ),
          const Divider(height: 32),
          _Header(l10n.appearanceSection),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.phone_android), label: Text(l10n.themeSystem)),
                ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(l10n.themeLight)),
                ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(l10n.themeDark)),
              ],
              selected: {ref.watch(themeModeProvider)},
              showSelectedIcon: false,
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
            ),
          ),
          const Divider(height: 32),
          _Header(l10n.accountSection),
          if (ref.watch(canChangePasswordProvider))
            ListTile(
              leading: const Icon(Icons.password_outlined),
              title: Text(l10n.changePassword),
              onTap: () => showChangePasswordDialog(context),
            ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text(l10n.deleteAccount, style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

/// Members of the current baby's family, with invite / remove / leave.
class _FamilySection extends ConsumerWidget {
  const _FamilySection({required this.baby});

  final Baby baby;

  Future<bool> _confirm(BuildContext context, String message, String action) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final code = await ref.read(familyRepositoryProvider).createInvite(baby.familyId);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.inviteCodeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                code,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(letterSpacing: 8),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(l10n.inviteCodeHelp),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelButton)),
            FilledButton.icon(
              onPressed: () => SharePlus.instance.share(ShareParams(text: l10n.inviteShareText(baby.name, code))),
              icon: const Icon(Icons.share),
              label: Text(l10n.shareButton),
            ),
          ],
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.familyOffline)));
      }
    }
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, FamilyMember member) async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      context,
      member.isMe ? l10n.leaveFamilyConfirm : l10n.removeMemberConfirm(member.name),
      member.isMe ? l10n.leaveFamily : l10n.removeMember,
    );
    if (!ok) return;
    try {
      await ref.read(familyRepositoryProvider).removeMember(baby.familyId, member.userId);
      ref.invalidate(familyMembersProvider(baby.familyId));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.familyOffline)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final members = ref.watch(familyMembersProvider(baby.familyId));

    return switch (members) {
      AsyncData(value: final list) => Column(
          children: [
            for (final m in list)
              ListTile(
                leading: Icon(m.isOwner ? Icons.star_outline : Icons.person_outline),
                title: Text(m.isMe ? '${m.name} (${l10n.youLabel})' : m.name),
                subtitle: Text(m.isOwner ? l10n.ownerLabel : l10n.caregiverLabel),
                trailing: _canRemove(list, m)
                    ? TextButton(
                        onPressed: () => _remove(context, ref, m),
                        child: Text(m.isMe ? l10n.leaveFamily : l10n.removeMember),
                      )
                    : null,
              ),
            if (list.any((m) => m.isMe && m.isOwner))
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: Text(l10n.inviteCaregiver),
                onTap: () => _invite(context, ref),
              ),
          ],
        ),
      AsyncError() => ListTile(leading: const Icon(Icons.cloud_off), title: Text(l10n.familyOffline)),
      _ => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
    };
  }

  /// Owners can remove caregivers; caregivers can leave. An owner can't
  /// remove themselves (the family would have no owner).
  static bool _canRemove(List<FamilyMember> members, FamilyMember m) {
    final meIsOwner = members.any((x) => x.isMe && x.isOwner);
    if (m.isMe) return !m.isOwner;
    return meIsOwner && !m.isOwner;
  }
}

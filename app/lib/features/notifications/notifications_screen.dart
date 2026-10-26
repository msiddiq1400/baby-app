import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/topic_icons.dart';
import '../../data/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import 'push.dart';

/// Settings > Notifications: which updates from the rest of the family
/// this person gets on this phone, and quiet hours. Saved on the phone and
/// sent to the server (pushRegistrationProvider) when online.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(pushPrefsProvider);
    final available = ref.watch(pushDeviceProvider) != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: prefs == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (!available)
                  Card(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: ListTile(leading: const Icon(Icons.info_outline), title: Text(l10n.pushUnavailable)),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(l10n.pushIntro, style: theme.textTheme.bodyLarge),
                ),
                SwitchListTile(
                  secondary: const Icon(TopicIcons.feed),
                  title: Text(l10n.feeds),
                  subtitle: Text(l10n.pushFeedsHelp),
                  value: prefs.feeds,
                  onChanged: (on) => setPushKind(ref, SettingKeys.notifyFeeds, on),
                ),
                SwitchListTile(
                  secondary: const Icon(TopicIcons.sleep),
                  title: Text(l10n.sleep),
                  subtitle: Text(l10n.pushSleepHelp),
                  value: prefs.sleep,
                  onChanged: (on) => setPushKind(ref, SettingKeys.notifySleep, on),
                ),
                SwitchListTile(
                  secondary: const Icon(TopicIcons.medicine),
                  title: Text(l10n.pushMedicines),
                  subtitle: Text(l10n.pushMedicinesHelp),
                  value: prefs.medicines,
                  onChanged: (on) => setPushKind(ref, SettingKeys.notifyMedicines, on),
                ),
                const Divider(height: 32),
                SwitchListTile(
                  secondary: const Icon(Icons.bedtime_off_outlined),
                  title: Text(l10n.quietHours),
                  subtitle: Text(
                    prefs.hasQuietHours
                        ? l10n.quietHoursOn(
                            PushPrefs.timeOf(prefs.quietFrom!).format(context),
                            PushPrefs.timeOf(prefs.quietTo!).format(context),
                          )
                        : l10n.quietHoursOff,
                  ),
                  value: prefs.hasQuietHours,
                  onChanged: (on) => on
                      ? setQuietHours(ref, PushPrefs.defaultQuietFrom, PushPrefs.defaultQuietTo)
                      : setQuietHours(ref, null, null),
                ),
                if (prefs.hasQuietHours) ...[
                  _TimeTile(
                    label: l10n.quietFrom,
                    minutes: prefs.quietFrom!,
                    onChanged: (m) => setQuietHours(ref, m, prefs.quietTo),
                  ),
                  _TimeTile(
                    label: l10n.quietTo,
                    minutes: prefs.quietTo!,
                    onChanged: (m) => setQuietHours(ref, prefs.quietFrom, m),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Text(
                    l10n.pushFooter,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.label, required this.minutes, required this.onChanged});

  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final time = PushPrefs.timeOf(minutes);
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
      title: Text(label),
      trailing: Text(time.format(context), style: Theme.of(context).textTheme.titleMedium),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked.hour * 60 + picked.minute);
      },
    );
  }
}

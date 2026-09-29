import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// Emergency numbers (tap to call), danger signs, and hot-weather /
/// load-shedding guidance for babies in Pakistan.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numbers = [
      ('1122', l10n.numRescue),
      ('115', l10n.numEdhi),
      ('1020', l10n.numChhipa),
      ('15', l10n.numPolice),
      ('16', l10n.numFire),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.callEmergencyWhen, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.emergencySigns),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.emergencyNumbers, style: theme.textTheme.titleMedium),
          Text(l10n.emergencyNumbersNote, style: theme.textTheme.bodySmall),
          for (final (number, name) in numbers)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(Icons.call, color: theme.colorScheme.onErrorContainer),
                ),
                // Phone numbers always read left to right.
                title: Text(number, textDirection: TextDirection.ltr, style: theme.textTheme.titleLarge),
                subtitle: Text(name),
                onTap: () => launchUrl(Uri(scheme: 'tel', path: number)),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.heatTitle, style: theme.textTheme.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.heatGuide),
                ],
              ),
            ),
          ),
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dehydrationTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.dehydrationSigns),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.helpSources, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

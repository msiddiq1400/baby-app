import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/countries.dart';
import '../../core/emergency.dart';
import '../../data/baby_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/country_picker.dart';

/// Danger signs, emergency numbers for the baby's country (tap to call), and
/// hot-weather / load-shedding guidance where it applies.
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final country = ref.watch(currentBabyProvider).value?.countryCode ?? defaultCountry;
    final countryText = countryLabel(context, country);
    final numbers = [
      for (final n in emergencyNumbers(country))
        (
          n.number,
          switch (n.service) {
            EmergencyService.all => l10n.numAll,
            EmergencyService.ambulance => l10n.numAmbulance,
            EmergencyService.rescue1122 => l10n.numRescue,
            EmergencyService.edhi => l10n.numEdhi,
            EmergencyService.chhipa => l10n.numChhipa,
            EmergencyService.police => l10n.numPolice,
            EmergencyService.fire => l10n.numFire,
            EmergencyService.nhs111 => l10n.numNhs111,
            EmergencyService.poison => l10n.numPoison,
            EmergencyService.nurseLine => l10n.numNurseLine,
            EmergencyService.unified => l10n.numUnified,
          },
        ),
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
          Text(l10n.emergencyNumbersIn(countryText), style: theme.textTheme.titleMedium),
          Text(numbers.isEmpty ? l10n.noEmergencyNumbers : l10n.emergencyNumbersNote, style: theme.textTheme.bodySmall),
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
                onTap: () => launchUrl(Uri(scheme: 'tel', path: number.replaceAll('-', ''))),
              ),
            ),
          const SizedBox(height: 16),
          if (heatAdviceCountries.contains(country))
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

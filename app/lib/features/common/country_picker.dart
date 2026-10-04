import 'package:flutter/material.dart';

import '../../core/countries.dart';
import '../../core/emergency.dart';
import '../../l10n/app_localizations.dart';

/// The country's name in the app's current language.
String countryLabel(BuildContext context, String code) {
  final locale = Localizations.localeOf(context);
  return countryName(code, locale.languageCode, scriptCode: locale.scriptCode);
}

/// The number to call in an emergency in [country], e.g. "999", or "your
/// local emergency number" when we don't know it.
String emergencyNumberText(BuildContext context, String country) =>
    primaryEmergencyNumber(country) ?? AppLocalizations.of(context).localEmergencyNumber;

/// Lets the user pick a country: the main ones first, then all, with search.
/// Returns the ISO code, or null if dismissed.
Future<String?> showCountryPicker(BuildContext context, {String? selected}) => showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CountrySheet(selected: selected),
    );

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({this.selected});

  final String? selected;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final searching = _query.trim().isNotEmpty;
    final matches = [for (final c in allCountries) if (countryMatches(c, _query)) c];

    Widget tile(String code) => ListTile(
          title: Text(countryLabel(context, code)),
          trailing: code == widget.selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
          onTap: () => Navigator.pop(context, code),
        );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchCountry,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom + 16),
              children: [
                if (!searching) ...[
                  for (final code in featuredCountries) tile(code),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(l10n.allCountries, style: theme.textTheme.titleSmall),
                  ),
                ],
                for (final code in matches) tile(code),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

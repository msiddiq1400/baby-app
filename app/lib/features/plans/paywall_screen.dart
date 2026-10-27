import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import 'plan.dart';
import 'store.dart';

/// Opens the Palna Pro screen; [reason] says what the person tried to do.
Future<void> showPaywall(BuildContext context, {String? reason}) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => PaywallScreen(reason: reason)));

/// True if the family has Pro; otherwise shows the Pro screen first and
/// says whether they have it now.
Future<bool> requirePro(BuildContext context, WidgetRef ref, String reason) async {
  if (ref.read(isProProvider)) return true;
  await showPaywall(context, reason: reason);
  return ref.read(isProProvider);
}

/// "Rs 10", "$0.10": the price per day, rounded to whole units when that's
/// at least 5 (so Rs 9.97 reads "Rs 10").
String pricePerDay(double price, String currencyCode, int days) {
  final perDay = price / days;
  return NumberFormat.simpleCurrency(name: currencyCode, decimalDigits: perDay >= 5 ? 0 : 2).format(perDay);
}

/// How much cheaper a year is than 12 months, in whole percent.
int yearlySaving(double monthly, double yearly) => monthly <= 0 ? 0 : ((1 - yearly / (monthly * 12)) * 100).round();

/// Free-trial length in days, or null if [product] has none.
int? trialDays(StoreProduct product) {
  final intro = product.introductoryPrice;
  if (intro == null || intro.price != 0) return null;
  final unit = switch (intro.periodUnit) {
    PeriodUnit.day => 1,
    PeriodUnit.week => 7,
    PeriodUnit.month => 30,
    PeriodUnit.year => 365,
    _ => 1,
  };
  return intro.periodNumberOfUnits * unit;
}

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.reason});

  final String? reason;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  late final _packages = ProStore.packages();
  var _yearly = true;
  var _busy = false;

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _done(bool pro, {required String notFound}) async {
    final l10n = AppLocalizations.of(context);
    if (!pro) {
      if (notFound.isNotEmpty) _snack(notFound);
      return;
    }
    ref.read(storeProProvider.notifier).set(true);
    await ProStore.tellServer(ref.read(supabaseProvider));
    if (!mounted) return;
    _snack(l10n.proThanks);
    Navigator.of(context).pop();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      debugPrint('Purchase: $e');
      if (mounted) _snack(AppLocalizations.of(context).proError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _manage() async {
    final url =
        await ProStore.managementUrl() ??
        (defaultTargetPlatform == TargetPlatform.iOS
            ? 'https://apps.apple.com/account/subscriptions'
            : 'https://play.google.com/store/account/subscriptions');
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPro = ref.watch(isProProvider);
    final until = ref.watch(proUntilProvider);
    final dates = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (widget.reason case final reason? when !isPro) ...[
              Text(reason, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
            ],
            if (isPro)
              Card(
                color: theme.colorScheme.primaryContainer,
                child: ListTile(
                  leading: Icon(Icons.workspace_premium, color: theme.colorScheme.onPrimaryContainer),
                  title: Text(l10n.proActive, style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                  subtitle: until == null
                      ? null
                      : Text(
                          l10n.proActiveUntil(dates.formatMediumDate(until.toLocal())),
                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                        ),
                ),
              ),
            const SizedBox(height: 8),
            Text(l10n.proIntro, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final (icon, text) in [
              (Icons.child_friendly_outlined, l10n.proFeatureBabies),
              (Icons.photo_library_outlined, l10n.proFeaturePhotos),
              (Icons.insert_chart_outlined, l10n.proFeatureReports),
              (Icons.palette_outlined, l10n.proFeatureThemes),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(text),
              ),
            Text(l10n.proFamilyNote, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            if (isPro)
              OutlinedButton(onPressed: _manage, child: Text(l10n.proManage))
            else
              FutureBuilder(
                future: _packages,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final p = snap.data;
                  if (p == null || (p.monthly == null && p.yearly == null)) {
                    return Text(l10n.proUnavailable, style: theme.textTheme.bodyMedium);
                  }
                  return _Choices(
                    monthly: p.monthly,
                    yearly: p.yearly,
                    yearlySelected: _yearly && p.yearly != null || p.monthly == null,
                    onSelect: (yearly) => setState(() => _yearly = yearly),
                    busy: _busy,
                    onBuy: (package) => _run(() async => _done(await ProStore.buy(package), notFound: '')),
                  );
                },
              ),
            const SizedBox(height: 8),
            if (ProStore.available && !isPro)
              Center(
                child: TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() async => _done(await ProStore.restore(), notFound: l10n.proRestoreNone)),
                  child: Text(l10n.proRestore),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              defaultTargetPlatform == TargetPlatform.iOS ? l10n.proLegalApple : l10n.proLegalGoogle,
              style: theme.textTheme.bodySmall,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () => launchUrl(Uri.parse('https://palnacare.com/terms/')),
                  child: Text(l10n.proTerms),
                ),
                TextButton(
                  onPressed: () => launchUrl(Uri.parse('https://palnacare.com/privacy/')),
                  child: Text(l10n.proPrivacy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The yearly (highlighted, with the free trial) and monthly options and the
/// buy button. The billed price is always the biggest text (store rules).
class _Choices extends StatelessWidget {
  const _Choices({
    required this.monthly,
    required this.yearly,
    required this.yearlySelected,
    required this.onSelect,
    required this.busy,
    required this.onBuy,
  });

  final Package? monthly;
  final Package? yearly;
  final bool yearlySelected;
  final ValueChanged<bool> onSelect;
  final bool busy;
  final ValueChanged<Package> onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = yearlySelected ? yearly! : monthly!;
    final trial = trialDays(selected.storeProduct);
    final saving = monthly != null && yearly != null
        ? yearlySaving(monthly!.storeProduct.price, yearly!.storeProduct.price)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (yearly case final y?)
          _Option(
            title: l10n.proYearly,
            price: l10n.proPricePerYear(y.storeProduct.priceString),
            perDay: l10n.proPricePerDay(pricePerDay(y.storeProduct.price, y.storeProduct.currencyCode, 365)),
            badges: [
              if (trialDays(y.storeProduct) case final days?) l10n.proTrialDays(days),
              if (saving > 0) l10n.proSave(saving),
            ],
            selected: yearlySelected,
            onTap: () => onSelect(true),
          ),
        if (monthly case final m?)
          _Option(
            title: l10n.proMonthly,
            price: l10n.proPricePerMonth(m.storeProduct.priceString),
            perDay: l10n.proPricePerDay(pricePerDay(m.storeProduct.price, m.storeProduct.currencyCode, 30)),
            badges: [if (trialDays(m.storeProduct) case final days?) l10n.proTrialDays(days)],
            selected: !yearlySelected,
            onTap: () => onSelect(false),
          ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: busy ? null : () => onBuy(selected),
          child: busy
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(trial != null ? l10n.proStartTrial : l10n.proSubscribe),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.price,
    required this.perDay,
    required this.badges,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String price;
  final String perDay;
  final List<String> badges;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall),
                        for (final b in badges)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              b,
                              style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(price, style: theme.textTheme.titleLarge),
                    Text(perDay, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

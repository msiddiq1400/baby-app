import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';

import '../../data/growth_repository.dart';
import '../../data/medication_repository.dart';
import '../../data/models.dart';
import '../../data/symptom_repository.dart';
import '../../data/tracking_repository.dart';
import '../../l10n/app_localizations.dart';
import 'doctor_summary.dart';
import 'summary_pdf.dart';

/// Everything the summary needs for a period starting at `from` (the key is
/// (baby id, from)). Feeds and diapers include the 7 days before, for "usually".
final _summaryDataProvider = FutureProvider.autoDispose.family<DoctorSummaryInput Function(Baby), (String, DateTime)>(
  (ref, key) async {
    final (babyId, from) = key;
    final baselineFrom = DateTime(from.year, from.month, from.day - 7);
    final (feeds, diapers) = await ref.read(trackingRepositoryProvider).feedsAndDiapersSince(babyId, baselineFrom);
    final symptoms = await ref.read(symptomRepositoryProvider).since(babyId, from);
    final medications = await ref.read(medicationRepositoryProvider).all(babyId);
    final doses = await ref.read(medicationRepositoryProvider).dosesSince(babyId, from);
    final growth = await ref.read(growthRepositoryProvider).all(babyId);
    final latestWeight = growth.where((g) => g.weightG != null).lastOrNull;

    return (baby) => DoctorSummaryInput(
          baby: baby,
          now: DateTime.now(),
          from: from,
          symptoms: symptoms,
          feeds: feeds,
          diapers: diapers,
          medications: medications,
          doses: doses,
          latestWeight: latestWeight,
        );
  },
);

class DoctorSummaryScreen extends ConsumerStatefulWidget {
  const DoctorSummaryScreen({super.key, required this.baby, required this.recentSymptoms});

  final Baby baby;

  /// Last 14 days, used to find when the current symptoms started.
  final List<SymptomLog> recentSymptoms;

  @override
  ConsumerState<DoctorSummaryScreen> createState() => _DoctorSummaryScreenState();
}

class _DoctorSummaryScreenState extends ConsumerState<DoctorSummaryScreen> {
  /// null = since the earliest symptom in the last 14 days.
  int? _days;
  var _english = true;
  var _makingPdf = false;

  /// Shares the summary as a PDF. The PDF is always in English (for the
  /// doctor; the PDF library can't lay out Nastaliq Urdu).
  Future<void> _sharePdf(DoctorSummaryInput input) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _makingPdf = true);
    try {
      final en = lookupAppLocalizations(const Locale('en'));
      final bytes = await buildSummaryPdf(
        buildDoctorSummary(input, en),
        fonts: await SummaryPdfFonts.load(),
        generatedOn: DateFormat('d MMM yyyy, h:mm a', 'en').format(DateTime.now()),
      );
      final name = 'Palna summary - ${widget.baby.name}.pdf';
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: name)],
          fileNameOverrides: [name],
          subject: en.sumTitle(widget.baby.name),
        ),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _makingPdf = false);
    }
  }

  DateTime get _from {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_days != null || widget.recentSymptoms.isEmpty) {
      return DateTime(today.year, today.month, today.day - ((_days ?? 3) - 1));
    }
    final first = widget.recentSymptoms.map((s) => s.occurredAt).reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime(first.year, first.month, first.day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEnglishApp = l10n.localeName == 'en';
    final textL10n = _english || isEnglishApp ? lookupAppLocalizations(const Locale('en')) : l10n;
    final data = ref.watch(_summaryDataProvider((widget.baby.id, _from)));
    final text = data.whenOrNull(data: (input) => buildDoctorSummary(input(widget.baby), textL10n));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorSummary)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              if (widget.recentSymptoms.isNotEmpty)
                ChoiceChip(
                  label: Text(l10n.summarySinceStart),
                  selected: _days == null,
                  onSelected: (_) => setState(() => _days = null),
                ),
              for (final days in const [3, 7, 14])
                ChoiceChip(
                  label: Text(l10n.lastNDays(days)),
                  selected: _days == days || (_days == null && widget.recentSymptoms.isEmpty && days == 3),
                  onSelected: (_) => setState(() => _days = days),
                ),
            ],
          ),
          if (!isEnglishApp)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.showInEnglish),
              value: _english,
              onChanged: (v) => setState(() => _english = v),
            ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: switch (data) {
                AsyncError() => Text(l10n.errorGeneric),
                _ when text == null => const Center(child: CircularProgressIndicator()),
                // English summaries read left to right even in the Urdu app.
                _ => Directionality(
                    textDirection: textL10n.localeName == 'ur' ? TextDirection.rtl : TextDirection.ltr,
                    child: SelectableText(text),
                  ),
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              IconButton.outlined(
                tooltip: l10n.copyButton,
                onPressed: text == null
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: text));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.copied)));
                        }
                      },
                icon: const Icon(Icons.copy),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: text == null || _makingPdf ? null : () => _sharePdf(data.value!(widget.baby)),
                  icon: _makingPdf
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(l10n.pdfButton),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: text == null
                      ? null
                      : () => SharePlus.instance.share(
                            ShareParams(text: text, subject: textL10n.sumTitle(widget.baby.name)),
                          ),
                  icon: const Icon(Icons.share),
                  label: Text(l10n.shareButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

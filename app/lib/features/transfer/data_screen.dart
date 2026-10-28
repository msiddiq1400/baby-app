import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';

import '../../core/l10n_lookup.dart';
import '../../data/baby_repository.dart';
import '../../data/local_db.dart';
import '../../data/models.dart';
import '../../data/tracking_repository.dart' show todayLogProvider;
import '../../l10n/app_localizations.dart';
import 'export.dart';
import 'import_model.dart';
import 'import_writer.dart';
import 'importers.dart';

/// Settings > Your data: export the baby's log as CSV, or bring in a log
/// from another app (Nara Baby, Huckleberry) or an earlier Palna export.
/// Both are free.
class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final baby = ref.watch(currentBabyProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataTitle)),
      body: baby == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.exportTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.exportHelp(baby.name)),
                const SizedBox(height: 12),
                _ExportButton(baby: baby),
                const Divider(height: 40),
                Text(l10n.importTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.importHelp(baby.name)),
                const SizedBox(height: 8),
                for (final source in ImportSource.values)
                  Card(
                    child: ListTile(
                      title: Text(importSourceName(l10n, source)),
                      subtitle: Text(importSourceSteps(l10n, source)),
                      isThreeLine: true,
                      trailing: const Icon(Icons.upload_file_outlined),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => ImportScreen(baby: baby, source: source)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

String importSourceName(AppLocalizations l10n, ImportSource source) => switch (source) {
  ImportSource.nara => 'Nara Baby',
  ImportSource.huckleberry => 'Huckleberry',
  ImportSource.palna => l10n.importFromPalna,
};

/// How to get the file out of the other app.
String importSourceSteps(AppLocalizations l10n, ImportSource source) => switch (source) {
  ImportSource.nara => l10n.importStepsNara,
  ImportSource.huckleberry => l10n.importStepsHuckleberry,
  ImportSource.palna => l10n.importStepsPalna,
};

class _ExportButton extends ConsumerStatefulWidget {
  const _ExportButton({required this.baby});

  final Baby baby;

  @override
  ConsumerState<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends ConsumerState<_ExportButton> {
  var _busy = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final text = await exportCsv(ref.read(powerSyncProvider), widget.baby);
      final name = exportFileName(widget.baby, DateTime.now());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(utf8.encode(text), mimeType: 'text/csv', name: name)],
          fileNameOverrides: [name],
          subject: l10n.exportSubject(widget.baby.name),
        ),
      );
    } catch (e) {
      debugPrint('Export: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilledButton.icon(
      onPressed: _busy ? null : _export,
      icon: _busy
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.ios_share),
      label: Text(l10n.exportButton),
    );
  }
}

/// Reads [text] as a file from [source]. If the file is clearly from
/// another app this knows, reads it as that one instead.
ImportResult readImportFile(String text, ImportSource source) {
  final detected = detectSource(text);
  return switch (detected ?? source) {
    ImportSource.nara => importNara(text),
    ImportSource.huckleberry => importHuckleberry(text),
    ImportSource.palna => importPalna(text),
  };
}

/// Picks the file, shows what's in it, and imports on the parent's OK.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key, required this.baby, required this.source, this.pickFile});

  final Baby baby;
  final ImportSource source;

  /// The file's text, or null if none was chosen (tests replace the picker).
  final Future<String?> Function()? pickFile;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportResult? _result;
  String? _error;
  var _reading = false;
  int? _done; // entries written so far, while importing
  ImportCounts? _counts; // when finished

  static Future<String?> _pick() async {
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    // Some exports aren't valid UTF-8 everywhere (e.g. a stray byte in a
    // note); read them anyway.
    return utf8.decode(await file.xFile.readAsBytes(), allowMalformed: true);
  }

  Future<void> _choose() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final text = await (widget.pickFile ?? _pick)();
      if (text == null) return;
      final result = readImportFile(text, widget.source);
      setState(() => _result = result);
      if (result.entries.isEmpty) setState(() => _error = l10n.importNothingFound);
    } on ImportFormatException catch (e) {
      setState(() => _error = e.message.contains('Excel') ? l10n.importExcelMangled : l10n.importWrongFile);
    } catch (e) {
      debugPrint('Import read: $e');
      setState(() => _error = l10n.importWrongFile);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _import(ImportResult result) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _done = 0);
    try {
      final counts = await writeImport(
        ref.read(powerSyncProvider),
        widget.baby,
        result.entries,
        onProgress: (done) {
          if (mounted) setState(() => _done = done);
        },
      );
      ref.invalidate(todayLogProvider(widget.baby.id));
      if (mounted) setState(() => _counts = counts);
    } catch (e) {
      debugPrint('Import write: $e');
      if (mounted) {
        setState(() => _done = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final result = _result;
    final counts = _counts;

    return Scaffold(
      appBar: AppBar(title: Text(importSourceName(l10n, widget.source))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (counts != null) ...[
            Icon(Icons.check_circle_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(l10n.importDone(counts.added, widget.baby.name), style: theme.textTheme.titleMedium),
            if (counts.duplicates > 0) Text(l10n.importDuplicates(counts.duplicates)),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.doneButton)),
          ] else if (_done != null) ...[
            LinearProgressIndicator(value: result == null ? null : _done! / result.entries.length.clamp(1, 1 << 30)),
            const SizedBox(height: 12),
            Text(l10n.importWorking),
          ] else ...[
            Text(importSourceSteps(l10n, widget.source)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _reading ? null : _choose,
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(result == null ? l10n.importChooseFile : l10n.importChooseAnother),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: 12),
              Text(error, style: TextStyle(color: theme.colorScheme.error)),
            ],
            if (result != null && result.entries.isNotEmpty) ...[
              const SizedBox(height: 20),
              _Preview(result: result, baby: widget.baby),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _import(result),
                child: Text(l10n.importButton(result.entries.length, widget.baby.name)),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// What the file holds: counts per kind, the dates it covers, and what
/// will be left out.
class _Preview extends StatelessWidget {
  const _Preview({required this.result, required this.baby});

  final ImportResult result;
  final Baby baby;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final byKind = <String, int>{};
    for (final e in result.entries) {
      final kind = switch (e) {
        ImportedFeed() => l10n.feeds,
        ImportedPumping() => l10n.pumpingEntry,
        ImportedDiaper() => l10n.diapers,
        ImportedSleep() => l10n.sleep,
        ImportedActivity() => l10n.activities,
        ImportedGrowth() => l10n.tabGrowth,
        ImportedTemperature() => l10n.importTemperatures,
      };
      byKind[kind] = (byKind[kind] ?? 0) + 1;
    }
    final times = result.entries.map((e) => e.at).toList()..sort();
    final dates = DateFormat.yMMMd(dateLocale(l10n));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.babyName case final name? when name.trim().isNotEmpty)
              Text(l10n.importFileBaby(name), style: theme.textTheme.titleSmall),
            Text(l10n.importDates(dates.format(times.first), dates.format(times.last))),
            const SizedBox(height: 8),
            for (final MapEntry(:key, :value) in byKind.entries) Text('$key: $value'),
            if (result.skipped.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(l10n.importSkippedTitle(result.skippedCount), style: theme.textTheme.titleSmall),
              for (final MapEntry(:key, :value) in result.skipped.entries)
                Text('${skipReasonText(l10n, key)}: $value', style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Text(l10n.importIntoBaby(baby.name), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// The importers' skip reasons in the app's language (unknown ones as is).
String skipReasonText(AppLocalizations l10n, String reason) => switch (reason) {
  SkipReason.medicine => l10n.importSkipMedicine,
  SkipReason.solidFood => l10n.importSkipSolids,
  SkipReason.milestone => l10n.importSkipMilestone,
  SkipReason.vaccine => l10n.importSkipVaccine,
  SkipReason.dryDiaper => l10n.importSkipDry,
  SkipReason.sleepGoing => l10n.importSkipSleepGoing,
  SkipReason.outOfRange => l10n.importSkipRange,
  SkipReason.unreadable => l10n.importSkipUnreadable,
  _ => reason,
};

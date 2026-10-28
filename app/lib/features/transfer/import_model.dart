// What an import produces, whatever app the file came from: entries ready
// to be written for one baby, plus what was left out and why. The importers
// (importers.dart) only parse; import_writer.dart checks for duplicates and
// writes.
//
// Every value here must already satisfy the server's rules (see the check
// constraints in supabase/migrations): the server rejects a bad row, and a
// rejected row takes the rest of its upload batch with it.

import '../../data/models.dart';

/// Where an import file came from.
enum ImportSource { nara, huckleberry, palna }

sealed class ImportedEntry {
  const ImportedEntry(this.at);

  /// When it happened (local time); also used to find duplicates.
  final DateTime at;
}

class ImportedFeed extends ImportedEntry {
  const ImportedFeed({
    required this.type,
    required DateTime startedAt,
    this.endedAt,
    this.amountMl,
    this.leftSeconds,
    this.rightSeconds,
    this.notes,
  }) : super(startedAt);

  /// breast, bottleBreastMilk or bottleFormula (never solids).
  final FeedType type;
  DateTime get startedAt => at;
  final DateTime? endedAt;

  /// Bottles: 0..1000.
  final int? amountMl;

  /// Breastfeeds: seconds on each side (>= 0).
  final int? leftSeconds;
  final int? rightSeconds;
  final String? notes;
}

class ImportedPumping extends ImportedEntry {
  const ImportedPumping({required DateTime startedAt, this.endedAt, this.amountMl, this.side, this.notes})
      : super(startedAt);

  DateTime get startedAt => at;
  final DateTime? endedAt;

  /// 0..1000.
  final int? amountMl;
  final BreastSide? side;
  final String? notes;
}

class ImportedDiaper extends ImportedEntry {
  const ImportedDiaper({required DateTime at, required this.wet, required this.dirty, this.notes}) : super(at);

  /// At least one of [wet] and [dirty] (dry diapers are skipped).
  final bool wet;
  final bool dirty;
  final String? notes;
}

class ImportedSleep extends ImportedEntry {
  const ImportedSleep({required DateTime startedAt, required this.endedAt, this.kind, this.notes}) : super(startedAt);

  DateTime get startedAt => at;

  /// Always set (a sleep still going in another app isn't imported).
  final DateTime endedAt;

  /// Null: nap or night from the start time.
  final SleepKind? kind;
  final String? notes;
}

class ImportedActivity extends ImportedEntry {
  const ImportedActivity({required this.kind, required DateTime startedAt, this.endedAt, this.label, this.notes})
      : super(startedAt);

  final ActivityKind kind;
  DateTime get startedAt => at;

  /// Null: no duration (stored as ended_at = started_at).
  final DateTime? endedAt;

  /// For [ActivityKind.other]: up to 60 characters.
  final String? label;
  final String? notes;
}

class ImportedGrowth extends ImportedEntry {
  const ImportedGrowth({required DateTime on, this.weightG, this.lengthMm, this.headMm}) : super(on);

  /// The date (time of day ignored).
  DateTime get on => at;

  /// 300..40000, 200..1300, 200..600; at least one set.
  final int? weightG;
  final int? lengthMm;
  final int? headMm;
}

/// A temperature reading, saved as a symptom ("fever" from 38 °C, otherwise
/// "other").
class ImportedTemperature extends ImportedEntry {
  const ImportedTemperature({required DateTime at, required this.celsius, this.notes}) : super(at);

  /// 30..45, one decimal.
  final double celsius;
  final String? notes;
}

/// The result of reading a file.
class ImportResult {
  const ImportResult({required this.entries, this.skipped = const {}, this.babyName});

  final List<ImportedEntry> entries;

  /// Rows not imported, counted by reason, e.g. {'Medicine': 12,
  /// 'Unreadable row': 2}. Shown to the parent before importing.
  final Map<String, int> skipped;

  /// The baby's name in the file, if it says.
  final String? babyName;

  int get skippedCount => skipped.values.fold(0, (a, b) => a + b);
}

/// Thrown when the file isn't the expected kind at all (wrong app, or
/// opened and re-saved in Excel so the times were mangled).
class ImportFormatException implements Exception {
  const ImportFormatException(this.message);

  final String message;

  @override
  String toString() => 'ImportFormatException: $message';
}

/// Palna's own export (export.dart writes it; the Palna importer reads it).
/// One row per entry; times are local, with the exact UTC time at the end.
abstract final class PalnaCsv {
  static const baby = 'Baby';
  static const type = 'Type';
  static const subtype = 'Subtype';
  static const label = 'Label';
  static const start = 'Start';
  static const end = 'End';
  static const minutes = 'Duration (min)';
  static const amount = 'Amount';
  static const unit = 'Unit';
  static const leftSeconds = 'Left (sec)';
  static const rightSeconds = 'Right (sec)';
  static const notes = 'Notes';
  static const startUtc = 'Start (UTC)';
  static const endUtc = 'End (UTC)';

  static const header = [
    baby,
    type,
    subtype,
    label,
    start,
    end,
    minutes,
    amount,
    unit,
    leftSeconds,
    rightSeconds,
    notes,
    startUtc,
    endUtc,
  ];

  // Type values.
  static const feed = 'Feed'; // subtype: breast | bottle_breast_milk | bottle_formula; amount ml
  static const pumping = 'Pumping'; // subtype: left | right | both | ''; amount ml
  static const diaper = 'Diaper'; // subtype: wet | dirty | both
  static const sleep = 'Sleep'; // subtype: nap | night
  static const activity = 'Activity'; // subtype: ActivityKind.dbValue; label for "other"
  static const growth = 'Growth'; // subtype: weight (kg) | length (cm) | head (cm); start = date
  static const symptom = 'Symptom'; // subtype: symptom code; amount = temperature °C if any
  static const medicine = 'Medicine'; // subtype: medicine name; label: given | skipped
  static const vaccine = 'Vaccine'; // subtype: vaccine code; label: name; start = date
  static const doctorVisit = 'Doctor visit'; // label: doctor; notes: diagnosis / advice
  static const food = 'Food'; // subtype: food id; label: opinion / reaction; start = date
  static const milestone = 'Milestone'; // subtype: milestone id; start = date
}

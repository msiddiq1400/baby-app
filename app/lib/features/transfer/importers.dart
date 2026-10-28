// Importers for other baby apps' CSV exports (Nara Baby, Huckleberry) and
// for Palna's own export. They only parse; import_writer.dart writes.
//
// A row Palna can't keep, or with a value the server would reject, is left
// out and counted by reason (a rejected row would take the rest of its
// upload batch with it). Nothing is clamped.

import '../../data/models.dart';
import 'csv.dart';
import 'import_model.dart';

/// Why rows were left out: the keys of [ImportResult.skipped]. Kept stable
/// so the app can translate them.
abstract final class SkipReason {
  static const medicine = 'Medicine';
  static const solidFood = 'Solid food';
  static const milestone = 'Milestone';
  static const vaccine = 'Vaccine';
  static const doctorVisit = 'Doctor visit';
  static const dryDiaper = 'Dry diaper';
  static const sleepGoing = 'Sleep still going';
  static const outOfRange = 'Out-of-range value';
  static const unreadable = 'Unreadable row';

  /// "Other: Potty" and so on, for entry types Palna doesn't keep.
  static const otherPrefix = 'Other: ';

  static String other(String type) => '$otherPrefix${_cap(type, 40)}';
}

/// Which app [csvText] came from, by its header; null if none of them.
ImportSource? detectSource(String csvText) {
  final lineEnd = csvText.indexOf('\n');
  final table = CsvTable(parseCsv(lineEnd < 0 ? csvText : csvText.substring(0, lineEnd)));
  if (_isPalna(table)) return ImportSource.palna;
  if (_isNara(table)) return ImportSource.nara;
  if (_isHuckleberry(table)) return ImportSource.huckleberry;
  return null;
}

bool _isPalna(CsvTable t) => t.has(PalnaCsv.type) && t.has(PalnaCsv.subtype) && t.has(PalnaCsv.startUtc);

bool _isNara(CsvTable t) => t.has('Type') && (t.has('Start Date/time (Epoch)') || t.has('Start Date/time'));

bool _isHuckleberry(CsvTable t) =>
    const ['Type', 'Start', 'End', 'Duration', 'Start Condition', 'Start Location', 'End Condition'].every(t.has);

// ---------------------------------------------------------------- Nara Baby

/// A Nara Baby export: one CSV per child, one wide table where each row's
/// `Type` says which `[Type] …` columns are filled. Times come from the
/// epoch-millisecond columns.
ImportResult importNara(String csvText) {
  final t = CsvTable.parse(csvText);
  if (!_isNara(t)) throw const ImportFormatException('Not a Nara Baby export');

  // Excel rewrites epochs as 1.78998E+12, which loses up to ±83 minutes in
  // every row: refuse the whole file.
  final epochColumns = [
    for (final h in t.header)
      if (h.toLowerCase().endsWith('(epoch)')) h,
  ];
  for (final row in t.rows) {
    for (final c in epochColumns) {
      final v = t.get(row, c);
      // Fractional milliseconds ("1789977600000.0") are fine; scientific
      // notation means Excel.
      if (v != null && v.contains(RegExp('[eE]'))) throw const ImportFormatException('re-saved in Excel');
    }
  }

  final out = _Collector();
  final pumpKeys = <String>{};
  String? profileName, anyName;
  for (final row in t.rows) {
    final type = t.get(row, 'Type');
    if (type == null) continue;
    final lower = type.toLowerCase();
    // The parent's own entries, not the baby's.
    if (lower.startsWith('postpartum')) continue;
    if (lower == 'profile') {
      profileName ??= t.get(row, 'Profile Name');
      continue;
    }
    if (lower == 'pump') {
      // Pumping is family-wide; the writer dedupes across files, here only
      // repeats within this one.
      final key = t.get(row, '_activityKey');
      if (key != null && !pumpKeys.add(key)) continue;
    } else {
      anyName ??= t.get(row, 'Profile Name');
    }
    out.row(() => _naraRow(t, row, type, out));
  }
  return out.result(profileName ?? anyName);
}

List<ImportedEntry> _naraRow(CsvTable t, List<String> row, String type, _Collector out) {
  String? get(String column) => t.get(row, column);
  // The epoch is the instant; the local column (device time) is a fallback.
  DateTime? time(String column) => _epoch(get('$column (Epoch)')) ?? _localTime(get(column));

  final lower = type.toLowerCase();
  switch (lower) {
    case 'solid feed':
      throw const _Skip(SkipReason.solidFood);
    case 'milestone' || 'baby first':
      throw const _Skip(SkipReason.milestone);
    case 'vaccine':
      throw const _Skip(SkipReason.vaccine);
  }
  final start = time('Start Date/time') ?? (throw _unreadable);
  final notes = _notes(get('Note'));

  // End of a Pump or Sleep: its end time, else start + duration.
  DateTime? end(String group) {
    final at = time('[$group] End Date/time');
    if (at != null) return at;
    final seconds = _seconds(get('[$group] Duration (Seconds)'));
    return seconds == null ? null : start.add(Duration(seconds: seconds));
  }

  switch (lower) {
    case 'breastfeed':
      return [_naraBreast(get, 'Breastfeed', start, notes, always: true)!];
    case 'bottle feed':
      return _naraBottle(get, 'Bottle Feed', start, notes);
    case 'combo feed':
      final breast = _naraBreast(get, 'Combo Feed', start, notes, always: false);
      final bottles = _naraHasBottle(get, 'Combo Feed') ? _naraBottle(get, 'Combo Feed', start, notes) : const [];
      if (breast == null && bottles.isEmpty) throw _unreadable;
      return [?breast, ...bottles];
    case 'pump':
      int? volume(String column) => _naraMl(get, '[Pump] $column');
      final left = volume('Left Volume'), right = volume('Right Volume');
      final total = volume('Total Volume') ?? (left == null && right == null ? null : _ml((left ?? 0) + (right ?? 0)));
      final l = (left ?? 0) > 0, r = (right ?? 0) > 0;
      return [
        ImportedPumping(
          startedAt: start,
          endedAt: end('Pump'),
          amountMl: total,
          side: l && r ? BreastSide.both : (l ? BreastSide.left : (r ? BreastSide.right : null)),
          notes: notes,
        ),
      ];
    case 'sleep':
      final endedAt = end('Sleep') ?? (throw const _Skip(SkipReason.sleepGoing));
      return [ImportedSleep(startedAt: start, endedAt: endedAt, notes: notes)];
    case 'diaper':
      final kind = get('[Diaper] Type')?.toLowerCase() ?? '';
      final both = kind.contains('mixed') || kind.contains('both');
      final wet = both || kind.contains('wet'), dirty = both || kind.contains('dirty');
      if (!wet && !dirty) throw kind.contains('dry') ? const _Skip(SkipReason.dryDiaper) : _unreadable;
      return [ImportedDiaper(at: start, wet: wet, dirty: dirty, notes: notes)];
    case 'growth':
      int? measure(String column, int Function(double, String?) convert) {
        final v = _num(get('[Growth] $column'));
        return v == null ? null : convert(v, get('[Growth] $column Unit'));
      }
      // The date as the family saw it (the row's own time zone), if readable.
      final on = _tryLocalTime(get('Start Date/time')) ?? start;
      return [_growth(on, measure('Weight', _grams), measure('Height', _mm), measure('Head Size', _mm))];
    case 'medical':
      final medicine = get('[Medical] Medication') != null;
      if (medicine) out.skip(SkipReason.medicine);
      final temperature = _num(get('[Medical] Temperature'));
      if (temperature == null) {
        if (medicine) return const [];
        throw _Skip(SkipReason.other(type));
      }
      final celsius = _celsius(temperature, get('[Medical] Temperature Unit'));
      return [ImportedTemperature(at: start, celsius: celsius, notes: notes)];
    case 'routine':
      final text = get('[Routine] Routine') ?? (throw _unreadable);
      final kind = _routineKind(text);
      return [
        ImportedActivity(
          kind: kind,
          startedAt: start,
          label: kind == ActivityKind.other ? _cap(text, 60) : null,
          notes: notes,
        ),
      ];
  }
  throw _Skip(SkipReason.other(type));
}

/// A breastfeed, or the breast part of a combo feed. Without durations it
/// keeps the side it began on, as 0 seconds on that side. Null when nothing
/// was recorded and [always] is false.
ImportedFeed? _naraBreast(
  String? Function(String) get,
  String group,
  DateTime start,
  String? notes, {
  required bool always,
}) {
  final left = _seconds(get('[$group] Left Duration (Seconds)')) ?? 0;
  final right = _seconds(get('[$group] Right Duration (Seconds)')) ?? 0;
  if (left + right > 0) {
    return ImportedFeed(
      type: FeedType.breast,
      startedAt: start,
      endedAt: start.add(Duration(seconds: left + right)),
      leftSeconds: left > 0 ? left : null,
      rightSeconds: right > 0 ? right : null,
      notes: notes,
    );
  }
  final side = _naraSide(get('[$group] Begin Side')) ?? _naraSide(get('[$group] End Side'));
  if (side == null && !always) return null;
  return ImportedFeed(
    type: FeedType.breast,
    startedAt: start,
    leftSeconds: side == BreastSide.left || side == BreastSide.both ? 0 : null,
    rightSeconds: side == BreastSide.right || side == BreastSide.both ? 0 : null,
    notes: notes,
  );
}

/// LEFT, RIGHT or BOTH, maybe with ".nonTimer" (a side entered by hand).
BreastSide? _naraSide(String? value) {
  final v = value?.toLowerCase();
  return switch (v?.endsWith('.nontimer') ?? false ? v!.substring(0, v.length - 9) : v) {
    'left' => BreastSide.left,
    'right' => BreastSide.right,
    'both' => BreastSide.both,
    _ => null,
  };
}

bool _naraHasBottle(String? Function(String) get, String group) => const [
  'Type',
  'Breast Milk Volume',
  'Formula Volume',
  'Volume',
  'Formula Name',
].any((c) => get('[$group] $c') != null);

/// A bottle: one feed per milk type when both shares are given; otherwise
/// one feed (a mixed bottle with only a total counts as formula).
List<ImportedFeed> _naraBottle(String? Function(String) get, String group, DateTime start, String? notes) {
  final breastMilk = _naraMl(get, '[$group] Breast Milk Volume');
  final formula = _naraMl(get, '[$group] Formula Volume');
  final total = _naraMl(get, '[$group] Volume');
  ImportedFeed feed(FeedType type, int? ml) => ImportedFeed(type: type, startedAt: start, amountMl: ml, notes: notes);

  final parts = [
    if ((breastMilk ?? 0) > 0) feed(FeedType.bottleBreastMilk, breastMilk),
    if ((formula ?? 0) > 0) feed(FeedType.bottleFormula, formula),
  ];
  if (parts.isNotEmpty) return parts;
  final kind = get('[$group] Type')?.toLowerCase() ?? '';
  final milkOnly = kind.contains('breast') && !kind.contains('formula');
  return [feed(milkOnly ? FeedType.bottleBreastMilk : FeedType.bottleFormula, total ?? breastMilk ?? formula)];
}

/// A volume column with its "… Unit" column, in ml.
int? _naraMl(String? Function(String) get, String column) {
  final v = _num(get(column));
  return v == null ? null : _toMl(v, get('$column Unit'));
}

/// Nara's free-text routine, e.g. "Bath", "Tummy Time", "Story time".
ActivityKind _routineKind(String text) {
  final t = text.toLowerCase();
  bool any(List<String> words) => words.any(t.contains);
  if (t.contains('bath')) return ActivityKind.bath;
  if (t.contains('tummy')) return ActivityKind.tummyTime;
  if (any(const ['story', 'read', 'book'])) return ActivityKind.reading;
  if (t.contains('massage')) return ActivityKind.massage;
  if (any(const ['walk', 'outside', 'outdoor', 'stroll'])) return ActivityKind.outdoors;
  if (t.contains('play')) return ActivityKind.play;
  return ActivityKind.other;
}

DateTime? _epoch(String? value) {
  if (value == null) return null;
  final ms = int.tryParse(value) ?? double.tryParse(value)?.round();
  if (ms == null || ms.abs() > 8640000000000000) throw _unreadable;
  return DateTime.fromMillisecondsSinceEpoch(ms);
}

// -------------------------------------------------------------- Huckleberry

/// A Huckleberry export: one row per entry, newest first, local times with
/// no zone.
ImportResult importHuckleberry(String csvText) {
  final t = CsvTable.parse(csvText);
  if (!_isHuckleberry(t)) throw const ImportFormatException('Not a Huckleberry export');
  final out = _Collector();
  for (final row in t.rows) {
    out.row(() => _huckleberryRow(t, row));
  }
  return out.result();
}

/// A breast side time, e.g. "00:07R" (HH:MM, then the side).
final _huckleberrySide = RegExp(r'(\d+):(\d{2})\s*([LR])', caseSensitive: false);

List<ImportedEntry> _huckleberryRow(CsvTable t, List<String> row) {
  String? get(String column) => t.get(row, column);
  final type = get('Type') ?? (throw _unreadable);
  final lower = type.toLowerCase();
  switch (lower) {
    case 'meds':
      throw const _Skip(SkipReason.medicine);
    case 'solids':
      throw const _Skip(SkipReason.solidFood);
  }
  final start = _localTime(get('Start')) ?? (throw _unreadable);
  final end = _localTime(get('End'));
  final notes = _notes(get('Notes'));

  switch (lower) {
    case 'feed':
      switch (get('Start Location')?.toLowerCase()) {
        case 'bottle':
          // Formula, Breast Milk or Cow Milk (kept as formula); End Condition
          // is the amount.
          final milk = get('Start Condition')?.toLowerCase();
          return [
            ImportedFeed(
              type: milk == 'breast milk' ? FeedType.bottleBreastMilk : FeedType.bottleFormula,
              startedAt: start,
              endedAt: end,
              amountMl: _huckleberryMeasure(get('End Condition'), _toMl),
              notes: notes,
            ),
          ];
        case 'breast':
          // Side times can be in either condition column: go by the suffix.
          var left = 0, right = 0;
          final sides = '${get('Start Condition') ?? ''} ${get('End Condition') ?? ''}';
          for (final m in _huckleberrySide.allMatches(sides)) {
            final seconds = (int.parse(m[1]!) * 60 + int.parse(m[2]!)) * 60;
            if (m[3]!.toUpperCase() == 'L') {
              left += seconds;
            } else {
              right += seconds;
            }
          }
          return [
            ImportedFeed(
              type: FeedType.breast,
              startedAt: start,
              endedAt: end ?? (left + right > 0 ? start.add(Duration(seconds: left + right)) : null),
              leftSeconds: left > 0 ? left : null,
              rightSeconds: right > 0 ? right : null,
              notes: notes,
            ),
          ];
      }
      throw _unreadable;
    case 'sleep':
      if (end == null) throw const _Skip(SkipReason.sleepGoing);
      return [ImportedSleep(startedAt: start, endedAt: end, notes: notes)];
    case 'diaper':
      // "Pee", "Poo:medium", "Both, pee:medium poo:small", "Dry".
      final first = RegExp('[a-z]+').firstMatch(get('End Condition')?.toLowerCase() ?? '')?[0];
      final (wet, dirty) = switch (first) {
        'pee' => (true, false),
        'poo' => (false, true),
        'both' => (true, true),
        'dry' => throw const _Skip(SkipReason.dryDiaper),
        _ => throw _unreadable,
      };
      return [ImportedDiaper(at: start, wet: wet, dirty: dirty, notes: notes)];
    case 'pump':
      // Two amounts (reportedly left and right): the total is their sum.
      final a = _huckleberryMeasure(get('Start Condition'), _toMl);
      final b = _huckleberryMeasure(get('End Condition'), _toMl);
      return [
        ImportedPumping(
          startedAt: start,
          endedAt: end,
          amountMl: a == null && b == null ? null : _ml((a ?? 0) + (b ?? 0)),
          side: a != null && b != null ? BreastSide.both : null,
          notes: notes,
        ),
      ];
    case 'growth':
      return [
        _growth(
          start,
          _huckleberryMeasure(get('Start Condition'), _grams),
          _huckleberryMeasure(get('Start Location'), _mm),
          _huckleberryMeasure(get('End Condition'), _mm),
        ),
      ];
    case 'tummy time':
      return [ImportedActivity(kind: ActivityKind.tummyTime, startedAt: start, endedAt: end, notes: notes)];
    case 'bath':
      return [ImportedActivity(kind: ActivityKind.bath, startedAt: start, endedAt: end, notes: notes)];
  }
  throw _Skip(SkipReason.other(type));
}

/// A number with its unit stuck on: "140ml", "4.5oz", "8.82kg", "18.31lbs.oz"
/// (decimal pounds), "2.46ft.in" (decimal feet).
final _huckleberryValue = RegExp(r'^(\d+(?:[.,]\d+)?)\s*([a-z]+(?:\.[a-z]+)?)$', caseSensitive: false);

int? _huckleberryMeasure(String? value, int Function(double, String?) convert) {
  if (value == null) return null;
  final m = _huckleberryValue.firstMatch(value) ?? (throw _unreadable);
  return convert(_num(m[1])!, m[2]);
}

// -------------------------------------------------------------------- Palna

/// Palna's own export (export.dart). Times come from the UTC columns.
ImportResult importPalna(String csvText) {
  final t = CsvTable.parse(csvText);
  if (!_isPalna(t)) throw const ImportFormatException('Not a Palna export');
  final out = _Collector();
  final growth = <_GrowthDay>[];
  String? babyName;
  for (final row in t.rows) {
    babyName ??= t.get(row, PalnaCsv.baby);
    out.row(() => _palnaRow(t, row, growth));
  }
  for (final g in growth) {
    out.row(() => [_growth(g.on, g.weightG, g.lengthMm, g.headMm)]);
  }
  return out.result(babyName);
}

/// Growth rows (one per measure) merged by date.
class _GrowthDay {
  _GrowthDay(this.on);

  final DateTime on;
  int? weightG, lengthMm, headMm;
}

List<ImportedEntry> _palnaRow(CsvTable t, List<String> row, List<_GrowthDay> growth) {
  String? get(String column) => t.get(row, column);
  final type = get(PalnaCsv.type) ?? (throw _unreadable);
  final subtype = get(PalnaCsv.subtype);
  switch (type) {
    case PalnaCsv.medicine:
      throw const _Skip(SkipReason.medicine);
    case PalnaCsv.vaccine:
      throw const _Skip(SkipReason.vaccine);
    case PalnaCsv.doctorVisit:
      throw const _Skip(SkipReason.doctorVisit);
    case PalnaCsv.food:
      throw const _Skip(SkipReason.solidFood);
    case PalnaCsv.milestone:
      throw const _Skip(SkipReason.milestone);
  }
  // The exact UTC time; the local one only if that's missing (dated rows).
  DateTime? time(String utc, String local) {
    final s = get(utc);
    return s != null ? DateTime.parse(s).toLocal() : _localTime(get(local));
  }

  final start = time(PalnaCsv.startUtc, PalnaCsv.start) ?? (throw _unreadable);
  final end = time(PalnaCsv.endUtc, PalnaCsv.end);
  final notes = _notes(get(PalnaCsv.notes));
  final amount = _num(get(PalnaCsv.amount));

  switch (type) {
    case PalnaCsv.feed:
      final feedType = FeedType.values.where((f) => f.dbValue == subtype).firstOrNull ?? (throw _unreadable);
      if (feedType == FeedType.solids) throw const _Skip(SkipReason.solidFood);
      final breast = feedType == FeedType.breast;
      return [
        ImportedFeed(
          type: feedType,
          startedAt: start,
          endedAt: end,
          amountMl: !breast && amount != null ? _ml(amount.round()) : null,
          leftSeconds: breast ? _seconds(get(PalnaCsv.leftSeconds)) : null,
          rightSeconds: breast ? _seconds(get(PalnaCsv.rightSeconds)) : null,
          notes: notes,
        ),
      ];
    case PalnaCsv.pumping:
      final side = subtype == null ? null : (BreastSide.values.asNameMap()[subtype] ?? (throw _unreadable));
      return [
        ImportedPumping(
          startedAt: start,
          endedAt: end,
          amountMl: amount == null ? null : _ml(amount.round()),
          side: side,
          notes: notes,
        ),
      ];
    case PalnaCsv.diaper:
      final (wet, dirty) = switch (subtype) {
        'wet' => (true, false),
        'dirty' => (false, true),
        'both' => (true, true),
        _ => throw _unreadable,
      };
      return [ImportedDiaper(at: start, wet: wet, dirty: dirty, notes: notes)];
    case PalnaCsv.sleep:
      final kind = subtype == null ? null : (SleepKind.values.asNameMap()[subtype] ?? (throw _unreadable));
      if (end == null) throw const _Skip(SkipReason.sleepGoing);
      return [ImportedSleep(startedAt: start, endedAt: end, kind: kind, notes: notes)];
    case PalnaCsv.activity:
      final label = get(PalnaCsv.label);
      return [
        ImportedActivity(
          kind: ActivityKind.fromDb(subtype),
          startedAt: start,
          endedAt: end,
          label: label == null ? null : _cap(label, 60),
          notes: notes,
        ),
      ];
    case PalnaCsv.growth:
      if (amount == null) throw _unreadable;
      final on = DateTime(start.year, start.month, start.day);
      // Check the value here, so a bad one counts against its own row.
      final value = switch (subtype) {
        'weight' => _inRange((amount * 1000).round(), 300, 40000),
        'length' => _inRange((amount * 10).round(), 200, 1300),
        'head' => _inRange((amount * 10).round(), 200, 600),
        _ => throw _unreadable,
      };
      // The first entry that day without this measure; two weighings on one
      // day stay two entries.
      bool free(_GrowthDay g) => switch (subtype) {
        'weight' => g.weightG == null,
        'length' => g.lengthMm == null,
        _ => g.headMm == null,
      };
      var day = growth.where((g) => g.on == on && free(g)).firstOrNull;
      if (day == null) growth.add(day = _GrowthDay(on));
      switch (subtype) {
        case 'weight':
          day.weightG = value;
        case 'length':
          day.lengthMm = value;
        default:
          day.headMm = value;
      }
      return const [];
    case PalnaCsv.symptom:
      if (amount == null) throw _Skip(SkipReason.other(type));
      return [ImportedTemperature(at: start, celsius: _celsius(amount, 'C'), notes: notes)];
  }
  throw _Skip(SkipReason.other(type));
}

// ------------------------------------------------------------------- Shared

/// Thrown while reading a row: the row is skipped for [reason].
class _Skip implements Exception {
  const _Skip(this.reason);

  final String reason;
}

const _unreadable = _Skip(SkipReason.unreadable);
const _outOfRange = _Skip(SkipReason.outOfRange);

/// Collects the entries read and counts the rows skipped.
class _Collector {
  final entries = <ImportedEntry>[];
  final skipped = <String, int>{};

  // Anything later than this is a broken date, not a real entry.
  final _latest = DateTime.now().add(const Duration(days: 1));

  void skip(String reason) => skipped.update(reason, (n) => n + 1, ifAbsent: () => 1);

  /// Keeps all of what [read] returns for one row, or counts why not.
  void row(List<ImportedEntry> Function() read) {
    try {
      final read_ = read();
      read_.forEach(_check);
      entries.addAll(read_);
    } on _Skip catch (e) {
      skip(e.reason);
    } on Exception {
      skip(SkipReason.unreadable);
    }
  }

  void _check(ImportedEntry e) {
    final end = switch (e) {
      ImportedFeed f => f.endedAt,
      ImportedPumping p => p.endedAt,
      ImportedSleep s => s.endedAt,
      ImportedActivity a => a.endedAt,
      _ => null,
    };
    if (e.at.isAfter(_latest) || (end?.isAfter(_latest) ?? false)) throw _unreadable;
    if (end != null && end.isBefore(e.at)) throw _outOfRange;
  }

  ImportResult result([String? babyName]) => ImportResult(entries: entries, skipped: skipped, babyName: babyName);
}

/// A growth entry with each measure dropped if out of the server's range;
/// the row is skipped when none is left.
ImportedGrowth _growth(DateTime on, int? weightG, int? lengthMm, int? headMm) {
  final w = _inRangeOrNull(weightG, 300, 40000);
  final l = _inRangeOrNull(lengthMm, 200, 1300);
  final h = _inRangeOrNull(headMm, 200, 600);
  if (w == null && l == null && h == null) throw (weightG ?? lengthMm ?? headMm) == null ? _unreadable : _outOfRange;
  return ImportedGrowth(on: DateTime(on.year, on.month, on.day), weightG: w, lengthMm: l, headMm: h);
}

int? _inRangeOrNull(int? v, int min, int max) => v != null && v >= min && v <= max ? v : null;

int _inRange(int v, int min, int max) => v >= min && v <= max ? v : throw _outOfRange;

/// A non-negative number; "4,5" is read as 4.5.
double? _num(String? value) {
  if (value == null) return null;
  final v = double.tryParse(value.contains('.') ? value : value.replaceAll(',', '.'));
  if (v == null || !v.isFinite) throw _unreadable;
  if (v < 0) throw _outOfRange;
  return v;
}

int? _seconds(String? value) => _num(value)?.round();

/// An amount in ml (bottles and pumping: 0..1000).
int _ml(int ml) => _inRange(ml, 0, 1000);

int _toMl(double v, String? unit) => _ml(
  switch (_unit(unit)) {
    null || 'ml' => v,
    'oz' || 'floz' => v * 29.5735,
    _ => throw _unreadable,
  }.round(),
);

int _grams(double v, String? unit) => switch (_unit(unit)) {
  'kg' => v * 1000,
  'g' => v,
  'lb' || 'lbs' || 'lbsoz' => v * 453.59237, // Huckleberry's "lbs.oz" is decimal pounds
  'oz' => v * 28.349523125,
  _ => throw _unreadable,
}.round();

int _mm(double v, String? unit) => switch (_unit(unit)) {
  'cm' => v * 10,
  'mm' => v,
  'in' => v * 25.4,
  'ft' || 'ftin' => v * 304.8, // Huckleberry's "ft.in" is decimal feet
  'm' => v * 1000,
  _ => throw _unreadable,
}.round();

/// Celsius to one decimal, 30..45.
double _celsius(double v, String? unit) {
  final c = switch (_unit(unit)) {
    null || 'c' || 'celsius' => v,
    'f' || 'fahrenheit' => (v - 32) * 5 / 9,
    _ => throw _unreadable,
  };
  final rounded = (c * 10).round() / 10;
  if (rounded < 30 || rounded > 45) throw _outOfRange;
  return rounded;
}

/// "FL OZ", "fl_oz", "°C" -> "floz", "c".
String? _unit(String? unit) => unit?.toLowerCase().replaceAll(RegExp(r'[\s._°]'), '');

final _stamp = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?$');

/// A local wall time: "2024-07-16 03:51", with optional seconds, or a date.
DateTime? _localTime(String? value) {
  if (value == null) return null;
  final m = _stamp.firstMatch(value) ?? (throw _unreadable);
  int at(int i) => int.parse(m[i] ?? '0');
  final (y, mo, d, h, mi, s) = (at(1), at(2), at(3), at(4), at(5), at(6));
  if (mo < 1 || mo > 12 || d < 1 || d > 31 || h > 23 || mi > 59 || s > 59) throw _unreadable;
  final t = DateTime(y, mo, d, h, mi, s);
  if (t.day != d) throw _unreadable; // e.g. 31 April
  return t;
}

DateTime? _tryLocalTime(String? value) {
  try {
    return _localTime(value);
  } on _Skip {
    return null;
  }
}

/// Trimmed, null when empty, at most 500 characters.
String? _notes(String? value) {
  final v = value?.trim();
  return v == null || v.isEmpty ? null : _cap(v, 500);
}

/// At most [max] characters (code points, as the server counts them).
String _cap(String s, int max) => s.runes.length <= max ? s : String.fromCharCodes(s.runes.take(max)).trimRight();

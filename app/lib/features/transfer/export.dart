import 'package:intl/intl.dart' show DateFormat;
import 'package:sqlite_async/sqlite_async.dart';

import '../../data/models.dart';
import 'csv.dart';
import 'import_model.dart';

// "Export my data": everything logged for one baby as one CSV file (opens in
// Excel / Google Sheets; Palna can import it again). Free for everyone:
// it's the family's data.

final _local = DateFormat('yyyy-MM-dd HH:mm');
final _date = DateFormat('yyyy-MM-dd');

String? _localTime(Object? utc) => utc == null ? null : _local.format(DateTime.parse(utc as String).toLocal());

String? _utc(Object? utc) => utc == null ? null : DateTime.parse(utc as String).toUtc().toIso8601String();

/// Whole minutes between two UTC timestamps, or null.
int? _minutes(Object? start, Object? end) {
  if (start == null || end == null) return null;
  return DateTime.parse(end as String).difference(DateTime.parse(start as String)).inMinutes;
}

/// The export's rows (header not included), oldest first.
Future<List<List<Object?>>> exportRows(SqliteReadContext db, Baby baby) async {
  final id = baby.id;
  final rows = <(String, List<Object?>)>[]; // sort key (UTC or date), row

  Future<List<Map<String, Object?>>> all(String sql) async =>
      [for (final r in await db.getAll(sql, [id])) Map<String, Object?>.of(r)];

  void timed(
    String type, {
    String? subtype,
    String? label,
    required Object? start,
    Object? end,
    Object? amount,
    String? unit,
    Object? left,
    Object? right,
    Object? notes,
  }) {
    rows.add((
      _utc(start) ?? '',
      [
        baby.name,
        type,
        subtype,
        label,
        _localTime(start),
        _localTime(end),
        _minutes(start, end),
        amount,
        unit,
        left,
        right,
        notes,
        _utc(start),
        _utc(end),
      ],
    ));
  }

  void dated(String type, Object? date, {String? subtype, String? label, Object? amount, String? unit, Object? notes}) {
    final day = DateTime.parse(date! as String);
    // Dates sort as midday (local) that day, among the timed entries.
    final key = DateTime(day.year, day.month, day.day, 12).toUtc().toIso8601String();
    rows.add((key, [baby.name, type, subtype, label, _date.format(day), null, null, amount, unit, null, null, notes, null, null]));
  }

  for (final r in await all(
    'SELECT type, started_at, ended_at, amount_ml, left_seconds, right_seconds, notes FROM feeds '
    'WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    final bottle = r['amount_ml'] != null;
    timed(
      PalnaCsv.feed,
      subtype: r['type'] as String?,
      start: r['started_at'],
      end: r['ended_at'],
      amount: r['amount_ml'],
      unit: bottle ? 'ml' : null,
      left: r['left_seconds'],
      right: r['right_seconds'],
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT side, started_at, ended_at, amount_ml, notes FROM pumping_sessions WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    timed(
      PalnaCsv.pumping,
      subtype: r['side'] as String?,
      start: r['started_at'],
      end: r['ended_at'],
      amount: r['amount_ml'],
      unit: r['amount_ml'] == null ? null : 'ml',
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT occurred_at, is_wet, is_dirty, notes FROM diapers WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    final wet = r['is_wet'] == 1 || r['is_wet'] == true;
    final dirty = r['is_dirty'] == 1 || r['is_dirty'] == true;
    timed(
      PalnaCsv.diaper,
      subtype: wet && dirty ? 'both' : (wet ? 'wet' : 'dirty'),
      start: r['occurred_at'],
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT kind, started_at, ended_at, notes FROM sleeps WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    timed(PalnaCsv.sleep, subtype: r['kind'] as String?, start: r['started_at'], end: r['ended_at'], notes: r['notes']);
  }
  for (final r in await all(
    'SELECT kind, label, started_at, ended_at, notes FROM activities WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    // An entry without a duration has ended_at = started_at: no end.
    final end = r['ended_at'] == r['started_at'] ? null : r['ended_at'];
    timed(
      PalnaCsv.activity,
      subtype: r['kind'] as String?,
      label: r['label'] as String?,
      start: r['started_at'],
      end: end,
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT measured_on, weight_g, length_mm, head_mm, notes FROM growth_measurements '
    'WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    final on = r['measured_on'];
    if (r['weight_g'] case final int g) {
      dated(PalnaCsv.growth, on, subtype: 'weight', amount: g / 1000, unit: 'kg', notes: r['notes']);
    }
    if (r['length_mm'] case final int mm) dated(PalnaCsv.growth, on, subtype: 'length', amount: mm / 10, unit: 'cm');
    if (r['head_mm'] case final int mm) dated(PalnaCsv.growth, on, subtype: 'head', amount: mm / 10, unit: 'cm');
  }
  for (final r in await all(
    'SELECT symptom, occurred_at, temperature_c, severity, notes FROM symptom_logs WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    timed(
      PalnaCsv.symptom,
      subtype: r['symptom'] as String?,
      label: switch (r['severity']) {
        1 => 'mild',
        2 => 'moderate',
        3 => 'severe',
        _ => null,
      },
      start: r['occurred_at'],
      amount: r['temperature_c'],
      unit: r['temperature_c'] == null ? null : '°C',
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT m.name, d.given_at, d.skipped, d.notes FROM medication_doses d JOIN medications m ON m.id = d.medication_id '
    'WHERE d.baby_id = ? AND d.deleted_at IS NULL',
  )) {
    final skipped = r['skipped'] == 1 || r['skipped'] == true;
    timed(
      PalnaCsv.medicine,
      subtype: r['name'] as String?,
      label: skipped ? 'skipped' : 'given',
      start: r['given_at'],
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT vaccine_code, vaccine_name, given_on, notes FROM vaccinations WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    dated(
      PalnaCsv.vaccine,
      r['given_on'],
      subtype: r['vaccine_code'] as String?,
      label: r['vaccine_name'] as String?,
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT visited_at, doctor, diagnosis, advice FROM doctor_visits WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    timed(
      PalnaCsv.doctorVisit,
      label: r['doctor'] as String?,
      start: r['visited_at'],
      notes: [r['diagnosis'], r['advice']].whereType<String>().join(' / '),
    );
  }
  for (final r in await all(
    'SELECT food_id, tried_on, opinion, reaction, notes FROM food_tries WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    dated(
      PalnaCsv.food,
      r['tried_on'],
      subtype: r['food_id'] as String?,
      label: [r['opinion'], if (r['reaction'] != 'none') r['reaction']].whereType<String>().join(' / '),
      notes: r['notes'],
    );
  }
  for (final r in await all(
    'SELECT milestone_id, achieved_on, notes FROM milestone_checks WHERE baby_id = ? AND deleted_at IS NULL',
  )) {
    if (r['achieved_on'] != null) {
      dated(PalnaCsv.milestone, r['achieved_on'], subtype: r['milestone_id'] as String?, notes: r['notes']);
    }
  }

  rows.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final (_, row) in rows) row];
}

/// The whole export file for [baby].
Future<String> exportCsv(SqliteReadContext db, Baby baby) async =>
    csvDocument(PalnaCsv.header, await exportRows(db, baby));

/// "palna-amna-2026-10-28.csv": letters and digits only, so every phone
/// and email app accepts it.
String exportFileName(Baby baby, DateTime now) {
  final name = baby.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
  return 'palna-${name.isEmpty ? 'baby' : name}-${_date.format(now)}.csv';
}

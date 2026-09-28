// Plain data classes for rows from Supabase. Timestamps are stored in UTC
// and converted to the phone's local time here.

DateTime _local(String value) => DateTime.parse(value).toLocal();
DateTime? _localOrNull(Object? value) => value == null ? null : _local(value as String);

class Baby {
  const Baby({
    required this.id,
    required this.familyId,
    required this.name,
    required this.birthDate,
    this.sex,
    this.birthWeightG,
    this.birthLengthMm,
    this.birthHeadMm,
  });

  final String id;
  final String familyId;
  final String name;
  final DateTime birthDate;

  /// 'female', 'male' or null (not given).
  final String? sex;
  final int? birthWeightG;
  final int? birthLengthMm;
  final int? birthHeadMm;

  static const columns = 'id, family_id, name, birth_date, sex, birth_weight_g, birth_length_mm, birth_head_mm';

  factory Baby.fromJson(Map<String, dynamic> json) => Baby(
        id: json['id'] as String,
        familyId: json['family_id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birth_date'] as String),
        sex: json['sex'] as String?,
        birthWeightG: json['birth_weight_g'] as int?,
        birthLengthMm: json['birth_length_mm'] as int?,
        birthHeadMm: json['birth_head_mm'] as int?,
      );
}

/// One visit to the scale / measuring tape. Any of the three may be missing.
class GrowthMeasurement {
  const GrowthMeasurement({required this.id, required this.measuredOn, this.weightG, this.lengthMm, this.headMm});

  final String id;
  final DateTime measuredOn;
  final int? weightG;
  final int? lengthMm;
  final int? headMm;

  factory GrowthMeasurement.fromJson(Map<String, dynamic> json) => GrowthMeasurement(
        id: json['id'] as String,
        measuredOn: DateTime.parse(json['measured_on'] as String),
        weightG: json['weight_g'] as int?,
        lengthMm: json['length_mm'] as int?,
        headMm: json['head_mm'] as int?,
      );
}

enum FeedType {
  breast('breast'),
  bottleBreastMilk('bottle_breast_milk'),
  bottleFormula('bottle_formula'),
  solids('solids');

  const FeedType(this.dbValue);
  final String dbValue;

  bool get isBottle => this == bottleBreastMilk || this == bottleFormula;

  static FeedType fromDb(String value) => values.firstWhere((t) => t.dbValue == value);
}

enum BreastSide { left, right, both }

class Feed {
  const Feed({
    required this.id,
    required this.type,
    required this.startedAt,
    this.endedAt,
    this.side,
    this.amountMl,
  });

  final String id;
  final FeedType type;
  final DateTime startedAt;
  final DateTime? endedAt;
  final BreastSide? side;
  final int? amountMl;

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json['id'] as String,
        type: FeedType.fromDb(json['type'] as String),
        startedAt: _local(json['started_at'] as String),
        endedAt: _localOrNull(json['ended_at']),
        side: json['side'] == null ? null : BreastSide.values.byName(json['side'] as String),
        amountMl: json['amount_ml'] as int?,
      );
}

class Diaper {
  const Diaper({required this.id, required this.occurredAt, required this.isWet, required this.isDirty});

  final String id;
  final DateTime occurredAt;
  final bool isWet;
  final bool isDirty;

  factory Diaper.fromJson(Map<String, dynamic> json) => Diaper(
        id: json['id'] as String,
        occurredAt: _local(json['occurred_at'] as String),
        isWet: json['is_wet'] as bool,
        isDirty: json['is_dirty'] as bool,
      );
}

enum SleepKind { nap, night }

class Sleep {
  const Sleep({required this.id, required this.kind, required this.startedAt, this.endedAt});

  final String id;
  final SleepKind kind;
  final DateTime startedAt;
  final DateTime? endedAt;

  bool get isOngoing => endedAt == null;

  factory Sleep.fromJson(Map<String, dynamic> json) => Sleep(
        id: json['id'] as String,
        kind: SleepKind.values.byName(json['kind'] as String),
        startedAt: _local(json['started_at'] as String),
        endedAt: _localOrNull(json['ended_at']),
      );
}

/// Everything logged for one baby today, plus the totals the dashboard shows.
class TodayLog {
  const TodayLog({required this.dayStart, required this.feeds, required this.diapers, required this.sleeps});

  final DateTime dayStart;
  final List<Feed> feeds;
  final List<Diaper> diapers;

  /// Sleeps that overlap today, including one that started last night.
  final List<Sleep> sleeps;

  int get bottleMl => feeds
      .where((f) => f.type.isBottle)
      .fold(0, (sum, f) => sum + (f.amountMl ?? 0));

  Feed? get lastFeed => feeds.isEmpty ? null : feeds.reduce((a, b) => a.startedAt.isAfter(b.startedAt) ? a : b);

  int get wetCount => diapers.where((d) => d.isWet).length;
  int get dirtyCount => diapers.where((d) => d.isDirty).length;

  Sleep? get ongoingSleep => sleeps.where((s) => s.isOngoing).firstOrNull;

  /// Time asleep since midnight; a sleep that began yesterday counts from midnight.
  Duration sleptSince(DateTime now) => sleeps.fold(Duration.zero, (total, s) {
        final start = s.startedAt.isBefore(dayStart) ? dayStart : s.startedAt;
        final end = s.endedAt ?? now;
        return end.isAfter(start) ? total + end.difference(start) : total;
      });
}

/// One dose in the national schedule, e.g. Pentavalent dose 2 at 10 weeks.
class VaccineDose {
  const VaccineDose({
    required this.code,
    required this.name,
    required this.dueAgeValue,
    required this.dueAgeUnit,
    required this.sortOrder,
    this.doseLabel,
  });

  final String code;
  final String name;
  final String? doseLabel;
  final int dueAgeValue;

  /// 'day', 'week' or 'month'.
  final String dueAgeUnit;
  final int sortOrder;

  factory VaccineDose.fromJson(Map<String, dynamic> json) => VaccineDose(
        code: json['code'] as String,
        name: json['name'] as String,
        doseLabel: json['dose_label'] as String?,
        dueAgeValue: json['due_age_value'] as int,
        dueAgeUnit: json['due_age_unit'] as String,
        sortOrder: json['sort_order'] as int,
      );
}

/// A dose the baby has received.
class Vaccination {
  const Vaccination({
    required this.id,
    required this.vaccineCode,
    required this.givenOn,
    this.batchNumber,
    this.clinic,
    this.notes,
  });

  final String id;
  final String vaccineCode;
  final DateTime givenOn;
  final String? batchNumber;
  final String? clinic;
  final String? notes;

  factory Vaccination.fromJson(Map<String, dynamic> json) => Vaccination(
        id: json['id'] as String,
        vaccineCode: json['vaccine_code'] as String,
        givenOn: DateTime.parse(json['given_on'] as String),
        batchNumber: json['batch_number'] as String?,
        clinic: json['clinic'] as String?,
        notes: json['notes'] as String?,
      );
}

/// A time of day for a scheduled dose, e.g. 08:00.
class DoseTime implements Comparable<DoseTime> {
  const DoseTime(this.hour, this.minute);

  final int hour;
  final int minute;

  /// Parses Postgres `time` values like '08:00:00'.
  factory DoseTime.parse(String value) {
    final parts = value.split(':');
    return DoseTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  String toDb() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';

  DateTime on(DateTime day) => DateTime(day.year, day.month, day.day, hour, minute);

  @override
  int compareTo(DoseTime other) => (hour * 60 + minute).compareTo(other.hour * 60 + other.minute);

  @override
  bool operator ==(Object other) => other is DoseTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => hour * 60 + minute;
}

/// A doctor's prescription as the parent entered it. The dose is free text
/// exactly as prescribed; the app never calculates doses.
class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.prescribedDose,
    required this.doseTimes,
    required this.asNeeded,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.notes,
  });

  final String id;
  final String name;
  final String prescribedDose;

  /// Sorted; empty when [asNeeded].
  final List<DoseTime> doseTimes;
  final bool asNeeded;
  final DateTime startDate;

  /// Last day to give it (inclusive); null means ongoing.
  final DateTime? endDate;
  final String? prescribedBy;
  final String? notes;

  static const columns = 'id, name, prescribed_dose, dose_times, as_needed, start_date, end_date, prescribed_by, notes';

  bool isActiveOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(startDate) && (endDate == null || !d.isAfter(endDate!));
  }

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        name: json['name'] as String,
        prescribedDose: json['prescribed_dose'] as String,
        doseTimes: [for (final t in json['dose_times'] as List) DoseTime.parse(t as String)]..sort(),
        asNeeded: json['as_needed'] as bool,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] == null ? null : DateTime.parse(json['end_date'] as String),
        prescribedBy: json['prescribed_by'] as String?,
        notes: json['notes'] as String?,
      );
}

/// A dose given (or deliberately skipped).
class MedicationDose {
  const MedicationDose({
    required this.id,
    required this.medicationId,
    required this.givenAt,
    required this.skipped,
    this.scheduledFor,
  });

  final String id;
  final String medicationId;
  final DateTime givenAt;
  final bool skipped;

  /// The scheduled time this dose was for; null for "as needed" doses.
  final DateTime? scheduledFor;

  factory MedicationDose.fromJson(Map<String, dynamic> json) => MedicationDose(
        id: json['id'] as String,
        medicationId: json['medication_id'] as String,
        givenAt: DateTime.parse(json['given_at'] as String).toLocal(),
        skipped: json['skipped'] as bool,
        scheduledFor: json['scheduled_for'] == null ? null : DateTime.parse(json['scheduled_for'] as String).toLocal(),
      );
}

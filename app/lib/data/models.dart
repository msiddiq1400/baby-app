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
  });

  final String id;
  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? sex;

  factory Baby.fromJson(Map<String, dynamic> json) => Baby(
        id: json['id'] as String,
        familyId: json['family_id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birth_date'] as String),
        sex: json['sex'] as String?,
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

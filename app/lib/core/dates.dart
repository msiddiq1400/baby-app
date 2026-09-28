/// Postgres `date` value (yyyy-mm-dd) for a calendar day, ignoring time.
String dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Postgres `timestamptz` value; always sent in UTC.
String utcTimestamp(DateTime t) => t.toUtc().toIso8601String();

/// [d] plus whole calendar months; the 31st becomes the month's last day
/// when needed (31 Jan + 1 month = 28/29 Feb). Returns a UTC date.
DateTime addMonths(DateTime d, int months) {
  final monthIndex = d.month - 1 + months;
  final year = d.year + monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDay = DateTime.utc(year, month + 1, 0).day;
  return DateTime.utc(year, month, d.day > lastDay ? lastDay : d.day);
}

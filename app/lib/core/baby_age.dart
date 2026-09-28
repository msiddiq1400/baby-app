import '../l10n/app_localizations.dart';
import 'dates.dart';

/// Whole calendar months and remaining days between [birth] and [today],
/// e.g. born 8 April, today 28 September -> 5 months, 20 days.
({int months, int days}) babyAge(DateTime birth, DateTime today) {
  // UTC dates avoid daylight-saving shifts when counting days.
  final b = DateTime.utc(birth.year, birth.month, birth.day);
  final t = DateTime.utc(today.year, today.month, today.day);
  if (t.isBefore(b)) return (months: 0, days: 0);

  var months = (t.year - b.year) * 12 + t.month - b.month;
  if (t.day < b.day) months--;
  final anchor = addMonths(b, months);
  return (months: months, days: t.difference(anchor).inDays);
}

String formatBabyAge(AppLocalizations l10n, DateTime birth, DateTime today) {
  final age = babyAge(birth, today);
  if (age.months == 0) return l10n.ageDays(age.days);
  if (age.days == 0) return l10n.ageMonths(age.months);
  return '${l10n.ageMonths(age.months)}, ${l10n.ageDays(age.days)}';
}

String formatDuration(AppLocalizations l10n, Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  return hours == 0 ? l10n.durationM(minutes) : l10n.durationHm(hours, minutes);
}

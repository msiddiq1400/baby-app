/// Optional RSV and flu protection (todos.txt Q5): shown as "Optional - ask
/// your doctor" next to the routine schedule, only in countries that offer it
/// to ALL babies or young children (not just risk groups). Each baby's family
/// can hide them.
///
/// Rules checked 27 Oct 2026 against each country's health ministry or public
/// health agency (sources in docs/vaccine-research-2026-10/). Re-check every
/// summer before the season, especially:
///   * US: CDC's Jan 2026 schedule (flu and RSV "decide with your doctor") is
///     stayed by a court since 16 Mar 2026; the appeal was heard 6 Oct 2026.
///     If it's upheld, drop the US entries.
///   * Canada: provinces differ (British Columbia offers RSV to high-risk
///     babies only, Alberta to babies born in hospital Nov-Apr).
///   * Norway plans RSV for all babies from 1 Jul 2027.
library;

typedef MonthDay = ({int month, int day});

/// RSV antibody (nirsevimab / clesrovimab) for a baby's first RSV season.
///
/// A baby born between [birthFrom] and [birthTo] (inclusive, the window may
/// run over New Year) gets it at birth. A baby born before the window who is
/// still under [catchUpUnderMonths] months old on [catchUpOn] gets it then.
/// No catch-up when [catchUpOn] is null.
typedef RsvRule = ({MonthDay birthFrom, MonthDay birthTo, MonthDay? catchUpOn, int? catchUpUnderMonths});

/// Yearly flu vaccine from [campaignStart], for children aged [fromMonths] up
/// to (not including) [untilMonths] (null: no upper limit). Children under
/// [twoDosesUnderYears] having it for the first time usually need two doses
/// 4 weeks apart (null: one dose is enough for healthy children). [nasal]:
/// usually given as a nasal spray (it contains pork gelatine; an injection
/// can be asked for instead).
typedef FluRule = ({int fromMonths, int? untilMonths, MonthDay campaignStart, int? twoDosesUnderYears, bool nasal});

const rsvRules = <String, RsvRule>{
  // CDC/ACIP: under 8 months entering the first season, unless the mother had
  // the RSV vaccine 14+ days before birth. Most of the mainland: Oct-Mar.
  'US': (
    birthFrom: (month: 10, day: 1),
    birthTo: (month: 3, day: 31),
    catchUpOn: (month: 10, day: 1),
    catchUpUnderMonths: 8,
  ),
  // NACI: all infants in their first season; provinces run it (most from
  // about 1 Oct).
  'CA': (
    birthFrom: (month: 10, day: 1),
    birthTo: (month: 3, day: 31),
    catchUpOn: (month: 10, day: 1),
    catchUpUnderMonths: 8,
  ),
  // UAE decree 189/2025: babies born 1 Sep - 1 Mar, at birth. No catch-up found.
  'AE': (birthFrom: (month: 9, day: 1), birthTo: (month: 3, day: 1), catchUpOn: null, catchUpUnderMonths: null),
  // Saudi MOH (national schedule since 2025): doses from mid-September.
  'SA': (
    birthFrom: (month: 9, day: 15),
    birthTo: (month: 3, day: 31),
    catchUpOn: (month: 9, day: 15),
    catchUpUnderMonths: 8,
  ),
  // Kuwait: within 24 h of birth in season; babies born up to 6 months before
  // get it at the season start. The committee sets the months each year.
  'KW': (
    birthFrom: (month: 10, day: 1),
    birthTo: (month: 3, day: 31),
    catchUpOn: (month: 10, day: 1),
    catchUpUnderMonths: 6,
  ),
  // France 2026/27 campaign: 14 Sep - 28 Feb, at the maternity ward; babies
  // born earlier in their first season get it before it starts.
  'FR': (
    birthFrom: (month: 9, day: 14),
    birthTo: (month: 2, day: 28),
    catchUpOn: (month: 9, day: 14),
    catchUpUnderMonths: 7,
  ),
  // HSE Ireland 2026/27: born 1 Sep - 28 Feb in hospital; born 1 Mar - 31 Aug
  // at the GP from 1 Sep.
  'IE': (
    birthFrom: (month: 9, day: 1),
    birthTo: (month: 2, day: 28),
    catchUpOn: (month: 9, day: 1),
    catchUpUnderMonths: 6,
  ),
  // RIVM: born Oct-Mar within 14 days; born Apr-Sep at the catch-up from 15 Sep.
  'NL': (
    birthFrom: (month: 10, day: 1),
    birthTo: (month: 3, day: 31),
    catchUpOn: (month: 9, day: 15),
    catchUpUnderMonths: 6,
  ),
  // Swedish regions (joint recommendation 27 Aug 2026): born from 10 Sep, at
  // the maternity ward or first check; no catch-up.
  'SE': (birthFrom: (month: 9, day: 10), birthTo: (month: 3, day: 31), catchUpOn: null, catchUpUnderMonths: null),
};

const fluRules = <String, FluRule>{
  'US': (fromMonths: 6, untilMonths: null, campaignStart: (month: 9, day: 1), twoDosesUnderYears: 9, nasal: false),
  'CA': (fromMonths: 6, untilMonths: null, campaignStart: (month: 10, day: 1), twoDosesUnderYears: 9, nasal: false),
  'AE': (fromMonths: 6, untilMonths: null, campaignStart: (month: 9, day: 1), twoDosesUnderYears: 9, nasal: false),
  'SA': (fromMonths: 6, untilMonths: null, campaignStart: (month: 9, day: 15), twoDosesUnderYears: 9, nasal: false),
  'QA': (fromMonths: 6, untilMonths: null, campaignStart: (month: 10, day: 1), twoDosesUnderYears: 9, nasal: false),
  'BH': (fromMonths: 6, untilMonths: 60, campaignStart: (month: 10, day: 1), twoDosesUnderYears: 9, nasal: false),
  // Southern hemisphere: from March/April, before the June-September peak.
  'AU': (fromMonths: 6, untilMonths: 60, campaignStart: (month: 4, day: 1), twoDosesUnderYears: 9, nasal: false),
  // From age 2 (2 or 3 on 31 August at the GP), as a nasal spray.
  'GB': (fromMonths: 24, untilMonths: null, campaignStart: (month: 9, day: 1), twoDosesUnderYears: null, nasal: true),
  'IE': (fromMonths: 24, untilMonths: null, campaignStart: (month: 10, day: 1), twoDosesUnderYears: null, nasal: true),
};

enum OptionalKind { rsv, flu }

/// One optional dose to show (and remind about).
class OptionalVaccine {
  const OptionalVaccine({
    required this.kind,
    required this.code,
    required this.dueDate,
    required this.showUntil,
    this.season,
    this.firstFlu = false,
    this.twoDosesUnderYears,
    this.nasal = false,
  });

  final OptionalKind kind;

  /// Saved as the vaccination's vaccine_code: 'RSV', or 'FLU-<season start
  /// year>' (one per season).
  final String code;

  /// Local calendar date (midnight).
  final DateTime dueDate;

  /// Not given by then: it's missed, so it's no longer shown.
  final DateTime showUntil;

  /// Flu: the season's start year.
  final int? season;

  /// Flu: no flu vaccine recorded before, and young enough for two doses.
  final bool firstFlu;
  final int? twoDosesUnderYears;
  final bool nasal;
}

const rsvCode = 'RSV';
String fluCode(int seasonYear) => 'FLU-$seasonYear';
bool isOptionalCode(String code) => code == rsvCode || code.startsWith('FLU-');

/// "2026–27", or "2027" in the southern hemisphere (one calendar year).
String fluSeasonLabel(String country, int year) {
  final startMonth = fluRules[country]?.campaignStart.month ?? 9;
  if (startMonth < 7) return '$year';
  return '$year–${((year + 1) % 100).toString().padLeft(2, '0')}';
}

/// Optional doses for a baby born on [birth] in [country], as of [today]:
/// RSV for the first season (if offered there), and the current or next flu
/// season. [givenCodes]: vaccine codes already recorded for the baby. Given
/// ones are included (so they show as done); missed ones are not.
List<OptionalVaccine> optionalVaccines(String country, DateTime birth, DateTime today, Set<String> givenCodes) {
  final b = _day(birth);
  final t = _day(today);
  return [?_rsv(rsvRules[country], b, t, givenCodes), ...?_flu(fluRules[country], b, t, givenCodes)];
}

OptionalVaccine? _rsv(RsvRule? rule, DateTime birth, DateTime today, Set<String> given) {
  if (rule == null) return null;
  // The birth window that contains the birth date, if any.
  for (final year in [birth.year - 1, birth.year]) {
    final from = _on(year, rule.birthFrom);
    final to = _windowEnd(year, rule.birthFrom, rule.birthTo);
    if (!birth.isBefore(from) && !birth.isAfter(to)) {
      return _rsvDose(birth, to, today, given);
    }
  }
  // Born before the next window: catch-up at its start, if young enough.
  final catchUp = rule.catchUpOn;
  final under = rule.catchUpUnderMonths;
  if (catchUp == null || under == null) return null;
  var on = _on(birth.year, catchUp);
  if (!on.isAfter(birth)) on = _on(birth.year + 1, catchUp);
  if (!on.isBefore(_addMonths(birth, under))) return null;
  // Catch-up dates are in September/October, just before (or on) the start
  // of that year's window.
  return _rsvDose(on, _windowEnd(on.year, rule.birthFrom, rule.birthTo), today, given);
}

OptionalVaccine? _rsvDose(DateTime due, DateTime seasonEnd, DateTime today, Set<String> given) {
  if (!given.contains(rsvCode) && today.isAfter(seasonEnd)) return null;
  return OptionalVaccine(kind: OptionalKind.rsv, code: rsvCode, dueDate: due, showUntil: seasonEnd);
}

List<OptionalVaccine>? _flu(FluRule? rule, DateTime birth, DateTime today, Set<String> given) {
  if (rule == null) return null;
  final hadFluBefore = given.any((c) => c.startsWith('FLU-'));
  // This season (if it has started) and the next one.
  final thisYear = today.isBefore(_on(today.year, rule.campaignStart)) ? today.year - 1 : today.year;
  for (final year in [thisYear, thisYear + 1]) {
    final start = _on(year, rule.campaignStart);
    final end = _addMonths(start, 6);
    final oldEnough = _addMonths(birth, rule.fromMonths);
    final due = oldEnough.isAfter(start) ? oldEnough : start;
    if (!due.isBefore(end)) continue;
    if (rule.untilMonths case final until? when !due.isBefore(_addMonths(birth, until))) continue;
    final code = fluCode(year);
    if (given.contains(code)) {
      // Done this season: show it as done, plus nothing more until next year.
      return [OptionalVaccine(kind: OptionalKind.flu, code: code, dueDate: due, showUntil: end, season: year)];
    }
    if (today.isAfter(end)) continue;
    final twoDoses = rule.twoDosesUnderYears;
    return [
      OptionalVaccine(
        kind: OptionalKind.flu,
        code: code,
        dueDate: due,
        showUntil: end,
        season: year,
        firstFlu: !hadFluBefore && twoDoses != null && due.isBefore(_addMonths(birth, twoDoses * 12)),
        twoDosesUnderYears: twoDoses,
        nasal: rule.nasal,
      ),
    ];
  }
  return const [];
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// [md] in [year]; 29 Feb becomes 28 Feb in other years.
DateTime _on(int year, MonthDay md) {
  final last = DateTime(year, md.month + 1, 0).day;
  return DateTime(year, md.month, md.day > last ? last : md.day);
}

/// Last day of the window that starts in [year].
DateTime _windowEnd(int year, MonthDay from, MonthDay to) {
  final overNewYear = to.month < from.month || (to.month == from.month && to.day < from.day);
  final end = _on(overNewYear ? year + 1 : year, to);
  // 28 Feb windows also cover 29 Feb in leap years.
  if (to.month == 2 && to.day == 28) return DateTime(end.year, 3, 0);
  return end;
}

DateTime _addMonths(DateTime d, int months) {
  final target = DateTime(d.year, d.month + months, 1);
  final last = DateTime(target.year, target.month + 1, 0).day;
  return DateTime(target.year, target.month, d.day > last ? last : d.day);
}

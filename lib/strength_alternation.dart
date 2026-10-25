/// One-based day of the year for [date]: January 1 is day 1.
///
/// Computed in UTC so daylight-saving shifts cannot skew the count.
int dayOfYear(DateTime date) {
  final startOfYear = DateTime.utc(date.year, 1, 1);
  final day = DateTime.utc(date.year, date.month, date.day);
  return day.difference(startOfYear).inDays + 1;
}

/// Morning strength alternation: upper body on odd days of the year,
/// lower body on even days.
bool isUpperBodyDay(DateTime date) => dayOfYear(date).isOdd;

import 'dart:math';

/// Points earned by a guided session: two points for each completed
/// active minute, capped at 120 points (one hour) per session.
///
/// Pauses, time away and skipped segments are excluded by the caller,
/// which passes only actively practiced seconds.
int sessionPoints(int activeSeconds) {
  if (activeSeconds <= 0) return 0;
  return min(120, 2 * (activeSeconds ~/ 60));
}

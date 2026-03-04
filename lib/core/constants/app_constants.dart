/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // ── Firestore Collections ──
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String reflectionsCollection = 'reflections';
  static const String dailyScoresCollection = 'daily_scores';

  // ── Score Calculation Weights ──
  static const int highImpactTaskWeight = 5;
  static const int deepWorkDivisor = 30;
  static const double maxScore = 100.0;

  // ── Layout Breakpoints ──
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1200;

  // ── Agent Thresholds ──
  static const double recoveryThreshold = 40.0;
  static const double focusThreshold = 80.0;
  static const int consecutiveLowDaysForMotivation = 2;

  // ── Animation Durations ──
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // ── Spacing ──
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Border Radius ──
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 9999.0;
}

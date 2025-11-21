class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int addedCount;
  final int consumedCount;
  final int trashedCount;
  final int pointsEarned;
  final double wastePercentage;

  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.addedCount,
    required this.consumedCount,
    required this.trashedCount,
    required this.pointsEarned,
    required this.wastePercentage,
  });

  static WeeklyReport calculate({
    required DateTime weekStart,
    required DateTime weekEnd,
    required int addedCount,
    required int consumedCount,
    required int trashedCount,
    required int pointsEarned,
  }) {
    final total = addedCount;
    final wastePercentage = total > 0 ? (trashedCount / total) * 100 : 0.0;

    return WeeklyReport(
      weekStart: weekStart,
      weekEnd: weekEnd,
      addedCount: addedCount,
      consumedCount: consumedCount,
      trashedCount: trashedCount,
      pointsEarned: pointsEarned,
      wastePercentage: wastePercentage,
    );
  }
}


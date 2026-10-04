class AnalyticsSummaryModel {
  final int totalMeetings;
  final double totalHours;
  final int activeUsers;
  final int peakConcurrentMeetings;
  final double completionRate;
  final double monthlyGrowthPercent;
  final List<double> weeklyMeetingCounts;

  const AnalyticsSummaryModel({
    required this.totalMeetings,
    required this.totalHours,
    required this.activeUsers,
    required this.peakConcurrentMeetings,
    required this.completionRate,
    required this.monthlyGrowthPercent,
    required this.weeklyMeetingCounts,
  });
}

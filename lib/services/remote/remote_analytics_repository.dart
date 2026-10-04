import '../../features/analytics/domain/models/analytics_summary_model.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import 'api_client.dart';

class RemoteAnalyticsRepository implements AnalyticsRepository {
  final ApiClient _client;

  RemoteAnalyticsRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  @override
  Future<AnalyticsSummaryModel> getSummary() async {
    try {
      final response = await _client.get('/api/analytics/summary');
      final data = _extractData(response);

      if (data is Map<String, dynamic>) {
        final weeklyRaw = data['weeklyMeetingCounts'] as List? ?? [];
        final weeklyCounts = weeklyRaw
            .map((e) => (e as num).toDouble())
            .toList();

        return AnalyticsSummaryModel(
          totalMeetings: data['totalMeetings'] as int? ?? 0,
          totalHours: (data['totalHours'] as num?)?.toDouble() ?? 0.0,
          activeUsers: data['activeUsers'] as int? ?? 0,
          peakConcurrentMeetings: data['peakConcurrentMeetings'] as int? ?? 0,
          completionRate: (data['completionRate'] as num?)?.toDouble() ?? 0.0,
          monthlyGrowthPercent:
              (data['monthlyGrowthPercent'] as num?)?.toDouble() ?? 0.0,
          weeklyMeetingCounts: weeklyCounts.isNotEmpty
              ? weeklyCounts
              : const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        );
      }

      return const AnalyticsSummaryModel(
        totalMeetings: 0,
        totalHours: 0.0,
        activeUsers: 0,
        peakConcurrentMeetings: 0,
        completionRate: 0.0,
        monthlyGrowthPercent: 0.0,
        weeklyMeetingCounts: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      );
    } catch (_) {
      return const AnalyticsSummaryModel(
        totalMeetings: 0,
        totalHours: 0.0,
        activeUsers: 0,
        peakConcurrentMeetings: 0,
        completionRate: 0.0,
        monthlyGrowthPercent: 0.0,
        weeklyMeetingCounts: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      );
    }
  }
}

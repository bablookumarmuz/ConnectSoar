import '../models/analytics_summary_model.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummaryModel> getSummary();
}

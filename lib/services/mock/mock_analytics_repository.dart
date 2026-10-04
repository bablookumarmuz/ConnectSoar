import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/analytics/domain/models/analytics_summary_model.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import 'mock_data_generator.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<AnalyticsSummaryModel> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDataGenerator.sampleAnalytics;
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return MockAnalyticsRepository();
});

final analyticsSummaryProvider = FutureProvider<AnalyticsSummaryModel>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getSummary();
});

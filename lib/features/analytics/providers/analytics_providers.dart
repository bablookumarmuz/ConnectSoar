import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../services/mock/mock_analytics_repository.dart';
import '../../../services/remote/api_client.dart';
import '../../../services/remote/remote_analytics_repository.dart';
import '../domain/models/analytics_summary_model.dart';
import '../domain/repositories/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockAnalyticsRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteAnalyticsRepository(client);
});

final analyticsSummaryProvider = FutureProvider<AnalyticsSummaryModel>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getSummary();
});

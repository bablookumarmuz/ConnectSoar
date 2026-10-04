import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../services/mock/mock_history_repository.dart';
import '../../../services/remote/api_client.dart';
import '../../../services/remote/remote_history_repository.dart';
import '../domain/models/meeting_event_model.dart';
import '../domain/models/meeting_history_detail_model.dart';
import '../domain/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockHistoryRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteHistoryRepository(client);
});

class MeetingHistoryFilter {
  final String? query;
  final String? date;

  const MeetingHistoryFilter({this.query, this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeetingHistoryFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          date == other.date;

  @override
  int get hashCode => Object.hash(query, date);
}

final meetingHistoryListProvider =
    FutureProvider.family<List<MeetingEventModel>, MeetingHistoryFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.watch(historyRepositoryProvider);
      return repo.getMeetingHistory(
        searchQuery: filter.query,
        dateFilter: filter.date,
      );
    });

final meetingHistoryDetailProvider =
    FutureProvider.family<MeetingHistoryDetailModel?, String>((
      ref,
      meetingId,
    ) async {
      final repo = ref.watch(historyRepositoryProvider);
      return repo.getHistoryDetail(meetingId);
    });

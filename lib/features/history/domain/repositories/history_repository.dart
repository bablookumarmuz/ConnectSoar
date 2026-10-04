import '../models/meeting_event_model.dart';
import '../models/meeting_history_detail_model.dart';

abstract class HistoryRepository {
  Future<List<MeetingEventModel>> getMeetingHistory({
    String? searchQuery,
    String? dateFilter,
  });
  Future<MeetingHistoryDetailModel?> getHistoryDetail(String meetingId);
}

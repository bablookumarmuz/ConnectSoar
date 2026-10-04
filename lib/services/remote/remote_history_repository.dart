import '../../features/history/domain/models/meeting_event_model.dart';
import '../../features/history/domain/models/meeting_history_detail_model.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/meetings/domain/models/participant_model.dart';
import 'api_client.dart';

class RemoteHistoryRepository implements HistoryRepository {
  final ApiClient _client;

  RemoteHistoryRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  @override
  Future<List<MeetingEventModel>> getMeetingHistory({
    String? searchQuery,
    String? dateFilter,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['query'] = searchQuery;
      }
      if (dateFilter != null && dateFilter.isNotEmpty) {
        queryParams['date'] = dateFilter;
      }

      final response = await _client.get(
        '/api/history',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = _extractData(response);

      if (data is List) {
        return data.map((e) {
          final json = e as Map<String, dynamic>;
          return MeetingEventModel(
            id: (json['id'] as String?) ?? '',
            meetingId: (json['meetingId'] as String?) ?? '',
            title: (json['title'] as String?) ?? 'Meeting Event',
            timestamp: json['timestamp'] != null
                ? DateTime.parse(json['timestamp'] as String)
                : DateTime.now(),
            type: (json['type'] as String?) ?? 'Meeting',
            summary: (json['summary'] as String?) ?? '',
            durationMinutes: json['durationMinutes'] as int? ?? 0,
            participantCount: json['participantCount'] as int? ?? 1,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<MeetingHistoryDetailModel?> getHistoryDetail(String meetingId) async {
    try {
      final response = await _client.get('/api/history/$meetingId');
      final data = _extractData(response);
      if (data == null || data is! Map<String, dynamic>) return null;

      final participantsJson = data['participants'] as List? ?? [];
      final participants = participantsJson
          .map(
            (p) => ParticipantModel(
              id: (p['id'] as String?) ?? '',
              userId: (p['userId'] as String?) ?? '',
              name: (p['name'] as String?) ?? 'Participant',
              avatarUrl: (p['avatarUrl'] as String?) ?? '',
              role: ParticipantRole.values.firstWhere(
                (r) =>
                    r.name.toLowerCase() ==
                    (p['role'] as String? ?? 'attendee').toLowerCase(),
                orElse: () => ParticipantRole.attendee,
              ),
              isMuted: p['isMuted'] as bool? ?? false,
              isVideoOff: p['isVideoOff'] as bool? ?? false,
              isHandRaised: p['isHandRaised'] as bool? ?? false,
              isScreenSharing: p['isScreenSharing'] as bool? ?? false,
            ),
          )
          .toList();

      final timelineEventsJson = data['timelineEvents'] as List? ?? [];
      final timelineEvents = timelineEventsJson
          .map(
            (ev) => MeetingTimelineEvent(
              id: (ev['id'] as String?) ?? '',
              title: (ev['title'] as String?) ?? 'Event',
              timestamp: ev['timestamp'] != null
                  ? DateTime.parse(ev['timestamp'] as String)
                  : DateTime.now(),
              category: (ev['category'] as String?) ?? 'system',
              participantName: ev['participantName'] as String?,
              avatarUrl: ev['avatarUrl'] as String?,
              detail: ev['detail'] as String?,
            ),
          )
          .toList();

      return MeetingHistoryDetailModel(
        id: (data['id'] as String?) ?? '',
        meetingId: (data['meetingId'] as String?) ?? meetingId,
        title: (data['title'] as String?) ?? 'Meeting History',
        description: (data['description'] as String?) ?? '',
        joinCode: (data['joinCode'] as String?) ?? '',
        startTime: data['startTime'] != null
            ? DateTime.parse(data['startTime'] as String)
            : DateTime.now(),
        endTime: data['endTime'] != null
            ? DateTime.parse(data['endTime'] as String)
            : DateTime.now(),
        hostName: (data['hostName'] as String?) ?? 'Host',
        hostAvatarUrl: (data['hostAvatarUrl'] as String?) ?? '',
        type: (data['type'] as String?) ?? 'Meeting',
        summary: (data['summary'] as String?) ?? '',
        durationMinutes: data['durationMinutes'] as int? ?? 0,
        screenShareDurationMinutes:
            data['screenShareDurationMinutes'] as int? ?? 0,
        chatMessageCount: data['chatMessageCount'] as int? ?? 0,
        participants: participants,
        timelineEvents: timelineEvents,
      );
    } catch (_) {
      return null;
    }
  }
}

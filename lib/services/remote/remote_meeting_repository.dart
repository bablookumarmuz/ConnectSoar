import '../../core/config/api_config.dart';
import '../../features/meetings/domain/models/meeting_model.dart';
import '../../features/meetings/domain/models/participant_model.dart';
import '../../features/meetings/domain/repositories/meeting_repository.dart';
import 'api_client.dart';

class RemoteMeetingRepository implements MeetingRepository {
  final ApiClient _client;

  RemoteMeetingRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  List<MeetingModel> _parseMeetingList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      if (data['content'] is List) {
        return (data['content'] as List)
            .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<List<MeetingModel>> getMeetings({
    String tab = 'all',
    int page = 0,
    int size = 20,
    String search = '',
  }) async {
    final query = <String, String>{
      'tab': tab,
      'page': page.toString(),
      'size': size.toString(),
    };
    if (search.isNotEmpty) {
      query['search'] = search;
    }

    final response = await _client.get(
      ApiConfig.meetingsEndpoint,
      queryParameters: query,
    );
    final data = _extractData(response);
    return _parseMeetingList(data);
  }

  @override
  Future<MeetingModel?> getMeetingById(String id) async {
    try {
      final response = await _client.get(ApiConfig.meetingDetailsEndpoint(id));
      final data = _extractData(response);
      if (data == null || data is! Map<String, dynamic>) return null;
      return MeetingModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MeetingModel?> getMeetingByCode(String code) async {
    try {
      final result = await joinMeetingByCode(code);
      final meetingId = result['meetingId'] ?? result['meeting_id'];
      if (meetingId != null && meetingId.toString().isNotEmpty) {
        return getMeetingById(meetingId.toString());
      }
      return null;
    } catch (_) {
      // Fallback: search in meetings list
      try {
        final list = await getMeetings(search: code);
        return list.firstWhere(
          (m) => m.joinCode.toLowerCase() == code.toLowerCase().trim(),
        );
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<List<ParticipantModel>> getMeetingParticipants(
    String meetingId,
  ) async {
    try {
      final response = await _client.get(
        ApiConfig.meetingParticipantsEndpoint(meetingId),
      );
      final data = _extractData(response);
      if (data is List) {
        return data
            .map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required MeetingType type,
    String? password,
    bool isChatAllowed = true,
    bool isScreenShareAllowed = true,
    bool isMuteOnEntry = false,
    bool isCameraAllowed = true,
  }) async {
    final req = CreateInstantMeetingRequest(
      title: title,
      description: description,
      password: password,
      allowParticipantChat: isChatAllowed,
      allowScreenSharing: isScreenShareAllowed,
      muteParticipantsOnEntry: isMuteOnEntry,
      allowParticipantVideo: isCameraAllowed,
      allowParticipantAudio: true,
      isOpenRoom: false,
    );

    final response = await _client.post(
      ApiConfig.meetingsEndpoint,
      body: req.toJson(),
    );
    final data = _extractData(response) as Map<String, dynamic>;
    return MeetingModel.fromJson(data);
  }

  @override
  Future<MeetingModel> scheduleMeeting({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes,
    required MeetingType type,
    required RepeatOption repeatOption,
    required String timezone,
    required int reminderMinutes,
    List<String> participantEmails = const [],
    String? password,
    bool isChatAllowed = true,
    bool isScreenShareAllowed = true,
    bool isMuteOnEntry = false,
    bool isCameraAllowed = true,
  }) async {
    final req = CreateScheduledMeetingRequest(
      title: title,
      description: description,
      scheduledStartTime: startTime,
      scheduledEndTime: startTime.add(Duration(minutes: durationMinutes)),
      durationMinutes: durationMinutes,
      timezone: timezone,
      reminderMinutes: reminderMinutes,
      recurrenceType: repeatOption.name.toUpperCase(),
      invitedEmails: participantEmails,
      password: password,
      allowParticipantChat: isChatAllowed,
      allowScreenSharing: isScreenShareAllowed,
      muteParticipantsOnEntry: isMuteOnEntry,
      allowParticipantVideo: isCameraAllowed,
      allowParticipantAudio: true,
    );

    final response = await _client.post(
      ApiConfig.meetingsEndpoint,
      body: req.toJson(),
    );
    final data = _extractData(response) as Map<String, dynamic>;
    return MeetingModel.fromJson(data);
  }

  @override
  Future<MeetingModel> updateMeeting(
    String meetingId,
    UpdateMeetingRequest request,
  ) async {
    final response = await _client.put(
      ApiConfig.meetingDetailsEndpoint(meetingId),
      body: request.toJson(),
    );
    final data = _extractData(response) as Map<String, dynamic>;
    return MeetingModel.fromJson(data);
  }

  @override
  Future<MeetingModel> startMeeting(String meetingId) async {
    final response = await _client.post(
      ApiConfig.meetingStartEndpoint(meetingId),
    );
    final data = _extractData(response) as Map<String, dynamic>;
    return MeetingModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> joinMeeting(
    String meetingId, {
    String? password,
  }) async {
    final body = <String, dynamic>{};
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final response = await _client.post(
      ApiConfig.meetingJoinEndpoint(meetingId),
      body: body,
    );
    final data = _extractData(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }

  @override
  Future<Map<String, dynamic>> joinMeetingByCode(
    String code, {
    String? password,
  }) async {
    final body = <String, dynamic>{'meetingCode': code.trim()};
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final response = await _client.post(ApiConfig.joinCodeEndpoint, body: body);
    final data = _extractData(response);
    return data is Map<String, dynamic> ? data : {'success': true};
  }

  @override
  Future<bool> leaveMeeting(String meetingId) async {
    try {
      await _client.post(ApiConfig.meetingLeaveEndpoint(meetingId));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<MeetingModel?> endMeeting(String meetingId) async {
    try {
      final response = await _client.post(
        ApiConfig.meetingEndEndpoint(meetingId),
      );
      final data = _extractData(response);
      if (data is Map<String, dynamic>) {
        return MeetingModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> cancelMeeting(String meetingId) async {
    return deleteMeeting(meetingId);
  }

  @override
  Future<bool> deleteMeeting(String meetingId) async {
    try {
      await _client.delete(ApiConfig.meetingDetailsEndpoint(meetingId));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<MeetingModel>> getRecentMeetings() async {
    return getMeetings(tab: 'past', size: 5);
  }
}

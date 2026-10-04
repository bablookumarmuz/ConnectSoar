import '../../core/config/api_config.dart';
import '../../features/meetings/domain/models/participant_model.dart';
import '../../features/meetings/domain/repositories/participant_repository.dart';
import 'api_client.dart';

class RemoteParticipantRepository implements ParticipantRepository {
  final ApiClient _client;

  RemoteParticipantRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  @override
  Future<List<ParticipantModel>> getParticipants(String meetingId) async {
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
  Future<ParticipantModel> inviteParticipant(
    String meetingId, {
    required String email,
    String role = 'PARTICIPANT',
  }) async {
    final response = await _client.post(
      ApiConfig.meetingParticipantsEndpoint(meetingId),
      body: {'email': email.trim(), 'role': role.toUpperCase()},
    );
    final data = _extractData(response);
    if (data is Map<String, dynamic>) {
      return ParticipantModel.fromJson(data);
    }
    return ParticipantModel(
      id: (data is Map ? data['id'] ?? data['user_id'] : '')?.toString() ?? '',
      userId:
          (data is Map ? data['user_id'] ?? data['userId'] : '')?.toString() ??
          '',
      name: email.split('@').first,
      email: email,
      avatarUrl: '',
      role: role.toUpperCase() == 'HOST'
          ? ParticipantRole.host
          : role.toUpperCase() == 'CO_HOST'
          ? ParticipantRole.coHost
          : ParticipantRole.attendee,
      status: 'INVITED',
    );
  }

  @override
  Future<ParticipantModel> addParticipant(
    String meetingId,
    String userId,
    String name,
    String avatarUrl,
    ParticipantRole role,
  ) async {
    return inviteParticipant(
      meetingId,
      email: name.contains('@') ? name : '$name@connectsoar.com',
      role: role == ParticipantRole.host
          ? 'HOST'
          : role == ParticipantRole.coHost
          ? 'CO_HOST'
          : 'PARTICIPANT',
    );
  }

  @override
  Future<bool> removeParticipant(
    String meetingId,
    String participantUserId,
  ) async {
    try {
      await _client.delete(
        ApiConfig.meetingParticipantDetailEndpoint(
          meetingId,
          participantUserId,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> updateAudioStatus(
    String meetingId,
    String participantId,
    bool isMuted,
  ) async {
    // Local hardware/client state
  }

  @override
  Future<void> updateVideoStatus(
    String meetingId,
    String participantId,
    bool isVideoOff,
  ) async {
    // Local hardware/client state
  }

  @override
  Future<void> updateHandRaisedStatus(
    String meetingId,
    String participantId,
    bool isHandRaised,
  ) async {
    // Local client state
  }

  @override
  Future<void> updateParticipantRole(
    String meetingId,
    String participantUserId,
    ParticipantRole newRole, {
    String? status,
  }) async {
    try {
      final roleStr = newRole == ParticipantRole.host
          ? 'HOST'
          : newRole == ParticipantRole.coHost
          ? 'CO_HOST'
          : 'PARTICIPANT';

      final body = <String, dynamic>{'participant_role': roleStr};
      if (status != null) {
        body['status'] = status;
      }

      await _client.patch(
        ApiConfig.meetingParticipantDetailEndpoint(
          meetingId,
          participantUserId,
        ),
        body: body,
      );
    } catch (_) {}
  }
}

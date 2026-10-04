import '../models/participant_model.dart';

abstract class ParticipantRepository {
  Future<List<ParticipantModel>> getParticipants(String meetingId);

  Future<ParticipantModel> inviteParticipant(
    String meetingId, {
    required String email,
    String role = 'PARTICIPANT',
  });

  Future<ParticipantModel> addParticipant(
    String meetingId,
    String userId,
    String name,
    String avatarUrl,
    ParticipantRole role,
  );

  Future<bool> removeParticipant(String meetingId, String participantUserId);

  Future<void> updateAudioStatus(
    String meetingId,
    String participantId,
    bool isMuted,
  );

  Future<void> updateVideoStatus(
    String meetingId,
    String participantId,
    bool isVideoOff,
  );

  Future<void> updateHandRaisedStatus(
    String meetingId,
    String participantId,
    bool isHandRaised,
  );

  Future<void> updateParticipantRole(
    String meetingId,
    String participantUserId,
    ParticipantRole newRole, {
    String? status,
  });
}

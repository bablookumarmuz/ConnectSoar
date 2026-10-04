import '../models/meeting_model.dart';
import '../models/participant_model.dart';

abstract class MeetingRepository {
  Future<List<MeetingModel>> getMeetings({
    String tab = 'all',
    int page = 0,
    int size = 20,
    String search = '',
  });

  Future<MeetingModel?> getMeetingById(String id);
  Future<MeetingModel?> getMeetingByCode(String code);
  Future<List<ParticipantModel>> getMeetingParticipants(String meetingId);

  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required MeetingType type,
    String? password,
    bool isChatAllowed = true,
    bool isScreenShareAllowed = true,
    bool isMuteOnEntry = false,
    bool isCameraAllowed = true,
  });

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
  });

  Future<MeetingModel> updateMeeting(
    String meetingId,
    UpdateMeetingRequest request,
  );
  Future<MeetingModel> startMeeting(String meetingId);
  Future<Map<String, dynamic>> joinMeeting(
    String meetingId, {
    String? password,
  });
  Future<Map<String, dynamic>> joinMeetingByCode(
    String code, {
    String? password,
  });
  Future<bool> leaveMeeting(String meetingId);
  Future<MeetingModel?> endMeeting(String meetingId);
  Future<bool> cancelMeeting(String meetingId);
  Future<bool> deleteMeeting(String meetingId);
  Future<List<MeetingModel>> getRecentMeetings();
}

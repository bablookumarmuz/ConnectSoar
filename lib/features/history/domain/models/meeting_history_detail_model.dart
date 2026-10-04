import '../../../meetings/domain/models/participant_model.dart';

class MeetingTimelineEvent {
  final String id;
  final String title;
  final DateTime timestamp;
  final String
  category; // e.g. "created", "started", "joined", "left", "screenshare_started", "screenshare_stopped", "ended"
  final String? participantName;
  final String? avatarUrl;
  final String? detail;

  const MeetingTimelineEvent({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.category,
    this.participantName,
    this.avatarUrl,
    this.detail,
  });
}

class MeetingHistoryDetailModel {
  final String id;
  final String meetingId;
  final String title;
  final String description;
  final String joinCode;
  final DateTime startTime;
  final DateTime endTime;
  final String hostName;
  final String hostAvatarUrl;
  final String type;
  final String summary;
  final int durationMinutes;
  final int screenShareDurationMinutes;
  final int chatMessageCount;
  final List<ParticipantModel> participants;
  final List<MeetingTimelineEvent> timelineEvents;

  const MeetingHistoryDetailModel({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.description,
    required this.joinCode,
    required this.startTime,
    required this.endTime,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.type,
    required this.summary,
    required this.durationMinutes,
    required this.screenShareDurationMinutes,
    required this.chatMessageCount,
    required this.participants,
    required this.timelineEvents,
  });
}

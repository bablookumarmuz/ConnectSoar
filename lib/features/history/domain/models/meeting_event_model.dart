class MeetingEventModel {
  final String id;
  final String meetingId;
  final String title;
  final DateTime timestamp;
  final String type;
  final String summary;
  final int durationMinutes;
  final int participantCount;

  const MeetingEventModel({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.timestamp,
    required this.type,
    required this.summary,
    required this.durationMinutes,
    required this.participantCount,
  });
}

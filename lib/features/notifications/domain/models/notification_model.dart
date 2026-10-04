enum NotificationType { meeting, invite, system, alert }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? actionUrl;
  final String? meetingId;
  final String? hostName;
  final String? meetingTime;
  final String? joinCode;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.actionUrl,
    this.meetingId,
    this.hostName,
    this.meetingTime,
    this.joinCode,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      actionUrl: actionUrl,
      meetingId: meetingId,
      hostName: hostName,
      meetingTime: meetingTime,
      joinCode: joinCode,
    );
  }
}

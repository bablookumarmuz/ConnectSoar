enum MessageType { text, system, file }

class ChatMessageModel {
  final String id;
  final String meetingId;
  final String threadId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final String? fileSize;
  final String? replyToMessageId;
  final String? replyToSenderName;
  final String? replyToMessageText;
  final Map<String, List<String>> reactions; // emoji -> list of userIds
  final List<String> mentions; // list of mentioned names/ids
  final bool isPinned;

  const ChatMessageModel({
    required this.id,
    required this.meetingId,
    String? threadId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.replyToMessageId,
    this.replyToSenderName,
    this.replyToMessageText,
    this.reactions = const {},
    this.mentions = const [],
    this.isPinned = false,
  }) : threadId = threadId ?? meetingId;

  ChatMessageModel copyWith({
    String? message,
    Map<String, List<String>>? reactions,
    List<String>? mentions,
    bool? isPinned,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToMessageText,
  }) {
    return ChatMessageModel(
      id: id,
      meetingId: meetingId,
      threadId: threadId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message ?? this.message,
      timestamp: timestamp,
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      replyToMessageText: replyToMessageText ?? this.replyToMessageText,
      reactions: reactions ?? this.reactions,
      mentions: mentions ?? this.mentions,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime ts = DateTime.now();
    final rawTs = json['createdAt'] ?? json['created_at'] ?? json['timestamp'];
    if (rawTs != null) {
      try {
        ts = DateTime.parse(rawTs.toString());
      } catch (_) {}
    }

    final sId =
        (json['senderUserId'] ??
                json['sender_user_id'] ??
                json['senderId'] ??
                json['sender_id'] ??
                '')
            .toString();
    final sName =
        (json['senderName'] ??
                json['sender_name'] ??
                json['senderEmail'] ??
                'User')
            .toString();
    final sAvatar = (json['senderAvatar'] ?? json['sender_avatar'] ?? '')
        .toString();
    final mId = (json['meetingId'] ?? json['meeting_id'] ?? '').toString();

    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      meetingId: mId,
      threadId: (json['threadId'] ?? json['thread_id'] ?? mId).toString(),
      senderId: sId,
      senderName: sName,
      senderAvatar: sAvatar,
      message: (json['message'] ?? '').toString(),
      timestamp: ts,
      type: MessageType.text,
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'senderUserId': senderId,
      'senderName': senderName,
      'message': message,
      'createdAt': timestamp.toIso8601String(),
    };
  }
}

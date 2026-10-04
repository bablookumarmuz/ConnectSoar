enum ChatThreadType { direct, meeting, channel }

class ChatThreadModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final ChatThreadType type;
  final String? meetingId;
  final String? otherUserId;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;
  final bool isOnline;

  const ChatThreadModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    required this.type,
    this.meetingId,
    this.otherUserId,
    this.participantIds = const [],
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isOnline = false,
  });

  ChatThreadModel copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isPinned,
    bool? isOnline,
  }) {
    return ChatThreadModel(
      id: id,
      title: title,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
      type: type,
      meetingId: meetingId,
      otherUserId: otherUserId,
      participantIds: participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

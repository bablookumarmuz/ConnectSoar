import '../../features/chat/domain/models/chat_message_model.dart';
import '../../features/chat/domain/models/chat_thread_model.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import 'api_client.dart';

class RemoteChatRepository implements ChatRepository {
  final ApiClient _client;

  RemoteChatRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  @override
  Future<List<ChatThreadModel>> getThreads() async {
    try {
      final response = await _client.get('/api/chat/threads');
      final data = _extractData(response);
      if (data is List) {
        return data.map((e) {
          final json = e as Map<String, dynamic>;
          return ChatThreadModel(
            id: (json['id'] as String?) ?? '',
            title: (json['title'] as String?) ?? 'Chat Thread',
            subtitle: json['subtitle'] as String?,
            avatarUrl: json['avatarUrl'] as String?,
            type: ChatThreadType.values.firstWhere(
              (t) =>
                  t.name.toLowerCase() ==
                  (json['type'] as String? ?? 'meeting').toLowerCase(),
              orElse: () => ChatThreadType.meeting,
            ),
            meetingId: json['meetingId'] as String?,
            otherUserId: json['otherUserId'] as String?,
            participantIds: List<String>.from(
              json['participantIds'] as List? ?? [],
            ),
            lastMessage: (json['lastMessage'] as String?) ?? 'No messages yet',
            lastMessageTime: json['lastMessageTime'] != null
                ? DateTime.parse(json['lastMessageTime'] as String)
                : DateTime.now(),
            unreadCount: json['unreadCount'] as int? ?? 0,
            isPinned: json['isPinned'] as bool? ?? false,
            isOnline: json['isOnline'] as bool? ?? false,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String id) async {
    try {
      dynamic response;
      try {
        response = await _client.get('/api/meetings/$id/messages');
      } catch (_) {
        response = await _client.get('/api/chat/threads/$id/messages');
      }

      final data = _extractData(response);
      if (data is List) {
        return data.map((e) {
          final json = e as Map<String, dynamic>;
          return ChatMessageModel.fromJson(json);
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String threadId,
    required String meetingId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String message,
    MessageType type = MessageType.text,
    String? fileName,
    String? fileSize,
    String? fileUrl,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToMessageText,
    List<String> mentions = const [],
  }) async {
    final isMeeting = meetingId.isNotEmpty;
    final path = isMeeting
        ? '/api/meetings/$meetingId/messages'
        : '/api/chat/threads/$threadId/messages';

    final body = isMeeting
        ? {'message': message}
        : {
            'message': message,
            'meetingId': meetingId,
            'type': type.name,
            'fileName': fileName,
            'fileSize': fileSize,
            'fileUrl': fileUrl,
            'replyToMessageId': replyToMessageId,
            'replyToSenderName': replyToSenderName,
            'replyToMessageText': replyToMessageText,
          };

    final response = await _client.post(path, body: body);
    final json = _extractData(response) as Map<String, dynamic>;

    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      meetingId: (json['meetingId'] ?? meetingId).toString(),
      threadId: (json['threadId'] ?? threadId).toString(),
      senderId: (json['senderUserId'] ?? json['senderId'] ?? senderId)
          .toString(),
      senderName: (json['senderName'] ?? senderName).toString(),
      senderAvatar: senderAvatar,
      message: (json['message'] ?? message).toString(),
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: type,
      fileName: fileName,
      fileSize: fileSize,
      fileUrl: fileUrl,
    );
  }

  @override
  Future<void> toggleReaction(
    String messageId,
    String emoji,
    String userId,
  ) async {
    // Reaction persistence endpoint hook
  }

  @override
  Future<void> togglePinMessage(String messageId) async {
    try {
      await _client.post('/api/chat/messages/$messageId/pin');
    } catch (_) {}
  }
}

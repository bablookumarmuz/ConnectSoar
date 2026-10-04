import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';

abstract class ChatRepository {
  Future<List<ChatThreadModel>> getThreads();
  Future<List<ChatMessageModel>> getMessages(String id);
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
  });
  Future<void> toggleReaction(String messageId, String emoji, String userId);
  Future<void> togglePinMessage(String messageId);
}

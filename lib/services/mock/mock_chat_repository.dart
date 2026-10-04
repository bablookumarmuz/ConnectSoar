import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chat/domain/models/chat_message_model.dart';
import '../../features/chat/domain/models/chat_thread_model.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import 'mock_data_generator.dart';

class MockChatRepository implements ChatRepository {
  final List<ChatThreadModel> _threads = List.from(
    MockDataGenerator.sampleChatThreads,
  );
  final List<ChatMessageModel> _messages = List.from(
    MockDataGenerator.sampleChatMessages,
  );

  @override
  Future<List<ChatThreadModel>> getThreads() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_threads);
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (id.isEmpty) return List.unmodifiable(_messages);
    final filtered = _messages
        .where((m) => m.threadId == id || m.meetingId == id)
        .toList();
    if (filtered.isEmpty) {
      // Return default meeting chat messages if not found directly by id
      return _messages
          .where(
            (m) => m.meetingId == 'mtg_live_1' || m.threadId == 'th_live_1',
          )
          .toList();
    }
    return filtered;
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
    await Future.delayed(const Duration(milliseconds: 100));
    final newMsg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      meetingId: meetingId,
      threadId: threadId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      fileName: fileName,
      fileSize: fileSize,
      fileUrl: fileUrl,
      replyToMessageId: replyToMessageId,
      replyToSenderName: replyToSenderName,
      replyToMessageText: replyToMessageText,
      mentions: mentions,
    );

    _messages.add(newMsg);

    // Update thread last message
    final threadIdx = _threads.indexWhere(
      (t) => t.id == threadId || t.meetingId == meetingId,
    );
    if (threadIdx != -1) {
      final t = _threads[threadIdx];
      _threads[threadIdx] = t.copyWith(
        lastMessage: type == MessageType.file
            ? 'Attached file: $fileName'
            : message,
        lastMessageTime: DateTime.now(),
      );
    }

    return newMsg;
  }

  @override
  Future<void> toggleReaction(
    String messageId,
    String emoji,
    String userId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final msg = _messages[idx];
      final currentReactions = Map<String, List<String>>.from(msg.reactions);
      final users = List<String>.from(currentReactions[emoji] ?? []);
      if (users.contains(userId)) {
        users.remove(userId);
        if (users.isEmpty) {
          currentReactions.remove(emoji);
        } else {
          currentReactions[emoji] = users;
        }
      } else {
        users.add(userId);
        currentReactions[emoji] = users;
      }
      _messages[idx] = msg.copyWith(reactions: currentReactions);
    }
  }

  @override
  Future<void> togglePinMessage(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final msg = _messages[idx];
      _messages[idx] = msg.copyWith(isPinned: !msg.isPinned);
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepository();
});

// StateNotifier for Chat Messages list for real-time reactivity
class ChatMessagesNotifier
    extends StateNotifier<AsyncValue<List<ChatMessageModel>>> {
  final ChatRepository _repo;
  final String _id;

  ChatMessagesNotifier(this._repo, this._id)
    : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getMessages(_id);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage({
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
    await _repo.sendMessage(
      threadId: _id,
      meetingId: _id,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message,
      type: type,
      fileName: fileName,
      fileSize: fileSize,
      fileUrl: fileUrl,
      replyToMessageId: replyToMessageId,
      replyToSenderName: replyToSenderName,
      replyToMessageText: replyToMessageText,
      mentions: mentions,
    );
    await loadMessages();
  }

  Future<void> toggleReaction(
    String messageId,
    String emoji,
    String userId,
  ) async {
    await _repo.toggleReaction(messageId, emoji, userId);
    await loadMessages();
  }

  Future<void> togglePinMessage(String messageId) async {
    await _repo.togglePinMessage(messageId);
    await loadMessages();
  }
}

final chatMessagesProvider =
    FutureProvider.family<List<ChatMessageModel>, String>((ref, id) async {
      final repo = ref.watch(chatRepositoryProvider);
      return repo.getMessages(id);
    });

final activeChatNotifierProvider =
    StateNotifierProvider.family<
      ChatMessagesNotifier,
      AsyncValue<List<ChatMessageModel>>,
      String
    >((ref, id) {
      final repo = ref.watch(chatRepositoryProvider);
      return ChatMessagesNotifier(repo, id);
    });

final chatThreadsProvider = FutureProvider<List<ChatThreadModel>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getThreads();
});

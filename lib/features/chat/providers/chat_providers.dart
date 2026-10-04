import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../services/mock/mock_chat_repository.dart';
import '../../../services/remote/api_client.dart';
import '../../../services/remote/remote_chat_repository.dart';
import '../domain/models/chat_message_model.dart';
import '../domain/models/chat_thread_model.dart';
import '../domain/repositories/chat_repository.dart';

export '../../../services/mock/mock_chat_repository.dart'
    show ChatMessagesNotifier;

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockChatRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteChatRepository(client);
});

final chatThreadsProvider = FutureProvider<List<ChatThreadModel>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getThreads();
});

final chatMessagesProvider =
    FutureProvider.family<List<ChatMessageModel>, String>((
      ref,
      threadId,
    ) async {
      final repo = ref.watch(chatRepositoryProvider);
      return repo.getMessages(threadId);
    });

final activeChatNotifierProvider =
    StateNotifierProvider.family<
      ChatMessagesNotifier,
      AsyncValue<List<ChatMessageModel>>,
      String
    >((ref, threadId) {
      final repo = ref.watch(chatRepositoryProvider);
      return ChatMessagesNotifier(repo, threadId);
    });

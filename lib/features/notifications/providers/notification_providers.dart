import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../services/mock/mock_notification_repository.dart';
import '../../../services/remote/api_client.dart';
import '../../../services/remote/remote_notification_repository.dart';
import '../domain/models/notification_model.dart';
import '../domain/repositories/notification_repository.dart';

export '../../../services/mock/mock_notification_repository.dart'
    show NotificationsNotifier;

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockNotificationRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteNotificationRepository(client);
});

final notificationsNotifierProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      return NotificationsNotifier(repo);
    });

final notificationsListProvider = FutureProvider<List<NotificationModel>>((
  ref,
) async {
  final asyncValue = ref.watch(notificationsNotifierProvider);
  return asyncValue.value ?? [];
});

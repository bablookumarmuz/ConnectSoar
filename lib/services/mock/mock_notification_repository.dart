import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/domain/models/notification_model.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import 'mock_data_generator.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<NotificationModel> _notifications = List.from(
    MockDataGenerator.sampleNotifications,
  );

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> clearAll() async {
    _notifications.clear();
  }

  @override
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
  }
}

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repo;

  NotificationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getNotifications();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    await load();
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    await load();
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    await load();
  }

  Future<void> removeNotification(String id) async {
    await _repo.removeNotification(id);
    await load();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
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
  final asyncVal = ref.watch(notificationsNotifierProvider);
  return asyncVal.when(
    data: (list) => list,
    loading: () => MockDataGenerator.sampleNotifications,
    error: (err, st) => [],
  );
});

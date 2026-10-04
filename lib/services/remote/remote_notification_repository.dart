import '../../features/notifications/domain/models/notification_model.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import 'api_client.dart';

class RemoteNotificationRepository implements NotificationRepository {
  final ApiClient _client;

  RemoteNotificationRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _client.get('/api/notifications');
      final data = _extractData(response);
      if (data is List) {
        return data.map((e) {
          final json = e as Map<String, dynamic>;
          return NotificationModel(
            id: (json['id'] as String?) ?? '',
            title: (json['title'] as String?) ?? 'Notification',
            message: (json['message'] as String?) ?? '',
            timestamp: json['timestamp'] != null
                ? DateTime.parse(json['timestamp'] as String)
                : DateTime.now(),
            isRead: json['isRead'] as bool? ?? false,
            type: NotificationType.values.firstWhere(
              (t) =>
                  t.name.toLowerCase() ==
                  (json['type'] as String? ?? 'system').toLowerCase(),
              orElse: () => NotificationType.system,
            ),
            actionUrl: json['actionUrl'] as String?,
            meetingId: json['meetingId'] as String?,
            hostName: json['hostName'] as String?,
            meetingTime: json['meetingTime'] as String?,
            joinCode: json['joinCode'] as String?,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _client.patch('/api/notifications/$id/read');
    } catch (_) {}
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _client.patch('/api/notifications/read-all');
    } catch (_) {}
  }

  @override
  Future<void> clearAll() async {
    try {
      await _client.delete('/api/notifications');
    } catch (_) {}
  }

  @override
  Future<void> removeNotification(String id) async {
    try {
      await _client.delete('/api/notifications/$id');
    } catch (_) {}
  }
}

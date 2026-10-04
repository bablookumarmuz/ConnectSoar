import '../../features/audit_log/domain/models/audit_log_model.dart';
import '../../features/audit_log/domain/repositories/audit_log_repository.dart';
import '../../features/auth/domain/models/user_model.dart';
import 'api_client.dart';

class RemoteAuditLogRepository implements AuditLogRepository {
  final ApiClient _client;

  RemoteAuditLogRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  @override
  Future<List<AuditLogModel>> getAuditLogs({
    String? searchQuery,
    String? actionFilter,
    String? userFilter,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['query'] = searchQuery;
      }
      if (actionFilter != null && actionFilter.isNotEmpty) {
        queryParams['action'] = actionFilter;
      }
      if (userFilter != null && userFilter.isNotEmpty) {
        queryParams['user'] = userFilter;
      }

      final response = await _client.get(
        '/api/audit-logs',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = _extractData(response);

      if (data is List) {
        return data.map((e) {
          final json = e as Map<String, dynamic>;
          return AuditLogModel(
            id: (json['id'] as String?) ?? '',
            timestamp: json['timestamp'] != null
                ? DateTime.parse(json['timestamp'] as String)
                : DateTime.now(),
            userId: (json['userId'] as String?) ?? '',
            userName: (json['userName'] as String?) ?? 'System User',
            userEmail: (json['userEmail'] as String?) ?? '',
            userAvatarUrl: (json['userAvatarUrl'] as String?) ?? '',
            userRole: UserRole.values.firstWhere(
              (r) =>
                  r.name.toLowerCase() ==
                  (json['userRole'] as String? ?? 'employee').toLowerCase(),
              orElse: () => UserRole.employee,
            ),
            action: (json['action'] as String?) ?? 'UNKNOWN_ACTION',
            category: AuditActionCategory.values.firstWhere(
              (c) =>
                  c.name.toLowerCase() ==
                  (json['category'] as String? ?? 'userauth').toLowerCase(),
              orElse: () => AuditActionCategory.userAuth,
            ),
            meetingId: json['meetingId'] as String?,
            meetingTitle: json['meetingTitle'] as String?,
            ipAddress: (json['ipAddress'] as String?) ?? '127.0.0.1',
            device: (json['device'] as String?) ?? 'ConnectSoar App',
            location: (json['location'] as String?) ?? 'Local Network',
            metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
          );
        }).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}

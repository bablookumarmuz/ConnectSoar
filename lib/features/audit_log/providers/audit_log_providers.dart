import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../services/mock/mock_audit_log_repository.dart';
import '../../../services/remote/api_client.dart';
import '../../../services/remote/remote_audit_log_repository.dart';
import '../domain/models/audit_log_model.dart';
import '../domain/repositories/audit_log_repository.dart';

class AuditLogFilter {
  final String query;
  final String action;
  final String user;

  const AuditLogFilter({
    this.query = '',
    this.action = 'ALL',
    this.user = 'ALL',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          action == other.action &&
          user == other.user;

  @override
  int get hashCode => Object.hash(query, action, user);
}

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockAuditLogRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteAuditLogRepository(client);
});

final auditLogsProvider =
    FutureProvider.family<List<AuditLogModel>, AuditLogFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.watch(auditLogRepositoryProvider);
      return repo.getAuditLogs(
        searchQuery: filter.query.isEmpty ? null : filter.query,
        actionFilter: filter.action == 'ALL' ? null : filter.action,
        userFilter: filter.user == 'ALL' ? null : filter.user,
      );
    });

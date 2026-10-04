import '../models/audit_log_model.dart';

abstract class AuditLogRepository {
  Future<List<AuditLogModel>> getAuditLogs({
    String? searchQuery,
    String? actionFilter,
    String? userFilter,
  });
}

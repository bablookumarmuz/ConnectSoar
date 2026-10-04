import '../../features/auth/domain/models/user_model.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import 'api_client.dart';

class RemoteUserRepository implements UserRepository {
  final ApiClient _client;

  RemoteUserRepository(this._client);

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _client.get('/api/v1/auth/me');
    final data = _extractData(response);
    if (data is Map<String, dynamic> && data.containsKey('user')) {
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }
    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    throw const ApiException(
      statusCode: 401,
      message: 'Failed to load user profile',
    );
  }

  @override
  void setCurrentUserIndex(int index) {
    // No-op for remote production repository
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      dynamic response;
      try {
        response = await _client.get('/api/v1/users');
      } catch (_) {
        response = await _client.get('/api/users');
      }
      final data = _extractData(response);
      List<dynamic>? userList;
      if (data is List) {
        userList = data;
      } else if (data is Map<String, dynamic>) {
        if (data['users'] is List) {
          userList = data['users'] as List;
        } else if (data['items'] is List) {
          userList = data['items'] as List;
        }
      }

      if (userList != null && userList.isNotEmpty) {
        return userList
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // If backend returns empty directory or 404, provide current user as active directory member
      final current = await getCurrentUser();
      return [current];
    } catch (_) {
      try {
        final current = await getCurrentUser();
        return [current];
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await _client.get('/api/users/$id');
      final data = _extractData(response);
      if (data == null || data is! Map<String, dynamic>) return null;
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> updateUserRole(String userId, UserRole role) async {
    final response = await _client.put(
      '/api/users/$userId/role',
      body: {'role': role.name},
    );
    final data = _extractData(response) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import 'mock_data_generator.dart';

class MockUserRepository implements UserRepository {
  final List<UserModel> _users = List.from(MockDataGenerator.sampleUsers);
  int _currentUserIndex = 0; // Default: Admin Alex Vance

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users[_currentUserIndex];
  }

  @override
  void setCurrentUserIndex(int index) {
    if (index >= 0 && index < _users.length) {
      _currentUserIndex = index;
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_users);
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users.firstWhere((u) => u.id == id);
  }

  @override
  Future<UserModel> updateUserRole(String userId, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = UserModel(
        id: _users[index].id,
        name: _users[index].name,
        email: _users[index].email,
        avatarUrl: _users[index].avatarUrl,
        role: role,
        status: _users[index].status,
        department: _users[index].department,
        title: _users[index].title,
      );
      _users[index] = updated;
      return updated;
    }
    throw Exception('User not found');
  }
}

// --- Riverpod Providers ---
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});

final selectedUserIndexProvider = StateProvider<int>((ref) => 0);

final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final index = ref.watch(selectedUserIndexProvider);
  repo.setCurrentUserIndex(index);
  return repo.getCurrentUser();
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getAllUsers();
});

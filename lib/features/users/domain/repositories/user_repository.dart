import 'package:connectsoar/features/auth/domain/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getCurrentUser();
  Future<List<UserModel>> getAllUsers();
  Future<UserModel?> getUserById(String id);
  Future<UserModel> updateUserRole(String userId, UserRole role);
  void setCurrentUserIndex(int index);
}

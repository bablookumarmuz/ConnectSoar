import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../services/mock/mock_user_repository.dart';
import '../../../services/remote/api_client.dart';
import '../../../services/remote/remote_user_repository.dart';
import '../../auth/domain/models/user_model.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockUserRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteUserRepository(client);
});

final selectedUserIndexProvider = StateProvider<int>((ref) => 0);

final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final sessionUser = await authRepo.getSessionUser();
  if (sessionUser != null) {
    return sessionUser;
  }
  final repo = ref.watch(userRepositoryProvider);
  return repo.getCurrentUser();
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getAllUsers();
});

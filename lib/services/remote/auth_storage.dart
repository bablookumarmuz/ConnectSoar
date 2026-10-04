import '../../core/storage/secure_storage_service.dart';

/// Adapter preserving backwards compatibility for components referencing AuthStorage
class AuthStorage {
  final SecureStorageService _secureStorage;

  AuthStorage([SecureStorageService? storage])
    : _secureStorage = storage ?? SecureStorageService();

  Future<void> saveToken(String token) async {
    await _secureStorage.saveAccessToken(token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.getAccessToken();
  }

  Future<void> clearToken() async {
    await _secureStorage.clearTokens();
  }
}

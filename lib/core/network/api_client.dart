import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  final HttpClient _httpClient;
  final SecureStorageService _storage;
  String? _authToken;

  // Single-flight refresh token mutex
  Completer<bool>? _refreshCompleter;

  // Callback on session expiration (when refresh fails)
  void Function()? onSessionExpired;

  ApiClient({SecureStorageService? storage})
    : _httpClient = HttpClient(),
      _storage = storage ?? SecureStorageService() {
    _httpClient.connectionTimeout = ApiConfig.connectTimeout;
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get currentAuthToken => _authToken;

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      'PUT',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      'DELETE',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Sends request with automatic token refresh on 401 (retrying once).
  Future<dynamic> _requestWithRetry(
    String method,
    String path, {
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    // If no in-memory token, check storage
    if (_authToken == null) {
      final storedToken = await _storage.getAccessToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        _authToken = storedToken;
      }
    }

    try {
      return await _sendRequest(
        method,
        path,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
      );
    } on ApiException catch (e) {
      // Refresh only on 401 for authenticated requests (not login or refresh itself)
      final isAuthEndpoint =
          path.contains(ApiConfig.loginEndpoint) ||
          path.contains(ApiConfig.refreshEndpoint);

      if (e.statusCode == 401 && !isAuthEndpoint) {
        final refreshSuccess = await _handleTokenRefresh();
        if (refreshSuccess) {
          // Retry original request ONCE with new access token
          return await _sendRequest(
            method,
            path,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
          );
        }
      }
      rethrow;
    }
  }

  /// Safely coordinates a single refresh call across concurrent requests
  Future<bool> _handleTokenRefresh() async {
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearSession();
        completer.complete(false);
        return false;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshEndpoint}');
      _logSafe('POST', uri.path, '[Refresh Attempt]');

      final request = await _httpClient.openUrl('POST', uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(
        jsonEncode({
          'refresh_token': refreshToken,
          'refreshToken': refreshToken,
        }),
      );

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(responseBody);
      } catch (_) {
        jsonResponse = null;
      }

      _logSafe('POST', uri.path, 'Status ${response.statusCode}');

      if (response.statusCode == 200 && jsonResponse is Map<String, dynamic>) {
        final data = jsonResponse['data'] is Map<String, dynamic>
            ? jsonResponse['data'] as Map<String, dynamic>
            : jsonResponse;
        final newAccessToken =
            (data['access_token'] ?? data['accessToken']) as String?;
        final newRefreshToken =
            (data['refresh_token'] ?? data['refreshToken']) as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          _authToken = newAccessToken;
          await _storage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          completer.complete(true);
          return true;
        }
      }

      // Refresh failed or returned non-200 (e.g. TOKEN_INVALID)
      await _clearSession();
      onSessionExpired?.call();
      completer.complete(false);
      return false;
    } catch (_) {
      await _clearSession();
      onSessionExpired?.call();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _clearSession() async {
    _authToken = null;
    await _storage.clearTokens();
  }

  Future<dynamic> _sendRequest(
    String method,
    String path, {
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: queryParameters);

    _logSafe(method, uri.path, '[Initiated]');

    try {
      final request = await _httpClient.openUrl(method, uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      if (_authToken != null && _authToken!.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $_authToken',
        );
      }

      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(ApiConfig.receiveTimeout);
      final responseBody = await response.transform(utf8.decoder).join();

      dynamic jsonResponse;
      if (responseBody.isNotEmpty) {
        try {
          jsonResponse = jsonDecode(responseBody);
        } catch (_) {
          jsonResponse = responseBody;
        }
      }

      _logSafe(method, uri.path, 'Status ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonResponse;
      }

      // Parse structured API error format:
      // { "success": false, "error": { "code": "...", "message": "..." }, "data": { ... } }
      String? errorCode;
      String errorMessage = 'HTTP Error ${response.statusCode}';
      dynamic errorData;

      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['error'] is Map<String, dynamic>) {
          final errMap = jsonResponse['error'] as Map<String, dynamic>;
          errorCode = errMap['code'] as String?;
          errorMessage = errMap['message'] as String? ?? errorMessage;
        } else if (jsonResponse['message'] != null) {
          errorMessage = jsonResponse['message'].toString();
        }
        errorData = jsonResponse['data'];
      }

      throw ApiException(
        statusCode: response.statusCode,
        code: errorCode,
        message: errorMessage,
        data: errorData,
      );
    } on SocketException catch (e) {
      _logSafe(
        method,
        uri.path,
        'Network SocketException: ${e.osError?.message ?? e.message}',
      );
      throw ApiException(
        statusCode: 0,
        message:
            'Network connection failed. Please check your internet connection.',
      );
    } on TimeoutException {
      _logSafe(method, uri.path, 'Request Timeout');
      throw const ApiException(
        statusCode: 408,
        message: 'Request timed out. Please try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      _logSafe(method, uri.path, 'Unexpected error: $e');
      throw ApiException(
        statusCode: 500,
        message: 'An unexpected connection error occurred: $e',
      );
    }
  }

  /// Strictly redact all sensitive data. NEVER log passwords, tokens, or auth headers.
  void _logSafe(String method, String endpoint, String detail) {
    // ignore: avoid_print
    print('[ApiClient] $method $endpoint -> $detail');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

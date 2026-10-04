import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_config.dart';

enum AppEnvironment { dev, staging, production }

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final String apiVersion;
  final bool enableLogging;
  final bool useMockData;
  final Duration connectTimeout;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    this.apiVersion = 'v1',
    this.enableLogging = true,
    this.useMockData = false,
    this.connectTimeout = ApiConfig.connectTimeout,
  });

  /// Centralized default configuration pointing to the real Render backend
  static const AppConfig standard = AppConfig(
    environment: AppEnvironment.production,
    apiBaseUrl: ApiConfig.baseUrl,
    wsBaseUrl: 'wss://connectsoar-backend.onrender.com/ws',
    apiVersion: 'v1',
    enableLogging: true,
    useMockData: false,
  );

  static AppConfig get dev => standard;
  static AppConfig get staging => standard;
  static AppConfig get production => standard;

  String get name => environment.name.toUpperCase();
}

/// Provider for application environment configuration.
/// Defaults to standard real Render backend with useMockData = false.
final appConfigProvider = StateProvider<AppConfig>((ref) {
  return AppConfig.standard;
});

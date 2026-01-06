import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final String apiBaseUrl;
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnv() {
    const base = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (base.isNotEmpty) return AppConfig(apiBaseUrl: base);

    if (kReleaseMode) {
      throw StateError('Missing --dart-define=API_BASE_URL');
    }
    return const AppConfig(apiBaseUrl: 'http://localhost:8080/v1');
  }
}

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnv());


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/user.dart';

class AuthApi {
  final ApiClient _api;
  AuthApi(this._api);

  Future<(String token, User user)> register({
    required String fullName,
    required String email,
    required String password,
    required String language,
    required String? timezone,
  }) async {
    final json = await _api.postJson(
      '/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'language': language,
        if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
      },
    );
    return (_token(json), User.fromJson(json['user'] as Map<String, dynamic>));
  }

  Future<(String token, User user)> login({required String email, required String password}) async {
    final json = await _api.postJson('/auth/login', body: {'email': email, 'password': password});
    return (_token(json), User.fromJson(json['user'] as Map<String, dynamic>));
  }

  String _token(Map<String, dynamic> json) => (json['token'] ?? '').toString();
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));

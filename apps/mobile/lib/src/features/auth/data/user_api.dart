import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/user.dart';
import 'dart:convert';

class UserApi {
  final ApiClient _api;
  UserApi(this._api);

  Future<User> me(String token) async {
    final json = await _api.getJson('/me', token: token);
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<User> patchMe(String token, Map<String, dynamic> patch) async {
    final json = await _api.patchJson('/me', token: token, body: patch);
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<User> uploadAvatar(String token, {required List<int> bytes, required String filename, required String mime}) async {
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    final json = await _api.postJson('/profile/avatar', token: token, body: {'dataUrl': dataUrl});
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }
}

final userApiProvider = Provider<UserApi>((ref) => UserApi(ref.watch(apiClientProvider)));

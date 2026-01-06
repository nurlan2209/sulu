import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  return Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
});

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  Options _auth(String? token) {
    if (token == null || token.isEmpty) return Options();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Map<String, dynamic>> getJson(String path, {String? token, Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query, options: _auth(token));
      return _asJsonMap(res.data);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Map<String, dynamic>> postJson(String path, {String? token, Object? body}) async {
    try {
      final res = await _dio.post(path, data: body, options: _auth(token));
      return _asJsonMap(res.data);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Map<String, dynamic>> patchJson(String path, {String? token, Object? body}) async {
    try {
      final res = await _dio.patch(path, data: body, options: _auth(token));
      return _asJsonMap(res.data);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Map<String, dynamic>> postMultipart(String path, {String? token, required FormData formData}) async {
    try {
      final res = await _dio.post(path, data: formData, options: _auth(token));
      return _asJsonMap(res.data);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return json.decode(data) as Map<String, dynamic>;
    throw const ApiException(code: 'invalid_response', message: 'Invalid server response');
  }

  ApiException _mapDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final err = data['error'];
      if (err is Map<String, dynamic>) {
        final code = (err['code'] ?? 'api_error').toString();
        final msg = (err['message'] ?? 'API error').toString();
        return ApiException(code: code, message: msg, status: status, details: err['details']);
      }
    }
    return ApiException(code: 'network_error', message: e.message ?? 'Network error', status: status);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));

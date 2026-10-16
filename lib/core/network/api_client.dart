import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/app_failure.dart';
import 'session_store.dart';

class ApiClient {
  ApiClient(this._dio, this._sessionStore) {
    _dio.options = BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 10),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStore.accessToken;
          if (token != null && options.extra['authenticated'] != false) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }
  }

  final Dio _dio;
  final SessionStore _sessionStore;
  final _sessionExpiredController = StreamController<void>.broadcast();

  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'authenticated': authenticated}),
      );
      return response.data ?? <String, dynamic>{};
    } catch (error) {
      throw await _mapAndHandle(error);
    }
  }

  Future<List<dynamic>> getList(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(path);
      return response.data ?? <dynamic>[];
    } catch (error) {
      throw await _mapAndHandle(error);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
    bool authenticated = true,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(extra: {'authenticated': authenticated}),
      );
      return response.data ?? <String, dynamic>{};
    } catch (error) {
      throw await _mapAndHandle(error);
    }
  }

  Future<AppFailure> _mapAndHandle(Object error) async {
    final failure = mapNetworkError(error);
    if (failure.type == FailureType.unauthorized) {
      await _sessionStore.clear();
      _sessionExpiredController.add(null);
    }
    return failure;
  }
}

AppFailure mapNetworkError(Object error) {
  if (error is AppFailure) return error;
  if (error is SocketException) {
    return const AppFailure(
      'You appear to be offline. Check your connection and retry.',
      type: FailureType.network,
    );
  }
  if (error is TimeoutException) {
    return const AppFailure(
      'The request took too long. Please retry.',
      type: FailureType.timeout,
    );
  }
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppFailure(
        'The request took too long. Please retry.',
        type: FailureType.timeout,
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return const AppFailure(
        'You appear to be offline. Check your connection and retry.',
        type: FailureType.network,
      );
    }
    final status = error.response?.statusCode;
    final serverMessage = error.response?.data is Map
        ? (error.response?.data as Map)['message']?.toString()
        : null;
    if (status == 400) {
      return AppFailure(
        serverMessage ?? 'Please check the submitted information.',
      );
    }
    if (status == 401 || status == 403) {
      return const AppFailure(
        'Your session has expired. Please sign in again.',
        type: FailureType.unauthorized,
      );
    }
    if (status == 404) {
      return const AppFailure(
        'The requested item could not be found.',
        type: FailureType.notFound,
      );
    }
    if (status != null && status >= 500) {
      return const AppFailure(
        'The server is having trouble. Please retry shortly.',
        type: FailureType.server,
      );
    }
  }
  return const AppFailure('Something unexpected happened. Please retry.');
}

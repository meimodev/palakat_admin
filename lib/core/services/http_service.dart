import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_service.g.dart';

/// HTTP service configuration with Dio and logging interceptor
class HttpService {
  late final Dio _dio;

  HttpService({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://api.example.com', // Replace with your API base URL
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      sendTimeout: sendTimeout ?? const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  /// Setup interceptors for logging and error handling
  void _setupInterceptors() {
    // Pretty logger interceptor for debugging
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          enabled: true, // Set to false in production
        ),
      );
    }

    // Custom error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Log error details
          dev.log('HTTP Error: ${error.message}',
              name: 'HttpService', level: 1000, error: error);
          if (error.response != null) {
            dev.log('Status Code: ${error.response?.statusCode}',
                name: 'HttpService', level: 1000);
            dev.log('Response Data: ${error.response?.data}',
                name: 'HttpService', level: 1000);
          }
          
          // Continue with the error
          handler.next(error);
        },
        onRequest: (options, handler) {
          // Add authentication headers if needed
          // options.headers['Authorization'] = 'Bearer $token';
          
          dev.log('Request: ${options.method} ${options.path}',
              name: 'HttpService', level: 800);
          handler.next(options);
        },
        onResponse: (response, handler) {
          dev.log('Response: ${response.statusCode} ${response.requestOptions.path}',
              name: 'HttpService', level: 800);
          handler.next(response);
        },
      ),
    );
  }

  /// Get configured Dio instance
  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Riverpod provider for HttpService
@riverpod
HttpService httpService(Ref ref) {
  return HttpService(
    baseUrl: 'https://jsonplaceholder.typicode.com', // Example API for testing
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  );
}

/// Provider for Dio instance
@riverpod
Dio dioInstance(Ref ref) {
  final httpService = ref.watch(httpServiceProvider);
  return httpService.dio;
}

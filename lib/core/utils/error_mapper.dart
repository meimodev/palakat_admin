import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/app_error.dart';

/// Centralized error mapping utilities
class ErrorMapper {
  /// Map DioException to AppError with a contextual message
  static AppError fromDio(DioException error, String message, [StackTrace? st]) {
    dev.log('Dio error: $message: $error', error: error, name: 'ErrorMapper', stackTrace: st);
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError.network('$message: Request timeout', details: error.message);
      case DioExceptionType.badResponse:
        return AppError.serverError(
          '$message: Server error',
          statusCode: error.response?.statusCode,
          details: 'Status: ${error.response?.statusCode}, Data: ${error.response?.data}',
        );
      case DioExceptionType.cancel:
        return AppError.network('$message: Request cancelled', details: error.message);
      case DioExceptionType.connectionError:
        return AppError.network('$message: Connection error', details: 'Please check your internet connection');
      case DioExceptionType.badCertificate:
        return AppError.network('$message: SSL certificate error', details: error.message);
      case DioExceptionType.unknown:
        return AppError.network('$message: Unknown error', details: error.message);
    }
  }

  /// Wrap an unknown error with AppError.unknown and context message
  static AppError unknown(String message, Object error, {StackTrace? st}) {
    dev.log('Unknown error: $message: $error', error: error, name: 'ErrorMapper', stackTrace: st);
    return AppError.unknown('$message: $error', details: "");
  }
}

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_error.dart';
import 'http_service.dart';
import 'package:palakat_admin/core/utils/error_mapper.dart';

part 'api_service.g.dart';

class ApiService {
  final HttpService _httpService;

  ApiService(this._httpService);

  Future<void> deleteActivity(String activityId) async {
    try {
      final response = await _httpService.delete('/posts/$activityId');

      if (response.statusCode != 200) {
        throw AppError.network(
          'Failed to delete activity',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete activity');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to delete activity', e, st);
    }
  }

  /// Get approval rules with pagination
  Future<Map<String, dynamic>> getApprovalRules(Map<String, dynamic> queryParams) async {
    try {
      final response = await _httpService.get(
        '/approval-rule',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw AppError.network(
          'Failed to fetch approval rules',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch approval rules');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch approval rules', e, st);
    }
  }

  /// Create a new approval rule
  Future<Map<String, dynamic>> createApprovalRule(Map<String, dynamic> data) async {
    try {
      final response = await _httpService.post('/approval-rule', data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw AppError.network(
          'Failed to create approval rule',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create approval rule');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to create approval rule', e, st);
    }
  }

  /// Update an existing approval rule
  Future<Map<String, dynamic>> updateApprovalRule(
    int ruleId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpService.put(
        '/approval-rule/$ruleId',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw AppError.network(
          'Failed to update approval rule',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update approval rule');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to update approval rule', e, st);
    }
  }

  /// Delete an approval rule
  Future<void> deleteApprovalRule(int ruleId) async {
    try {
      final response = await _httpService.delete('/approval-rule/$ruleId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw AppError.network(
          'Failed to delete approval rule',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete approval rule');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to delete approval rule', e, st);
    }
  }

  /// Get membership positions with pagination
  Future<Map<String, dynamic>> getMembershipPositions(Map<String, dynamic> queryParams) async {
    try {
      final response = await _httpService.get(
        '/membership-position',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw AppError.network(
          'Failed to fetch positions',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch positions');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch positions', e, st);
    }
  }
}

/// Riverpod provider for ApiService
@riverpod
ApiService apiService(Ref ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ApiService(httpService);
}

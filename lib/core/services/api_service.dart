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
    } catch (e) {
      throw ErrorMapper.unknown('Failed to delete activity', e);
    }
  }

  Future<List<Map<String, dynamic>>> getApprovalRules() async {
    try {
      // For demo purposes, using JSONPlaceholder API
      // Replace with your actual API endpoints
      final response = await _httpService.get('/users');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Convert users to approval rules for demo
        return data
            .map(
              (json) => {
                'id': json['id'].toString(),
                'name': 'Approval Rule ${json['id']}',
                'description': 'Rule managed by ${json['name']}',
                'isActive': json['id'] % 2 == 1,
                'conditions': [
                  'Budget > \$${json['id'] * 100}',
                  'Location: ${json['address']['city']}',
                ],
                'approvers': [json['name']],
                'createdAt': DateTime.now()
                    .subtract(Duration(days: json['id']))
                    .toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
            )
            .toList();
      } else {
        throw AppError.network(
          'Failed to fetch approval rules',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch approval rules');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch approval rules', e);
    }
  }
}

/// Riverpod provider for ApiService
@riverpod
ApiService apiService(Ref ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ApiService(httpService);
}

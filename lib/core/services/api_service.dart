import 'package:dio/dio.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity.dart';
import '../models/app_error.dart';
import 'http_service.dart';
import 'package:palakat_admin/core/utils/error_mapper.dart';

part 'api_service.g.dart';

/// API service for handling HTTP requests to the backend
class ApiService {
  final HttpService _httpService;

  ApiService(this._httpService);

  /// Fetch all activities from the API
  Future<List<Activity>> getActivities() async {
    try {
      // For demo purposes, using JSONPlaceholder API
      // Replace with your actual API endpoints
      final response = await _httpService.get('/posts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Convert JSONPlaceholder posts to Activity objects for demo
        return data
            .map(
              (json) => Activity(
                id: json['id'].toString(),
                title: json['title'] ?? 'Unknown Activity',
                description: json['body'] ?? 'No description available',
                startDate: DateTime.now().subtract(
                  Duration(days: json['id'] % 30),
                ),
                status: ActivityStatus
                    .values[json['id'] % ActivityStatus.values.length],
                location: 'Location ${json['id']}',
                supervisor: 'User ${json['userId']}',
                supervisorPositions: ['Supervisor'],
                participants: List.generate(
                  (json['id'] % 5) + 1,
                  (index) => 'Participant ${index + 1}',
                ),
                type: ActivityType
                    .values[json['id'] % ActivityType.values.length],
                notes: 'Notes for activity ${json['id']}',
                createdAt: DateTime.now().subtract(
                  Duration(days: json['id'] % 30),
                ),
                updatedAt: DateTime.now(),
              ),
            )
            .toList();
      } else {
        throw AppError.network(
          'Failed to fetch activities',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch activities');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch activities', e);
    }
  }

  /// Create a new activity
  Future<Activity> createActivity(Activity activity) async {
    try {
      final response = await _httpService.post(
        '/posts',
        data: {
          'title': activity.title,
          'body': activity.description,
          'userId': 1, // Demo user ID
        },
      );

      if (response.statusCode == 201) {
        final json = response.data;
        return Activity(
          id: json['id'].toString(),
          title: activity.title,
          description: activity.description,
          startDate: activity.startDate,
          status: activity.status,
          location: activity.location,
          supervisor: activity.supervisor,
          supervisorPositions: activity.supervisorPositions,
          participants: activity.participants,
          type: activity.type,
          notes: activity.notes,
          createdAt: activity.createdAt,
          updatedAt: DateTime.now(),
        );
      } else {
        throw AppError.network(
          'Failed to create activity',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create activity');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to create activity', e);
    }
  }

  /// Update an existing activity
  Future<Activity> updateActivity(Activity activity) async {
    try {
      final response = await _httpService.put(
        '/posts/${activity.id ?? ''}',
        data: {
          'id': int.tryParse(activity.id ?? '') ?? 1,
          'title': activity.title,
          'body': activity.description,
          'userId': 1, // Demo user ID
        },
      );

      if (response.statusCode == 200) {
        return activity;
      } else {
        throw AppError.network(
          'Failed to update activity',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update activity');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to update activity', e);
    }
  }

  /// Delete an activity
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

  /// Fetch approval rules from the API
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

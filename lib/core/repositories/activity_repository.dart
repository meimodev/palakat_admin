import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity.dart';
import '../models/app_error.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'activity_repository.g.dart';

@riverpod
ActivityRepository activityRepository(Ref ref) => ActivityRepository(ref);

class ActivityRepository {
  ActivityRepository(this._ref);

  final Ref _ref;

  Future<PaginationResponseWrapper<Activity>> fetchActivities({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.activities,
        queryParameters: query,
      );

      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => Activity.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch activities');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch activities', e,  st);
    }
  }

  Future<Activity> fetchActivity({required int activityId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.activity(activityId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid activity response payload');
      }
      return Activity.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch activity');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch activity', e, st);
    }
  }

  Future<Activity> updateActivity({
    required int activityId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.activity(activityId.toString()),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update activity response payload');
      }

      return Activity.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update activity');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to update activity', e, st);
    }
  }

  Future<Activity> createActivity({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.activities,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid create activity response payload');
      }
      return Activity.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create activity');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to create activity', e, st);
    }
  }

  Future<void> deleteActivity({required int activityId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.activity(activityId.toString()));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete activity');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to delete activity', e, st);
    }
  }

}

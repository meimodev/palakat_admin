import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/revenue.dart';
import '../models/app_error.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'revenue_repository.g.dart';

@riverpod
RevenueRepository revenueRepository(Ref ref) => RevenueRepository(ref);

class RevenueRepository {
  RevenueRepository(this._ref);

  final Ref _ref;

  Future<PaginationResponseWrapper<Revenue>> fetchRevenues({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.revenues,
        queryParameters: query,
      );

      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => Revenue.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch revenue');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch revenue', e, st);
    }
  }

  Future<Revenue> fetchRevenue({required int revenueId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.revenue(revenueId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid revenue response payload');
      }
      return Revenue.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch revenue');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch revenue', e, st);
    }
  }

  Future<Revenue> updateRevenue({
    required int revenueId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.revenue(revenueId.toString()),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update revenue response payload');
      }

      return Revenue.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update revenue');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to update revenue', e, st);
    }
  }

  Future<Revenue> createRevenue({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.revenues,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid create revenue response payload');
      }
      return Revenue.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create revenue');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to create revenue', e, st);
    }
  }

  Future<void> deleteRevenue({required int revenueId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.revenue(revenueId.toString()));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete revenue');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to delete revenue', e, st);
    }
  }

}

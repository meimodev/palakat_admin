import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/report.dart';
import '../models/app_error.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'report_repository.g.dart';

@riverpod
ReportRepository reportRepository(Ref ref) => ReportRepository(ref);

class ReportRepository {
  ReportRepository(this._ref);

  final Ref _ref;

  Future<PaginationResponseWrapper<Report>> fetchReports({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.reports,
        queryParameters: query,
      );

      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => Report.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch reports');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch reports', e, st);
    }
  }

  Future<Report> fetchReport({required int reportId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.report(reportId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid report response payload');
      }
      return Report.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch report');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch report', e, st);
    }
  }

  Future<Report> generateReport({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.reports,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid generate report response payload');
      }
      return Report.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to generate report');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to generate report', e, st);
    }
  }

  Future<void> deleteReport({required int reportId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.report(reportId.toString()));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete report');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to delete report', e, st);
    }
  }

  Future<String> downloadReport({required int reportId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<String>(
        '${Endpoints.report(reportId.toString())}/download',
      );
      return response.data ?? '';
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to download report');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to download report', e, st);
    }
  }
}

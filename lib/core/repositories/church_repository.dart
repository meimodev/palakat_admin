import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/column_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/church.dart';
import '../models/column.dart' as cm;
import '../models/location.dart';
import '../models/app_error.dart';
import '../models/member_position_detail.dart';
import '../models/member_position.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'church_repository.g.dart';

@riverpod
ChurchRepository churchRepository(Ref ref) => ChurchRepository(ref);

class ChurchRepository {
  ChurchRepository(this._ref);

  final Ref _ref;

  Future<Church> fetchChurchProfile(int churchId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.church(churchId: churchId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?["data"] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid church response payload');
      }

      return Church.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch church profile');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch church profile', e);
    }
  }

  Future<Church> updateChurchProfile({
    required int churchId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.church(churchId: churchId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?["data"] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update church response payload');
      }
      return Church.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update church profile');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to update church profile', e);
    }
  }

  Future<Location> fetchLocation(int locationId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.location(locationId: locationId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?["data"] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid church response payload');
      }

      return Location.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch church profile');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch church profile', e);
    }
  }

  Future<Location> updateLocation({
    required int locationId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.location(locationId: locationId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update location response payload');
      }

      return Location.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update location');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to update location', e);
    }
  }

  Future<cm.Column> updateColumn({
    required int columnId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.column(columnId: columnId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update column response payload');
      }

      return cm.Column.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update column');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to update column', e);
    }
  }

  Future<ColumnDetail> fetchColumn({required int columnId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.column(columnId: columnId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid column response payload');
      }
      return ColumnDetail.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch column');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch column', e);
    }
  }

  Future<cm.Column> createColumn({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.columns,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid create column response payload');
      }
      return cm.Column.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create column');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to create column', e);
    }
  }

  Future<void> deleteColumn({required int columnId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.column(columnId: columnId));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete column');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to delete column', e);
    }
  }

  Future<List<cm.Column>> fetchColumns({required int churchId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.columns,
        queryParameters: {'churchId': churchId, 'pageSize': 100},
      );

      final data = response.data;
      final List<dynamic> jsonList = (data?['data'] as List?) ?? const [];
      return jsonList
          .map((e) => cm.Column.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch columns');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch columns', e);
    }
  }

  Future<List<MemberPosition>> fetchPositions({required int churchId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membershipPositions,
        queryParameters: {'churchId': churchId, 'pageSize': 100},
      );

      final data = response.data;
      final List<dynamic> jsonList = (data?['data'] as List?) ?? const [];
      return jsonList
          .map((e) => MemberPosition.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch positions');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch positions', e);
    }
  }

  Future<MemberPositionDetail> fetchPosition({required int positionId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membershipPosition(positionId: positionId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid position response payload');
      }
      return MemberPositionDetail.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch position');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch position', e);
    }
  }

  Future<void> deletePosition({required int positionId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(
        Endpoints.membershipPosition(positionId: positionId),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete position');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to delete position', e);
    }
  }

  Future<MemberPosition> updateMemberPosition({
    required int positionId,
    required Map<String, dynamic> update,
  }) async {

    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.membershipPosition(positionId: positionId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update position response payload');
      }

      return MemberPosition.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update position');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to update position', e);
    }

  }

  Future<MemberPosition> createMemberPosition({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.membershipPositions,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid create position response payload');
      }
      return MemberPosition.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create position');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to create position', e);
    }
  }
}

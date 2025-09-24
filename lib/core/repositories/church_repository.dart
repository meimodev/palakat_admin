import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/church.dart';
import '../models/app_error.dart';
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
      final response = await http.get<Map<String, dynamic>>(Endpoints.church(churchId: churchId));

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
}

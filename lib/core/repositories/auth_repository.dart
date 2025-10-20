import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/config/endpoint.dart';
import 'package:palakat_admin/core/models/app_error.dart';
import 'package:palakat_admin/core/models/auth_credentials.dart';
import 'package:palakat_admin/core/models/auth_response.dart';
import 'package:palakat_admin/core/models/auth_tokens.dart';
import 'package:palakat_admin/core/services/local_storage_service.dart';
import 'package:palakat_admin/core/services/local_storage_service_provider.dart';
import 'package:palakat_admin/core/services/http_service.dart';
import 'package:palakat_admin/core/utils/error_mapper.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  const AuthRepository(this._dio, this._localStorageService);

  Future<AuthResponse> signIn(AuthCredentials credentials) async {
    try {
      final body = {
        'identifier': credentials.identifier,
        'password': credentials.password,
      };
      final res = await _dio.post<Map<String, dynamic>>(
        Endpoints.signIn,
        data: body,
      );
      final auth = AuthResponse.fromJson(res.data?["data"] ?? const {});
      // Persist full auth payload (tokens + account) using Hive
      await _localStorageService.saveAuth(auth);
      return auth;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to sign in');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to sign in', e, st);
    }
  }

  Future<AuthTokens> refresh() async {
    try {
      final refreshToken = _localStorageService.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AppError.validation('No refresh token available');
      }
      final res = await _dio.post<Map<String, dynamic>>(
        Endpoints.refresh,
        data: {
          'refresh_token': refreshToken,
        },
      );
      // some APIs return tokens directly; others nest in data
      final data = res.data ?? const {};
      final tokens = AuthTokens.fromJson(data["data"]);
      await _localStorageService.saveTokens(tokens);
      return tokens;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to refresh tokens');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to refresh tokens', e, st);
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post(Endpoints.signOut);
    } catch (_) {
      // ignore network errors on logout
    } finally {
      await _localStorageService.clear();
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioInstanceProvider);
  final auth = ref.watch(localStorageServiceProvider);
  return AuthRepository(dio, auth);
}

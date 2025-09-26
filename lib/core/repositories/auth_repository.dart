import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/config/endpoint.dart';
import 'package:palakat_admin/core/models/app_error.dart';
import 'package:palakat_admin/core/models/auth_credentials.dart';
import 'package:palakat_admin/core/models/auth_response.dart';
import 'package:palakat_admin/core/models/auth_tokens.dart';
import 'package:palakat_admin/core/services/auth_service.dart';
import 'package:palakat_admin/core/services/auth_service_provider.dart';
import 'package:palakat_admin/core/services/http_service.dart';
import 'package:palakat_admin/core/utils/error_mapper.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final AuthService _authService;

  const AuthRepository(this._dio, this._authService);

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
      await _authService.saveAuth(auth);
      return auth;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to sign in');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to sign in', e);
    }
  }

  Future<AuthTokens> refresh() async {
    try {
      final refreshToken = _authService.refreshToken;
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
      await _authService.saveTokens(tokens);
      return tokens;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to refresh tokens');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to refresh tokens', e);
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post(Endpoints.signOut);
    } catch (_) {
      // ignore network errors on logout
    } finally {
      await _authService.clear();
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioInstanceProvider);
  final auth = ref.watch(authServiceProvider);
  return AuthRepository(dio, auth);
}

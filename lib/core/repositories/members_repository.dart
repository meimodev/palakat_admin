import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/request/get_fetch_member_position_request.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:palakat_admin/features/members/presentation/state/members_screen_state.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/account.dart';
import '../models/app_error.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'members_repository.g.dart';

@riverpod
MembersRepository membersRepository(Ref ref) => MembersRepository(ref);

class MembersRepository {
  MembersRepository(this._ref);

  final Ref _ref;

  Future<PaginationResponseWrapper<Account>> fetchAccounts({
    required PaginationRequestWrapper<GetFetchAccountsRequest>
    paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.accounts,
        queryParameters: query,
      );

      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => Account.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch accounts');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch accounts', e);
    }
  }

  Future<Account> fetchAccount({required int accountId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.account(accountId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid account response payload');
      }
      return Account.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch account');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch account', e);
    }
  }

  Future<Account> updateAccount({
    required int accountId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.account(accountId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update account response payload');
      }

      return Account.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update account');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to update account', e);
    }
  }

  // Future<Account> createAccount({required Map<String, dynamic> data}) async {
  //   try {
  //     final http = _ref.read(httpServiceProvider);
  //     final response = await http.post<Map<String, dynamic>>(
  //       Endpoints.accounts,
  //       data: data,
  //     );
  //
  //     final body = response.data;
  //     final Map<String, dynamic> json = body?['data'] ?? {};
  //     if (json.isEmpty) {
  //       throw AppError.network('Invalid create account response payload');
  //     }
  //     return Account.fromJson(json);
  //   } on DioException catch (e) {
  //     throw ErrorMapper.fromDio(e, 'Failed to create account');
  //   } catch (e) {
  //     throw ErrorMapper.unknown('Failed to create account', e);
  //   }
  // }

  Future<void> deleteAccount({required int accountId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.account(accountId));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete account');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to delete account', e);
    }
  }

  Future<MembersScreenStateCounts> fetchCounts(GetFetchAccountsRequest request) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.accountCount,
        queryParameters: request.toJson(),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid fetch account counts response payload');
      }

      return MembersScreenStateCounts.fromJson(json);
    } on DioException catch (e, st) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch account counts',st);
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed tofetch account counts', e, st: st);
    }
  }

  Future<Account> createAccount({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.accounts,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid create account response payload');
      }
      return Account.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create account');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to create account', e);
    }
  }

  Future<PaginationResponseWrapper<MemberPosition>> fetchMemberPositionsPagination({
    required PaginationRequestWrapper<GetFetchMemberPosition>
    paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membershipPositions,
        queryParameters: query,
      );

      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => MemberPosition.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch member positions');
    } catch (e) {
      throw ErrorMapper.unknown('Failed to fetch member positions', e);
    }
  }
}

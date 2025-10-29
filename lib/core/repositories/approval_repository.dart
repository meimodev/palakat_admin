import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_error.dart';
import '../models/approval_rule.dart';
import '../models/member_position.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'approval_repository.g.dart';

/// Repository for managing approval rules and configurations
class ApprovalRepository {
  final Ref _ref;
  
  ApprovalRepository(this._ref);
  
  /// Fetch approval rules with pagination
  Future<PaginationResponseWrapper<ApprovalRule>> fetchApprovalRules({
    required PaginationRequestWrapper<GetFetchApprovalRulesRequest> paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.approvalRules,
        queryParameters: query,
      );
      
      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => ApprovalRule.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch approval rules');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch approval rules', e, st);
    }
  }

  /// Fetch membership positions with pagination
  Future<PaginationResponseWrapper<MemberPosition>> fetchMembershipPositions({
    required PaginationRequestWrapper<GetFetchPositionsRequest> paginationRequest,
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
      throw ErrorMapper.fromDio(e, 'Failed to fetch positions');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch positions', e, st);
    }
  }

  /// Fetch a single approval rule by ID
  Future<ApprovalRule> fetchApprovalRuleById(int ruleId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.approvalRule(ruleId.toString()),
      );
      
      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid approval rule response payload');
      }
      
      return ApprovalRule.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch approval rule');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch approval rule', e, st);
    }
  }

  /// Create a new approval rule
  Future<ApprovalRule> createApprovalRule(Map<String, dynamic> data) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.approvalRules,
        data: data,
      );
      
      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid create approval rule response payload');
      }
      
      return ApprovalRule.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create approval rule');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to create approval rule', e, st);
    }
  }

  /// Update an existing approval rule
  Future<ApprovalRule> updateApprovalRule({
    required int ruleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.approvalRule(ruleId.toString()),
        data: data,
      );
      
      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update approval rule response payload');
      }
      
      return ApprovalRule.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update approval rule');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to update approval rule', e, st);
    }
  }

  /// Delete an approval rule
  Future<void> deleteApprovalRule(int ruleId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete(Endpoints.approvalRule(ruleId.toString()));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete approval rule');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to delete approval rule', e, st);
    }
  }
}

/// Riverpod provider for ApprovalRepository
@riverpod
ApprovalRepository approvalRepository(Ref ref) {
  return ApprovalRepository(ref);
}


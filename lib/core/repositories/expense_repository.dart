import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense.dart';
import '../models/app_error.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'expense_repository.g.dart';

@riverpod
ExpenseRepository expenseRepository(Ref ref) => ExpenseRepository(ref);

class ExpenseRepository {
  ExpenseRepository(this._ref);

  final Ref _ref;

  Future<PaginationResponseWrapper<Expense>> fetchExpenses({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.expenses,
        queryParameters: query,
      );

      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => Expense.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch expenses');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch expenses', e, st);
    }
  }

  Future<Expense> fetchExpense({required int expenseId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.expense(expenseId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid expense response payload');
      }
      return Expense.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch expense');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch expense', e, st);
    }
  }

  Future<Expense> updateExpense({
    required int expenseId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.expense(expenseId.toString()),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid update expense response payload');
      }

      return Expense.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update expense');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to update expense', e, st);
    }
  }

  Future<Expense> createExpense({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.expenses,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        throw AppError.network('Invalid create expense response payload');
      }
      return Expense.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to create expense');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to create expense', e, st);
    }
  }

  Future<void> deleteExpense({required int expenseId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.expense(expenseId.toString()));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to delete expense');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to delete expense', e, st);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/revenue/presentation/state/revenue_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'revenue_controller.g.dart';

@riverpod
class RevenueController extends _$RevenueController {
  late final Debouncer _searchDebouncer;

  @override
  RevenueScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const RevenueScreenState();
    Future.microtask(() {
      _fetchRevenues();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchRevenues() async {
    state = state.copyWith(revenues: const AsyncLoading());
    try {
      final repository = ref.read(revenueRepositoryProvider);
      
      // Calculate actual date range from preset
      DateTimeRange? actualDateRange;
      if (state.dateRangePreset == DateRangePreset.custom) {
        actualDateRange = state.customDateRange;
      } else if (state.dateRangePreset != DateRangePreset.allTime) {
        actualDateRange = state.dateRangePreset.getDateRange();
      }
      
      final revenues = await repository.fetchRevenues(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchRevenuesRequest(
            churchId: church.id!,
            search: state.searchQuery.isEmpty ? null : state.searchQuery,
            startDate: actualDateRange?.start,
            endDate: actualDateRange?.end,
          ),
          page: state.currentPage,
          pageSize: state.pageSize,
        ),
      );
      state = state.copyWith(revenues: AsyncData(revenues));
    } catch (e, st) {
      state = state.copyWith(revenues: AsyncError(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchRevenues());
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRevenues();
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(
      customDateRange: dateRange,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRevenues();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchRevenues();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchRevenues();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchRevenues();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchRevenues();
    }
  }

  Future<void> refresh() async {
    await _fetchRevenues();
  }

  // Fetch single revenue detail (doesn't mutate state)
  Future<Revenue> fetchRevenue(int revenueId) async {
    final repository = ref.read(revenueRepositoryProvider);
    return await repository.fetchRevenue(revenueId: revenueId);
  }

  // Save revenue (create or update)
  Future<void> saveRevenue(Revenue revenue) async {
    final repository = ref.read(revenueRepositoryProvider);

    final payload = revenue.toJson();
    if (revenue.id != null) {
      await repository.updateRevenue(revenueId: revenue.id!, update: payload);
    } else {
      await repository.createRevenue(data: payload);
    }

    await _fetchRevenues();
  }

  // Delete revenue
  Future<void> deleteRevenue(int revenueId) async {
    final repository = ref.read(revenueRepositoryProvider);
    await repository.deleteRevenue(revenueId: revenueId);

    // Refresh the list after delete
    await _fetchRevenues();
  }
}

/// Request model for fetching revenues
class GetFetchRevenuesRequest {
  final int churchId;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;

  GetFetchRevenuesRequest({
    required this.churchId,
    this.search,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'churchId': churchId,
      if (search != null) 'search': search,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
    };
  }
}

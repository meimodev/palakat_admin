import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/report/presentation/state/report_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_controller.g.dart';

@riverpod
class ReportController extends _$ReportController {
  late final Debouncer _searchDebouncer;

  @override
  ReportScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const ReportScreenState();
    Future.microtask(() {
      _fetchReports();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchReports() async {
    state = state.copyWith(reports: const AsyncLoading());
    try {
      final repository = ref.read(reportRepositoryProvider);
      
      // Calculate actual date range from preset
      DateTimeRange? actualDateRange;
      if (state.dateRangePreset == DateRangePreset.custom) {
        actualDateRange = state.customDateRange;
      } else if (state.dateRangePreset != DateRangePreset.allTime) {
        actualDateRange = state.dateRangePreset.getDateRange();
      }
      
      final reports = await repository.fetchReports(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchReportsRequest(
            churchId: church.id!,
            search: state.searchQuery.isEmpty ? null : state.searchQuery,
            startDate: actualDateRange?.start,
            endDate: actualDateRange?.end,
            generatedBy: state.generatedByFilter,
          ),
          page: state.currentPage,
          pageSize: state.pageSize,
        ),
      );
      state = state.copyWith(reports: AsyncData(reports));
    } catch (e, st) {
      state = state.copyWith(reports: AsyncError(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchReports());
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchReports();
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(
      customDateRange: dateRange,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchReports();
  }

  void onChangedGeneratedBy(GeneratedBy? generatedBy) {
    state = state.copyWith(
      generatedByFilter: generatedBy,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchReports();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchReports();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchReports();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchReports();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchReports();
    }
  }

  Future<void> refresh() async {
    await _fetchReports();
  }

  // Fetch single report detail (doesn't mutate state)
  Future<Report> fetchReport(int reportId) async {
    final repository = ref.read(reportRepositoryProvider);
    return await repository.fetchReport(reportId: reportId);
  }

  // Generate report
  Future<void> generateReport(Map<String, dynamic> data) async {
    final repository = ref.read(reportRepositoryProvider);
    await repository.generateReport(data: data);
    await _fetchReports();
  }

  // Delete report
  Future<void> deleteReport(int reportId) async {
    final repository = ref.read(reportRepositoryProvider);
    await repository.deleteReport(reportId: reportId);

    // Refresh the list after delete
    await _fetchReports();
  }

  // Download report
  Future<String> downloadReport(int reportId) async {
    final repository = ref.read(reportRepositoryProvider);
    return await repository.downloadReport(reportId: reportId);
  }
}

/// Request model for fetching reports
class GetFetchReportsRequest {
  final int churchId;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;
  final GeneratedBy? generatedBy;

  GetFetchReportsRequest({
    required this.churchId,
    this.search,
    this.startDate,
    this.endDate,
    this.generatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'churchId': churchId,
      if (search != null) 'search': search,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (generatedBy != null) 'generatedBy': generatedBy!.name.toUpperCase(),
    };
  }
}

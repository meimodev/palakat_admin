import 'package:palakat_admin/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'approval_screen_state.dart';

part 'approval_controller.g.dart';

@riverpod
class ApprovalController extends _$ApprovalController {
  late final Debouncer _searchDebouncer;

  @override
  ApprovalScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const ApprovalScreenState();
    Future.microtask(() {
      _fetchRules();
      _fetchPositions();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchRules() async {
    state = state.copyWith(rules: const AsyncValue.loading());
    try {
      final repository = ref.read(approvalRepositoryProvider);
      
      final rules = await repository.fetchApprovalRules(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchApprovalRulesRequest(
            churchId: church.id!,
            search: state.searchQuery.isEmpty ? null : state.searchQuery,
            active: state.activeOnly,
            positionId: state.selectedPositionId,
          ),
          page: state.currentPage,
          pageSize: state.pageSize,
        ),
      );
      state = state.copyWith(rules: AsyncValue.data(rules));
    } catch (e, st) {
      state = state.copyWith(rules: AsyncValue.error(e, st));
    }
  }

  Future<void> _fetchPositions() async {
    state = state.copyWith(positions: const AsyncValue.loading());
    try {
      final repository = ref.read(approvalRepositoryProvider);
      
      // Fetch all positions for the church (no pagination needed for positions dropdown)
      final positions = await repository.fetchMembershipPositions(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchPositionsRequest(
            churchId: church.id!,
          ),
          page: 1,
          pageSize: 100, // Get all positions
        ),
      );
      state = state.copyWith(positions: AsyncValue.data(positions));
    } catch (e, st) {
      state = state.copyWith(positions: AsyncValue.error(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchRules());
  }

  void onChangedActiveFilter(bool? activeOnly) {
    state = state.copyWith(
      activeOnly: activeOnly,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRules();
  }

  void onChangedPositionFilter(int? positionId) {
    state = state.copyWith(
      selectedPositionId: positionId,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRules();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchRules();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchRules();
  }

  void onPrevPage() {
    if (state.currentPage > 1) {
      onChangedPage(state.currentPage - 1);
    }
  }

  void onNextPage() {
    final pagination = state.rules.value?.pagination;
    if (pagination != null && pagination.hasNext) {
      onChangedPage(state.currentPage + 1);
    }
  }

  Future<void> saveRule(ApprovalRule rule) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);
      final data = rule.toJson();
      
      if (rule.id == null || rule.id == 0) {
        // Remove id for creation
        data.remove('id');
        await repository.createApprovalRule(data);
      } else {
        // Update existing rule
        await repository.updateApprovalRule(
          ruleId: rule.id!,
          data: data,
        );
      }
      
      // Refresh the list after save
      await _fetchRules();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRule(int ruleId) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);
      await repository.deleteApprovalRule(ruleId);
      
      // Refresh the list after delete
      await _fetchRules();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single approval rule by ID (for drawer detail view)
  Future<ApprovalRule> fetchRuleDetail(int ruleId) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);
      return await repository.fetchApprovalRuleById(ruleId);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch positions for a specific church (for drawer selector)
  Future<List<MemberPosition>> fetchPositionsByChurch(int churchId) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);
      
      final result = await repository.fetchMembershipPositions(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchPositionsRequest(
            churchId: churchId,
          ),
          page: 1,
          pageSize: 100, // Get all positions
        ),
      );
      
      return result.data;
    } catch (e) {
      rethrow;
    }
  }

  void refresh() {
    _fetchRules();
    _fetchPositions();
  }
}

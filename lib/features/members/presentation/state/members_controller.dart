import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/church.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:palakat_admin/core/models/request/get_fetch_member_position_request.dart';
import 'package:palakat_admin/core/utils/debouncer.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/members/presentation/state/members_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/repositories/members_repository.dart';

part 'members_controller.g.dart';

@riverpod
class MembersController extends _$MembersController {
  late final Debouncer _searchDebouncer;

  @override
  MembersScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const MembersScreenState();
    Future.microtask(() {
      _fetchMemberPositions();
      _fetchCounts();
      _fetchAccounts();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchAccounts() async {
    state = state.copyWith(accounts: const AsyncLoading());
    try {
      final repository = ref.read(membersRepositoryProvider);
      final accounts = await repository.fetchAccounts(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchAccountsRequest(
            churchId: church.id,
            search: state.searchQuery.isEmpty ? null : state.searchQuery,
            position: state.selectedPosition?.name.toLowerCase(),
          ),
          page: state.currentPage,
          pageSize: state.pageSize,
        ),
      );
      state = state.copyWith(accounts: AsyncData(accounts));
    } catch (e, st) {
      state = state.copyWith(accounts: AsyncError(e, st));
    }
  }

  Future<void> _fetchCounts() async {
    state = state.copyWith(counts: const AsyncLoading());
    try {
      final repository = ref.read(membersRepositoryProvider);
      final data = await repository.fetchCounts(
        GetFetchAccountsRequest(churchId: church.id),
      );
      state = state.copyWith(counts: AsyncData(data));
    } catch (e, st) {
      state = state.copyWith(counts: AsyncError(e, st));
    }
  }

  void _fetchMemberPositions() async {
    state = state.copyWith(positions: const AsyncLoading());
    try {
      final repository = ref.read(membersRepositoryProvider);
      final positions = await repository.fetchMemberPositionsPagination(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchMemberPosition(churchId: church.id),
        ),
      );
      state = state.copyWith(positions: AsyncData(positions.data));
    } catch (e, st) {
      state = state.copyWith(positions: AsyncError(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchAccounts());
  }

  void onChangedPosition(MemberPosition? position) {
    state = state.copyWith(
      selectedPosition: position,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchAccounts();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchAccounts();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchAccounts();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchAccounts();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchAccounts();
    }
  }

  Future<void> refresh() async {
    await _fetchAccounts();
  }

  // Fetch single member detail (doesn't mutate state)
  Future<Account> fetchMember(int memberId) async {
    final repository = ref.read(membersRepositoryProvider);
    return await repository.fetchAccount(accountId: memberId);
  }

  // Save member (create or update)
  Future<void> saveMember(Account account) async {
    final repository = ref.read(membersRepositoryProvider);

    final payload = account.toJson();
    if (account.id != null) {
      await repository.updateAccount(accountId: account.id!, update: payload);
    } else {
      await repository.createAccount(data: payload);
    }

    await _fetchAccounts();
    await _fetchCounts();
  }

  // Delete member
  Future<void> deleteMember(int memberId) async {
    final repository = ref.read(membersRepositoryProvider);
    await repository.deleteAccount(accountId: memberId);

    // Refresh the list after delete
    await _fetchAccounts();
    await _fetchCounts();
  }

  /// Helper method to convert nested objects to IDs within membership field
  /// - Converts membershipPositions list to membershipPositionIds list
  /// - Converts column object to columnId
  /// - Only processes data within 'membership' field, preserves all other data
  Map<String, dynamic> _convertNestedObjectsToIds(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    // Recursively find and process 'membership' field
    result.forEach((key, value) {
      if (key == 'membership' && value is Map<String, dynamic>) {
        result[key] = _processMembershipField(value);
      } else if (value is Map<String, dynamic>) {
        result[key] = _convertNestedObjectsToIds(value);
      }
    });

    return result;
  }

  /// Process the membership field to convert nested objects to IDs
  Map<String, dynamic> _processMembershipField(
    Map<String, dynamic> membership,
  ) {
    final result = Map<String, dynamic>.from(membership);

    // Convert membershipPositions to membershipPositionIds
    if (membership.containsKey('membershipPositions') &&
        membership['membershipPositions'] is List) {
      final positions = membership['membershipPositions'] as List;
      result['membershipPositionIds'] = positions
          .map((pos) => pos is Map ? pos['id'] : pos)
          .where((id) => id != null)
          .toList();
      result.remove('membershipPositions');
    }

    // Convert column object to columnId
    if (membership.containsKey('column') && membership['column'] is Map) {
      final column = membership['column'] as Map;
      if (column.containsKey('id')) {
        result['columnId'] = column['id'];
      }
      result.remove('column');
    }
    return result;
  }
}

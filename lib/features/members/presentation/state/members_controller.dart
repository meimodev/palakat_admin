import 'package:palakat_admin/core/models/church.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:palakat_admin/core/models/request/get_fetch_member_position_request.dart';
import 'package:palakat_admin/core/repositories/auth_repository.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/members/presentation/state/members_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/repositories/members_repository.dart';

part 'members_controller.g.dart';

@riverpod
class MembersController extends _$MembersController {
  @override
  MembersScreenState build() {
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

  void _fetchCounts() async {
    state = state.copyWith(counts: const AsyncLoading());
    try {
      final repository = ref.read(membersRepositoryProvider);
      final data = await repository.fetchCounts(
        GetFetchAccountsRequest(churchId: church.id),
      );
      state = state.copyWith(counts: AsyncData(data));
    } catch (e, st) {
      state = state.copyWith(accounts: AsyncError(e, st));
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
    _fetchAccounts();
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
}

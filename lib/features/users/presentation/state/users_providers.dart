import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUser {
  final String name;
  final String email;
  final String role; // Admin, Member
  final String status; // Active, Pending
  const AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}

// Dummy users
final usersAllProvider = Provider<List<AppUser>>((ref) {
  return List.generate(120, (i) => AppUser(
        name: 'User ${i + 1}',
        email: 'user${i + 1}@example.com',
        role: i % 7 == 0 ? 'Admin' : 'Member',
        status: i % 5 == 0 ? 'Pending' : 'Active',
      ));
});

@immutable
class UsersFilterState {
  final String search;
  final String role; // All/Admin/Member
  final String status; // All/Active/Pending
  final int page; // zero-based
  final int rowsPerPage;
  const UsersFilterState({
    this.search = '',
    this.role = 'All',
    this.status = 'All',
    this.page = 0,
    this.rowsPerPage = 10,
  });

  UsersFilterState copyWith({
    String? search,
    String? role,
    String? status,
    int? page,
    int? rowsPerPage,
  }) => UsersFilterState(
        search: search ?? this.search,
        role: role ?? this.role,
        status: status ?? this.status,
        page: page ?? this.page,
        rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      );
}

class UsersFilterNotifier extends StateNotifier<UsersFilterState> {
  UsersFilterNotifier() : super(const UsersFilterState());

  void setSearch(String value) => state = state.copyWith(search: value, page: 0);
  void setRole(String value) => state = state.copyWith(role: value, page: 0);
  void setStatus(String value) => state = state.copyWith(status: value, page: 0);
  void setRowsPerPage(int value) => state = state.copyWith(rowsPerPage: value, page: 0);
  void nextPage(int total) {
    final maxPage = (total / state.rowsPerPage).ceil() - 1;
    if (state.page < maxPage) state = state.copyWith(page: state.page + 1);
  }
  void prevPage() {
    if (state.page > 0) state = state.copyWith(page: state.page - 1);
  }
}

final usersFilterProvider = StateNotifierProvider<UsersFilterNotifier, UsersFilterState>((ref) {
  return UsersFilterNotifier();
});

final usersFilteredProvider = Provider<List<AppUser>>((ref) {
  final filters = ref.watch(usersFilterProvider);
  final all = ref.watch(usersAllProvider);
  return all.where((u) {
    final okSearch = filters.search.isEmpty ||
        u.name.toLowerCase().contains(filters.search.toLowerCase()) ||
        u.email.toLowerCase().contains(filters.search.toLowerCase());
    final okRole = filters.role == 'All' || u.role == filters.role;
    final okStatus = filters.status == 'All' || u.status == filters.status;
    return okSearch && okRole && okStatus;
  }).toList();
});

class UsersPageSlice {
  final List<AppUser> rows;
  final int total;
  const UsersPageSlice(this.rows, this.total);
}

final usersPageProvider = Provider<UsersPageSlice>((ref) {
  final filters = ref.watch(usersFilterProvider);
  final list = ref.watch(usersFilteredProvider);
  final start = filters.page * filters.rowsPerPage;
  final end = (start + filters.rowsPerPage).clamp(0, list.length);
  final pageRows = start >= list.length ? <AppUser>[] : list.sublist(start, end);
  return UsersPageSlice(pageRows, list.length);
});

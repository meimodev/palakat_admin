import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/core/models/member_position.dart';

part 'members_providers.g.dart';

// Dummy Members using Riverpod 3.x syntax
@riverpod
class MembersNotifier extends _$MembersNotifier {
  @override
  List<Account> build() {
    return _generateMembers();
  }

  static List<Account> _generateMembers() {
    final allPositions = [
      'Elder',
      'Deacon',
      'Member',
      'Worship Leader',
      'Sunday School Teacher',
      'Youth Leader',
      'Small Group Leader',
      'Volunteer',
    ];

    return List.generate(120, (i) {
      // Generate 1-3 random positions for each member
      final positionCount = 1 + (i % 3);
      final positions = List.generate(
        positionCount,
        (j) => allPositions[(i + j) % allPositions.length],
      ).toSet().toList(); // Ensure unique positions

      final now = DateTime.now();
      final membership = Membership(
        id: i + 1,
        baptize: i % 3 == 0,
        sidi: i % 4 == 0,
        createdAt: now,
        updatedAt: now,
        membershipPositions: [
          for (var idx = 0; idx < positions.length; idx++)
            MemberPosition(
              id: (i + 1) * 100 + idx,
              churchId: 1,
              columnId: (idx % 5) + 1,
              name: positions[idx],
              createdAt: now,
              updatedAt: now,
            ),
        ],
      );

      return Account(
        id: i+1,
        name: 'Member ${i + 1}',
        phone: '+1 (555) ${100 + (i % 900)}-${1000 + (i % 9000)}',
        email: 'member${i + 1}@example.com',
        gender: i % 2 == 0 ? Gender.male : Gender.female,
        married: i % 5 == 0,
        dob: DateTime(1990 + (i % 20), ((i % 12) + 1), ((i % 28) + 1)),
        claimed: i % 5 == 0,
        createdAt: now,
        updatedAt: now,
        membership: membership,
      );
    });
  }

  void addMember(Account member) {
    state = [member, ...state];
  }

  void updateMember(Account updatedMember) {
    state = [
      for (final member in state)
        if (member.email == updatedMember.email) updatedMember else member,
    ];
  }
}

// For backward compatibility
@riverpod
List<Account> membersAll(Ref ref) {
  return ref.watch(membersProvider);
}

@immutable
class MembersFilterState {
  final String search;
  final String? selectedPosition;
  final int page; // zero-based
  final int rowsPerPage;
  const MembersFilterState({
    this.search = '',
    this.selectedPosition,
    this.page = 0,
    this.rowsPerPage = 10,
  });

  MembersFilterState copyWith({
    String? search,
    String? selectedPosition,
    int? page,
    int? rowsPerPage,
  }) => MembersFilterState(
    search: search ?? this.search,
    selectedPosition: selectedPosition ?? this.selectedPosition,
    page: page ?? this.page,
    rowsPerPage: rowsPerPage ?? this.rowsPerPage,
  );
}

@riverpod
class MembersFilterNotifier extends _$MembersFilterNotifier {
  @override
  MembersFilterState build() {
    return const MembersFilterState();
  }

  void setSearch(String value) =>
      state = state.copyWith(search: value, page: 0);
  void setPosition(String? value) =>
      state = state.copyWith(selectedPosition: value, page: 0);
  void setRowsPerPage(int value) =>
      state = state.copyWith(rowsPerPage: value, page: 0);
  void nextPage(int total) {
    final maxPage = (total / state.rowsPerPage).ceil() - 1;
    if (state.page < maxPage) state = state.copyWith(page: state.page + 1);
  }

  void prevPage() {
    if (state.page > 0) state = state.copyWith(page: state.page - 1);
  }
}

@riverpod
List<Account> membersFiltered(Ref ref) {
  final filters = ref.watch(membersFilterProvider);
  final all = ref.watch(membersAllProvider);
  return all.where((u) {
    final matchesSearch =
        filters.search.isEmpty ||
        u.name.toLowerCase().contains(filters.search.toLowerCase()) ||
        u.email.toLowerCase().contains(filters.search.toLowerCase());

    final memberPositionNames = (u.membership?.membershipPositions ?? [])
        .map((mp) => mp.name)
        .toList();
    final matchesPosition =
        filters.selectedPosition == null ||
        memberPositionNames.contains(filters.selectedPosition!);

    return matchesSearch && matchesPosition;
  }).toList();
}

// Provider for available positions
@riverpod
List<String> availablePositions(Ref ref) {
  final all = ref.watch(membersAllProvider);
  final allPositions = <String>{};
  for (final member in all) {
    allPositions.addAll(
      (member.membership?.membershipPositions ?? []).map((mp) => mp.name),
    );
  }
  return allPositions.toList()..sort();
}

class MembersPageSlice {
  final List<Account> rows;
  final int total;
  const MembersPageSlice(this.rows, this.total);
}

@riverpod
MembersPageSlice membersPage(Ref ref) {
  final filters = ref.watch(membersFilterProvider);
  final list = ref.watch(membersFilteredProvider);
  final start = filters.page * filters.rowsPerPage;
  final end = (start + filters.rowsPerPage).clamp(0, list.length);
  final pageRows = start >= list.length
      ? <Account>[]
      : list.sublist(start, end);
  return MembersPageSlice(pageRows, list.length);
}

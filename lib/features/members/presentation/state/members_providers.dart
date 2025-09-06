import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Membership {
  final String name;
  final String email;
  final String phone;
  final List<String> positions;
  final bool isBaptized;
  final bool isSidi;
  final bool isLinked;
  final bool isMarried;
  final String? gender;

  const Membership({
    required this.name,
    required this.email,
    required this.phone,
    required this.positions,
    this.isBaptized = false,
    this.isSidi = false,
    this.isLinked = false,
    this.isMarried = false,
    this.gender,
  });

  Membership copyWith({
    String? name,
    String? email,
    String? phone,
    List<String>? positions,
    bool? isBaptized,
    bool? isSidi,
    bool? isLinked,
    bool? isMarried,
    String? gender,
  }) {
    return Membership(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      positions: positions ?? List.from(this.positions),
      isBaptized: isBaptized ?? this.isBaptized,
      isSidi: isSidi ?? this.isSidi,
      isLinked: isLinked ?? this.isLinked,
      isMarried: isMarried ?? this.isMarried,
      gender: gender ?? this.gender,
    );
  }

  // Helper method to create an AppMember with a single position for backward compatibility
  factory Membership.singlePosition({
    required String name,
    required String email,
    required String phone,
    required String position,
    bool isBaptized = false,
    bool isSidi = false,
    bool isLinked = false,
    bool isMarried = false,
  }) {
    return Membership(
      name: name,
      email: email,
      phone: phone,
      positions: [position],
      isBaptized: isBaptized,
      isSidi: isSidi,
      isLinked: isLinked,
      isMarried: isMarried,
    );
  }
}

// Dummy Members
final membersProvider =
    StateNotifierProvider<MembersNotifier, List<Membership>>((ref) {
      return MembersNotifier();
    });

class MembersNotifier extends StateNotifier<List<Membership>> {
  MembersNotifier() : super(_generateMembers());

  static List<Membership> _generateMembers() {
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

      return Membership(
        name: 'Member ${i + 1}',
        email: 'member${i + 1}@example.com',
        phone: '+1 (555) ${100 + (i % 900)}-${1000 + (i % 9000)}',
        positions: positions,
        isBaptized: i % 3 == 0,
        isSidi: i % 4 == 0,
        isLinked: i % 5 == 0,
      );
    });
  }

  void addMember(Membership member) {
    state = [member, ...state];
  }

  void updateMember(Membership updatedMember) {
    state = [
      for (final member in state)
        if (member.email == updatedMember.email) updatedMember else member,
    ];
  }
}

// For backward compatibility
final membersAllProvider = Provider<List<Membership>>((ref) {
  return ref.watch(membersProvider);
});

@immutable
class MembersFilterState {
  final String search;
  final int page; // zero-based
  final int rowsPerPage;
  const MembersFilterState({
    this.search = '',
    this.page = 0,
    this.rowsPerPage = 10,
  });

  MembersFilterState copyWith({String? search, int? page, int? rowsPerPage}) =>
      MembersFilterState(
        search: search ?? this.search,
        page: page ?? this.page,
        rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      );
}

class MembersFilterNotifier extends StateNotifier<MembersFilterState> {
  MembersFilterNotifier() : super(const MembersFilterState());

  void setSearch(String value) =>
      state = state.copyWith(search: value, page: 0);
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

final membersFilterProvider =
    StateNotifierProvider<MembersFilterNotifier, MembersFilterState>((ref) {
      return MembersFilterNotifier();
    });

final membersFilteredProvider = Provider<List<Membership>>((ref) {
  final filters = ref.watch(membersFilterProvider);
  final all = ref.watch(membersAllProvider);
  return all.where((u) {
    return filters.search.isEmpty ||
        u.name.toLowerCase().contains(filters.search.toLowerCase()) ||
        u.email.toLowerCase().contains(filters.search.toLowerCase());
  }).toList();
});

class MembersPageSlice {
  final List<Membership> rows;
  final int total;
  const MembersPageSlice(this.rows, this.total);
}

final membersPageProvider = Provider<MembersPageSlice>((ref) {
  final filters = ref.watch(membersFilterProvider);
  final list = ref.watch(membersFilteredProvider);
  final start = filters.page * filters.rowsPerPage;
  final end = (start + filters.rowsPerPage).clamp(0, list.length);
  final pageRows = start >= list.length
      ? <Membership>[]
      : list.sublist(start, end);
  return MembersPageSlice(pageRows, list.length);
});

import 'package:palakat_admin/features/members/presentation/state/members_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/core/models/member_position.dart';

part 'members_controller.g.dart';

@riverpod
class MembersController extends _$MembersController {

  @override
  MembersState build() {
    // Start with loading, then simulate fetch.
    final initial = const MembersState();
    // Kick off initial load asynchronously.
    Future.microtask(() {
      _loadMembers();
      _loadCounts();
    });
    return initial;
  }

  void _loadCounts() async {
    await Future.delayed(Duration(seconds: 2));
    state = state.copyWith(
      counts: AsyncData(
        MembersStateCounts(
          total: 9999,
          baptized: 9999,
          claimed: 9999,
          sidi: 9999,
        ),
      ),
    );
  }

  List<String> fetchMemberPositions (){
    return [
      'Usher',
      'Treasurer',
      'Choir',
      'Sunday School',
      'Youth Leader',
      'Media',
    ];
  }


  void setSearch(String value) {
    print("Set Search $value");
  }

  void setPositionFilter(String? position) {
    print("Set Position $position");
  }

  Future<void> refresh() async {
    await _loadMembers();
  }

  Future<void> _loadMembers() async {
    // Set loading state
    state = state.copyWith(accounts: const AsyncLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final data = _buildMockMembers();
      state = state.copyWith(accounts: AsyncData(data));
    } catch (e, st) {
      state = state.copyWith(accounts: AsyncError(e, st));
    }
  }

  List<Account> _buildMockMembers() {
    final now = DateTime.now();
    MemberPosition pos(String name) => MemberPosition(
      id: null,
      churchId: 1,
      name: name,
      createdAt: now.subtract(const Duration(days: 400)),
      updatedAt: now.subtract(const Duration(days: 30)),
    );

    Membership mkMembership({
      required bool baptize,
      required bool sidi,
      List<MemberPosition> positions = const [],
    }) => Membership(
      id: null,
      baptize: baptize,
      sidi: sidi,
      createdAt: now.subtract(const Duration(days: 500)),
      updatedAt: now.subtract(const Duration(days: 1)),
      membershipPositions: positions,
    );

    Account mkAccount({
      required int id,
      required String name,
      required String phone,
      required String email,
      required Gender gender,
      required bool married,
      required bool claimed,
      required DateTime dob,
      Membership? membership,
    }) => Account(
      id: id,
      name: name,
      phone: phone,
      email: email,
      gender: gender,
      married: married,
      dob: dob,
      claimed: claimed,
      createdAt: now.subtract(const Duration(days: 800)),
      updatedAt: now.subtract(const Duration(days: 2)),
      membership: membership,
    );

    return [
      mkAccount(
        id: 1,
        name: 'John Doe',
        phone: '+62 811-2222-333',
        email: 'john.doe@example.com',
        gender: Gender.male,
        married: true,
        claimed: true,
        dob: DateTime(1990, 5, 12),
        membership: mkMembership(
          baptize: true,
          sidi: true,
          positions: [pos('Usher'), pos('Treasurer')],
        ),
      ),
      mkAccount(
        id: 2,
        name: 'Jane Smith',
        phone: '+62 812-4444-555',
        email: 'jane.smith@example.com',
        gender: Gender.female,
        married: false,
        claimed: false,
        dob: DateTime(1994, 9, 1),
        membership: mkMembership(
          baptize: true,
          sidi: false,
          positions: [pos('Choir')],
        ),
      ),
      mkAccount(
        id: 3,
        name: 'Michael Lee',
        phone: '+62 813-6666-777',
        email: 'michael.lee@example.com',
        gender: Gender.male,
        married: true,
        claimed: true,
        dob: DateTime(1987, 2, 23),
        membership: mkMembership(baptize: false, sidi: false, positions: []),
      ),
      mkAccount(
        id: 4,
        name: 'Sarah Connor',
        phone: '+62 814-8888-999',
        email: 'sarah.connor@example.com',
        gender: Gender.female,
        married: false,
        claimed: true,
        dob: DateTime(1992, 12, 2),
        membership: mkMembership(
          baptize: true,
          sidi: true,
          positions: [pos('Sunday School')],
        ),
      ),
      mkAccount(
        id: 5,
        name: 'David Kim',
        phone: '+62 815-1010-202',
        email: 'david.kim@example.com',
        gender: Gender.male,
        married: false,
        claimed: false,
        dob: DateTime(1996, 7, 15),
        membership: mkMembership(
          baptize: true,
          sidi: false,
          positions: [pos('Youth Leader'), pos('Media')],
        ),
      ),
    ];
  }

}

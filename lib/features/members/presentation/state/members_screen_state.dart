import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/models/response/pagination_response_wrapper.dart';

part 'members_screen_state.freezed.dart';
part 'members_screen_state.g.dart';

@freezed
abstract class MembersScreenState with _$MembersScreenState {
  const factory MembersScreenState({
    @Default(AsyncValue.loading()) AsyncValue<PaginationResponseWrapper<Account>> accounts,
    @Default(AsyncValue.loading()) AsyncValue<MembersScreenStateCounts> counts,
    @Default(AsyncValue.loading()) AsyncValue<List<MemberPosition>> positions,
    @Default('') String searchQuery,
    MemberPosition? selectedPosition,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
  }) = _MembersScreenState;
}

@freezed
abstract class MembersScreenStateCounts with _$MembersScreenStateCounts {
  const factory MembersScreenStateCounts({
    @Default(0) int total,
    @Default(0) int claimed,
    @Default(0) int baptized,
    @Default(0) int sidi,
  }) = _MembersScreenStateCounts;

  factory MembersScreenStateCounts.fromJson(Map<String, dynamic> json) => _$MembersScreenStateCountsFromJson(json);
}

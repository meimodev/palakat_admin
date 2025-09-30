import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/account.dart';

part 'members_state.freezed.dart';

@freezed
abstract class MembersState with _$MembersState {
  const factory MembersState({
    @Default(AsyncValue.loading()) AsyncValue<List<Account>> accounts,
    @Default(AsyncValue.loading()) AsyncValue<MembersStateCounts> counts,
    // @Default('') String searchText,
    // String? positionFilter,
  }) = _MembersState;
}

@freezed
abstract class MembersStateCounts with _$MembersStateCounts {
  const factory MembersStateCounts({
    @Default(0) int total,
    @Default(0) int claimed,
    @Default(0) int baptized,
    @Default(0) int sidi,
  }) = _MembersStateCounts;
}

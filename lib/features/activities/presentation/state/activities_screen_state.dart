import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/constants/date_range_preset.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/models/activity.dart';
import 'package:palakat_admin/core/models/response/pagination_response_wrapper.dart';

part 'activities_screen_state.freezed.dart';

@freezed
abstract class ActivitiesScreenState with _$ActivitiesScreenState {
  const factory ActivitiesScreenState({
    @Default(AsyncValue.loading()) AsyncValue<PaginationResponseWrapper<Activity>> activities,
    @Default('') String searchQuery,
    @Default(DateRangePreset.allTime) DateRangePreset dateRangePreset,
    DateTimeRange? customDateRange,
    ActivityType? activityTypeFilter,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
  }) = _ActivitiesScreenState;
}

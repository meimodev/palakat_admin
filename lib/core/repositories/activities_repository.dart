import 'package:flutter/material.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity.dart';
import '../models/async_state.dart' as app_async;
import '../models/app_error.dart';
import '../services/api_service.dart';

part 'activities_repository.g.dart';

/// Repository for managing activities data with proper error handling and async states
/// This separates data logic from UI components
class ActivitiesRepository {
  final ApiService _apiService;
  
  ActivitiesRepository(this._apiService);
  
  /// Get all activities with proper async state handling using HTTP
  Future<app_async.AsyncState<List<Activity>>> getActivitiesAsync() async {
    try {
      final activities = await _apiService.getActivities();
      return app_async.AsyncSuccess(activities);
    } catch (e) {
      if (e is AppError) {
        return app_async.AsyncError(e);
      }
      return app_async.AsyncError(AppError.unknown('Failed to load activities: $e'));
    }
  }
  
  /// Create a new activity
  Future<app_async.AsyncState<Activity>> createActivity(Activity activity) async {
    try {
      final createdActivity = await _apiService.createActivity(activity);
      return app_async.AsyncSuccess(createdActivity);
    } catch (e) {
      if (e is AppError) {
        return app_async.AsyncError(e);
      }
      return app_async.AsyncError(AppError.unknown('Failed to create activity: $e'));
    }
  }
  
  /// Update an existing activity
  Future<app_async.AsyncState<Activity>> updateActivity(Activity activity) async {
    try {
      final updatedActivity = await _apiService.updateActivity(activity);
      return app_async.AsyncSuccess(updatedActivity);
    } catch (e) {
      if (e is AppError) {
        return app_async.AsyncError(e);
      }
      return app_async.AsyncError(AppError.unknown('Failed to update activity: $e'));
    }
  }
  
  /// Delete an activity
  Future<app_async.AsyncState<void>> deleteActivity(String activityId) async {
    try {
      await _apiService.deleteActivity(activityId);
      return const app_async.AsyncSuccess(null);
    } catch (e) {
      if (e is AppError) {
        return app_async.AsyncError(e);
      }
      return app_async.AsyncError(AppError.unknown('Failed to delete activity: $e'));
    }
  }
  
  /// Generate mock activities data (synchronous version for backward compatibility)
  List<Activity> getAllActivities() {
    return _generateMockActivities();
  }
  
  /// Internal method to generate mock activities
  List<Activity> _generateMockActivities() {
    final now = DateTime.now();
    return [
      Activity(
        id: 'ACT-1001',
        title: 'Sunday Morning Worship',
        description: 'Weekly worship service with sermon and communion',
        type: ActivityType.service,
        status: ActivityStatus.ongoing,
        startDate: now.subtract(const Duration(days: 0)),
        endDate: now
            .subtract(const Duration(days: 0))
            .add(const Duration(hours: 2)),
        supervisor: 'Pastor John',
        supervisorPositions: ['Senior Pastor', 'Head of Worship'],
        participants: ['Pastor John', 'Worship Team', 'Congregation'],
        location: 'Main Sanctuary',
        notes: 'Special guest speaker this week',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Activity(
        id: 'ACT-1002',
        title: 'Youth Bible Study',
        description: 'Weekly Bible study for teenagers and young adults',
        type: ActivityType.service,
        status: ActivityStatus.planned,
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 2, hours: 1, minutes: 30)),
        supervisor: 'Youth Pastor Sarah',
        supervisorPositions: ['Youth Pastor', 'Education Coordinator'],
        participants: ['Youth Pastor Sarah', 'Teen Group'],
        location: 'Youth Room',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Activity(
        id: 'ACT-1003',
        title: 'Community Food Drive',
        description: 'Monthly food collection for local food bank',
        type: ActivityType.event,
        status: ActivityStatus.completed,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 8)),
        supervisor: 'Deacon Mary',
        supervisorPositions: ['Deacon', 'Outreach Coordinator'],
        participants: ['Deacon Mary', 'Volunteers', 'Community Members'],
        location: 'Church Parking Lot',
        notes: 'Collected 500 pounds of food items',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Activity(
        id: 'ACT-1004',
        title: 'Church Budget Update',
        description: 'Important announcement regarding church budget changes',
        type: ActivityType.announcement,
        status: ActivityStatus.completed,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now
            .subtract(const Duration(days: 15))
            .add(const Duration(hours: 2)),
        supervisor: 'Administrator Bob',
        supervisorPositions: ['Administrator', 'Financial Secretary'],
        participants: ['Pastor John', 'Deacon Mary', 'Treasurer', 'Secretary'],
        location: 'Conference Room',
        notes: 'Discussed budget and upcoming events',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Activity(
        id: 'ACT-1005',
        title: 'Christmas Concert',
        description: 'Annual Christmas musical performance',
        type: ActivityType.event,
        status: ActivityStatus.planned,
        startDate: now.add(const Duration(days: 45)),
        endDate: now.add(const Duration(days: 45, hours: 3)),
        supervisor: 'Music Director',
        supervisorPositions: ['Music Director', 'Worship Leader'],
        participants: ['Choir', 'Orchestra', 'Soloists'],
        location: 'Main Sanctuary',
        notes: 'Rehearsals start next month',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Activity(
        id: 'ACT-1006',
        title: 'Fellowship Dinner',
        description: 'Monthly potluck dinner for church members',
        type: ActivityType.event,
        status: ActivityStatus.planned,
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7, hours: 2)),
        supervisor: 'Fellowship Committee',
        supervisorPositions: ['Fellowship Coordinator', 'Event Planner'],
        participants: ['Church Members', 'Families'],
        location:
            'Fellowship Hall - Main dining area with kitchen facilities and seating for up to 200 people',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  /// Filter activities based on search query and date range
  List<Activity> filterActivities(
    List<Activity> activities,
    String searchQuery,
    DateTimeRange? dateRange,
  ) {
    return activities.where((activity) {
      // Search filter
      final query = searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          (activity.id?.toLowerCase().contains(query) ?? false) ||
          activity.title.toLowerCase().contains(query) ||
          activity.description.toLowerCase().contains(query) ||
          activity.type.displayName.toLowerCase().contains(query) ||
          activity.status.displayName.toLowerCase().contains(query) ||
          activity.supervisor.toLowerCase().contains(query) ||
          (activity.location?.toLowerCase().contains(query) ?? false) ||
          activity.participants.any((p) => p.toLowerCase().contains(query));

      // Date range filter
      bool inDateRange = true;
      if (dateRange != null) {
        final startDate = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
        final endDate = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
        final activityDate = DateTime(activity.startDate.year, activity.startDate.month, activity.startDate.day);
        final afterStart = activityDate.isAtSameMomentAs(startDate) || activityDate.isAfter(startDate);
        final beforeEnd = activityDate.isAtSameMomentAs(endDate) || activityDate.isBefore(endDate);
        inDateRange = afterStart && beforeEnd;
      }

      return matchesQuery && inDateRange;
    }).toList();
  }

  /// Get paginated activities
  List<Activity> getPaginatedActivities(
    List<Activity> activities,
    int page,
    int rowsPerPage,
  ) {
    final start = (page * rowsPerPage).clamp(0, activities.length);
    final end = (start + rowsPerPage).clamp(0, activities.length);
    return start < end ? activities.sublist(start, end) : <Activity>[];
  }
}

/// Riverpod provider for ActivitiesRepository
@riverpod
ActivitiesRepository activitiesRepository(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ActivitiesRepository(apiService);
}

/// Provider for all activities with async state handling
@riverpod
Future<List<Activity>> activitiesAsync(Ref ref) async {
  final repository = ref.watch(activitiesRepositoryProvider);
  final result = await repository.getActivitiesAsync();
  
  return result.when(
    loading: () => throw StateError('Loading'),
    success: (data) => data,
    error: (error) => throw error,
  );
}

/// Provider for all activities (synchronous - for backward compatibility)
@riverpod
List<Activity> allActivities(Ref ref) {
  final repository = ref.watch(activitiesRepositoryProvider);
  return repository.getAllActivities();
}

/// State class for activities screen state
class ActivitiesScreenStateData {
  final String searchQuery;
  final DateTimeRange? dateRange;
  final int page;
  final int rowsPerPage;

  const ActivitiesScreenStateData({
    this.searchQuery = '',
    this.dateRange,
    this.page = 0,
    this.rowsPerPage = 5,
  });

  ActivitiesScreenStateData copyWith({
    String? searchQuery,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    int? page,
    int? rowsPerPage,
  }) {
    return ActivitiesScreenStateData(
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      page: page ?? this.page,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
    );
  }
}

/// Provider for activities screen state using Riverpod generator
@riverpod
class ActivitiesScreenState extends _$ActivitiesScreenState {
  @override
  ActivitiesScreenStateData build() {
    return const ActivitiesScreenStateData();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, page: 0);
  }

  void updateDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range, page: 0);
  }

  void clearDateRange() {
    state = state.copyWith(clearDateRange: true, page: 0);
  }

  void updatePage(int page) {
    state = state.copyWith(page: page);
  }

  void updateRowsPerPage(int rowsPerPage) {
    state = state.copyWith(rowsPerPage: rowsPerPage, page: 0);
  }

  void nextPage(int maxPage) {
    if (state.page < maxPage) {
      state = state.copyWith(page: state.page + 1);
    }
  }

  void previousPage() {
    if (state.page > 0) {
      state = state.copyWith(page: state.page - 1);
    }
  }
}

/// Provider for filtered activities based on current state
@riverpod
List<Activity> filteredActivities(Ref ref) {
  final allActivities = ref.watch(allActivitiesProvider);
  final screenState = ref.watch(activitiesScreenStateProvider);
  final repository = ref.watch(activitiesRepositoryProvider);

  return repository.filterActivities(
    allActivities,
    screenState.searchQuery,
    screenState.dateRange,
  );
}

/// Provider for paginated activities based on current state
@riverpod
List<Activity> paginatedActivities(Ref ref) {
  final filteredActivities = ref.watch(filteredActivitiesProvider);
  final screenState = ref.watch(activitiesScreenStateProvider);
  final repository = ref.watch(activitiesRepositoryProvider);

  return repository.getPaginatedActivities(
    filteredActivities,
    screenState.page,
    screenState.rowsPerPage,
  );
}

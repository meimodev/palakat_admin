import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/core/models/activity.dart';
import 'package:palakat_admin/core/models/approval_status.dart';
import 'package:palakat_admin/core/utils/date_utils.dart';
import 'package:palakat_admin/core/widgets/positions_cell.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/app_table.dart';
import 'package:palakat_admin/core/widgets/activity_type_chip.dart';
import 'package:palakat_admin/core/widgets/approver_card.dart';
import 'package:palakat_admin/core/widgets/compact_status_chip.dart';
import 'package:palakat_admin/features/activities/presentation/state/activities_screen_state.dart';
import '../state/activities_controller.dart';
import '../widgets/activity_detail_drawer.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  /// Shows activity drawer for viewing
  void _showActivityDrawer(int activityId) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: ActivityDetailDrawer(
              activityId: activityId,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ActivitiesScreenState state = ref.watch(activitiesControllerProvider);
    final ActivitiesController controller = ref.watch(
      activitiesControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activities', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Monitor and manage all church activities.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: 'Activity Directory',
              subtitle: 'A record of all church activities and events.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<Activity>(
                    loading: state.activities.isLoading,
                    data: state.activities.value?.data ?? [],
                    errorText: state.activities.hasError
                        ? state.activities.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    pagination: () {
                      final pageSize =
                          state.activities.value?.pagination.pageSize ?? 10;
                      final page = state.activities.value?.pagination.page ?? 1;
                      final total =
                          state.activities.value?.pagination.total ?? 0;

                      final hasPrev =
                          state.activities.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          state.activities.value?.pagination.hasNext ?? false;

                      return AppTablePaginationConfig(
                        total: total,
                        pageSize: pageSize,
                        page: page,
                        onPageSizeChanged: controller.onChangedPageSize,
                        onPageChanged: controller.onChangedPage,
                        onPrev: hasPrev ? controller.onPressedPrevPage : null,
                        onNext: hasNext ? controller.onPressedNextPage : null,
                      );
                    }.call(),
                    filtersConfig: AppTableFiltersConfig(
                      searchHint: 'Search by title, description, or supervisor name ...',
                      onSearchChanged: controller.onChangedSearch,
                      dateRangePreset: state.dateRangePreset,
                      customDateRange: state.customDateRange,
                      onDateRangePresetChanged: controller.onChangedDateRangePreset,
                      onCustomDateRangeSelected: controller.onCustomDateRangeSelected,
                      dropdownLabel: 'Type',
                      dropdownOptions: {
                        ActivityType.service.name: ActivityType.service.displayName,
                        ActivityType.event.name: ActivityType.event.displayName,
                        ActivityType.announcement.name: ActivityType.announcement.displayName,
                      },
                      dropdownValue: state.activityTypeFilter?.name,
                      onDropdownChanged: (value) {
                        if (value == null) {
                          controller.onChangedActivityType(null);
                        } else {
                          controller.onChangedActivityType(
                            ActivityType.values.firstWhere((e) => e.name == value),
                          );
                        }
                      },
                    ),
                    onRowTap: (activity) async {
                      if (activity.id != null) {
                        _showActivityDrawer(activity.id!);
                      }
                    },
                    columns: _buildTableColumns(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the table column configuration for the activities table
  static List<AppTableColumn<Activity>> _buildTableColumns() {
    return [
      AppTableColumn<Activity>(
        title: 'Title',
        flex: 3,
        cellBuilder: (ctx, activity) {
          final theme = Theme.of(ctx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                activity.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (activity.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  activity.description ?? "",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          );
        },
      ),
      AppTableColumn<Activity>(
        title: 'Type',
        flex: 2,
        cellBuilder: (ctx, activity) {
          return ActivityTypeChip(type: activity.activityType);
        },
      ),
      AppTableColumn<Activity>(
        title: 'Request Date Time',
        flex: 2,
        cellBuilder: (ctx, activity) {
          final theme = Theme.of(ctx);
          final date = AppDateUtils.formatCustom(
            activity.createdAt,
            "EEEE, dd MMMM yyyy",
          );
          final time = AppDateUtils.formatCustom(
            activity.createdAt,
            "HH:mm ",
          );
          return Text(
            "$date\n$time",
            style: theme.textTheme.bodyMedium,
          );
        },
      ),
      AppTableColumn<Activity>(
        title: 'Supervisor',
        flex: 2,
        cellBuilder: (ctx, activity) {
          final theme = Theme.of(ctx);

          return Text(
            activity.supervisor.account?.name ?? "",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      AppTableColumn<Activity>(
        title: 'Approval',
        flex: 2,
        cellBuilder: (ctx, activity) {
          return CompactStatusChip.forApproval(activity.approvers.approvalStatus);
        },
      ),
      AppTableColumn<Activity>(
        title: 'Approvers',
        flex: 3,
        cellBuilder: (ctx, activity) {
          return ApproversWrapDisplay(
            approvers: activity.approvers,
            fallbackDate: activity.updatedAt ?? activity.createdAt,
          );
        },
      ),

    ];
  }
}


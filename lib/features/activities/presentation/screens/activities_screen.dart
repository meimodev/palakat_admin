import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/activity.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/date_range_filter.dart';
import '../widgets/activity_detail_view.dart';
import '../../../../core/widgets/supervisor_chip.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/services/approver_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/repositories/activities_repository.dart';
import '../../../../core/models/approver.dart';
import '../../../../core/models/approval_status.dart';
import '../../../../core/models/app_error.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

// Approver logic moved to shared ApproverService

class _ActivityApproverChip extends StatelessWidget {
  final ApproverDecision approver;

  const _ActivityApproverChip({
    super.key,
    required this.approver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;
    String? dateText;
    switch (approver.decision) {
      case ApprovalStatus.approved:
        icon = Icons.check;
        color = Colors.green;
        if (approver.decisionAt != null) {
          dateText = AppDateUtils.formatStandardDate(approver.decisionAt!);
        }
        break;
      case ApprovalStatus.rejected:
        icon = Icons.close;
        color = Colors.red;
        if (approver.decisionAt != null) {
          dateText = AppDateUtils.formatStandardDate(approver.decisionAt!);
        }
        break;
      case ApprovalStatus.pending:
        icon = Icons.watch_later_outlined;
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.person, size: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(approver.name, style: theme.textTheme.labelMedium),
              if (dateText != null) ...[
                Text(
                  dateText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final Debouncer _searchDebouncer;

  @override
  void initState() {
    super.initState();
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebouncer(() {
      ref.read(activitiesScreenStateProvider.notifier)
          .updateSearchQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenState = ref.watch(activitiesScreenStateProvider);
    final activitiesAsync = ref.watch(activitiesAsyncProvider);
    final screenNotifier = ref.read(activitiesScreenStateProvider.notifier);
    
    return Material(
      color: theme.colorScheme.surface,
      child: activitiesAsync.when(
        loading: () => const AppLoadingWidget(
          message: 'Loading activities...',
        ),
        error: (error, stackTrace) => AppErrorWidget(
          error: error is AppError 
            ? error 
            : AppError.unknown('Failed to load activities'),
          onRetry: () => ref.refresh(activitiesAsyncProvider),
        ),
        data: (activities) => _buildActivitiesContent(
          context, 
          theme, 
          screenState, 
          activities, 
          screenNotifier,
        ),
      ),
    );
  }

  Widget _buildActivitiesContent(
    BuildContext context,
    ThemeData theme,
    ActivitiesScreenStateData screenState,
    List<Activity> activities,
    ActivitiesScreenState screenNotifier,
  ) {
    final repository = ref.read(activitiesRepositoryProvider);
    final filteredActivities = repository.filterActivities(
      activities,
      screenState.searchQuery,
      screenState.dateRange,
    );
    final paginatedActivities = repository.getPaginatedActivities(
      filteredActivities,
      screenState.page,
      screenState.rowsPerPage,
    );
    
    final total = filteredActivities.length;

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
              title: 'Activities',
              subtitle: 'Manage church activities and events.',
              child: Column(
                children: [
                  // Search + Date Range
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search activities...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {}, // Handled by debouncer
                        ),
                      ),
                      const SizedBox(width: 8),
                      DateRangeFilter(
                        value: screenState.dateRange,
                        onChanged: (r) => screenNotifier.updateDateRange(r),
                        onClear: () => screenNotifier.clearDateRange(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Header Row (table-like)
                  _ActivitiesHeader(),
                  const Divider(height: 1),

                  // Rows
                  ...[
                    for (final activity in paginatedActivities)
                      _ActivityRow(
                        key: ValueKey(activity.id),
                        activity: activity,
                        onTap: () => _showActivityDetail(activity),
                      ),
                  ],

                  const SizedBox(height: 8),
                  // Pagination
                  PaginationBar(
                    showingCount: paginatedActivities.length,
                    totalCount: total,
                    rowsPerPage: screenState.rowsPerPage,
                    page: screenState.page,
                    pageCount: (total / screenState.rowsPerPage).ceil().clamp(1, 9999),
                    onRowsPerPageChanged: (v) => screenNotifier.updateRowsPerPage(v),
                    onPrev: () => screenNotifier.previousPage(),
                    onNext: () => screenNotifier.nextPage((total / screenState.rowsPerPage).ceil() - 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(Activity? activity) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      pageBuilder: (ctx, anim, secAnim) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            // Dimmed background
            Opacity(
              opacity: 0.4 * curved.value,
              child: ModalBarrier(dismissible: true, color: Colors.black54),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: ActivityDetailView(
                  activity: activity!,
                  onClose: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Mock data generation moved to ActivitiesRepository
}

class _ActivitiesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Title'), flex: 3, style: textStyle),
          _cell(const Text('Type'), flex: 2, style: textStyle),
          _cell(const Text('Start Date'), flex: 2, style: textStyle),
          _cell(const Text('Supervisor'), flex: 3, style: textStyle),
          _cell(const Text('Approver'), flex: 3, style: textStyle),
          _cell(const Text('Status'), flex: 2, style: textStyle),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) => Expanded(
    flex: flex,
    child: DefaultTextStyle.merge(style: style, child: child),
  );
}

class _ActivityRow extends ConsumerWidget {
  final Activity activity;
  final VoidCallback onTap;

  const _ActivityRow({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.04);
    final approvers = ref.watch(activityApproversProvider(activity));
    final approvalStatus = ref.watch(activityApprovalStatusProvider(activity));
    final approverService = ref.watch(approverServiceProvider);
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              hoverColor: hoverColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _cell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      flex: 3,
                    ),
                    _cell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _TypeChip(type: activity.type),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Text(
                        _formatDate(activity.startDate),
                        style: theme.textTheme.bodyMedium,
                      ),
                      flex: 2,
                    ),
                    _cell(
                      flex: 3,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SupervisorChip(
                          name: activity.supervisor,
                          positions: activity.supervisorPositions,
                        ),
                      ),
                    ),
                    _cell(
                      Wrap(
                        spacing: 8,
                        direction: Axis.vertical,
                        runSpacing: 8,
                        children: [
                          for (final approver in approvers)
                            _ActivityApproverChip(approver: approver),
                        ],
                      ),
                      flex: 3,
                    ),
                    _cell(
                      Builder(
                        builder: (context) {
                          final statusDisplay = approverService.getStatusDisplay(approvalStatus);
                          return StatusChip(
                            label: statusDisplay.label,
                            background: Color(statusDisplay.colorValue).withValues(alpha: 0.1),
                            foreground: Color(statusDisplay.colorValue),
                            icon: IconData(statusDisplay.iconCodePoint, fontFamily: 'MaterialIcons'),
                          );
                        },
                      ),
                      flex: 2,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return AppDateUtils.formatStandardDate(d);
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}

class _TypeChip extends StatelessWidget {
  final ActivityType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (type) {
      ActivityType.service => (Colors.teal, Icons.handshake),
      ActivityType.event => (Colors.red, Icons.event),
      ActivityType.announcement => (Colors.orange, Icons.campaign),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/app_error.dart';
import 'package:palakat_admin/core/utils/date_utils.dart';
import 'package:palakat_admin/core/widgets/app_snackbars.dart';
import 'package:palakat_admin/features/members/presentation/state/members_screen_state.dart';

import '../widgets/member_edit_drawer.dart';
import '../widgets/member_name_cell.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/app_table.dart';
import 'package:palakat_admin/core/widgets/positions_cell.dart';

import '../state/members_controller.dart';
import 'package:palakat_admin/core/widgets/quick_stat_card.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  /// Shows member drawer for editing or creating
  void _showMemberDrawer({int? accountId}) {
    final isEditing = accountId != null;
    
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
            child: MemberEditDrawer(
              accountId: accountId,
              onSave: (account) async {
                final controller = ref.read(membersControllerProvider.notifier);
                await controller.saveMember(account);
                if (!context.mounted) return;
                AppSnackbars.showSuccess(
                  context,
                  title: isEditing ? 'Saved' : 'Created',
                  message: isEditing 
                      ? 'Member saved successfully'
                      : 'Member created successfully',
                );
              },
              onDelete: isEditing
                  ? () {
                      final controller = ref.read(membersControllerProvider.notifier);
                      controller
                          .deleteMember(accountId)
                          .then((_) {
                            if (!context.mounted) return;
                            AppSnackbars.showSuccess(
                              context,
                              title: 'Deleted',
                              message: 'Member deleted successfully',
                            );
                          })
                          .catchError((e) {
                            if (!context.mounted) return;
                            _handleMemberOperationError(
                              context,
                              e,
                              operation: 'delete',
                            );
                          });
                    }
                  : null,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
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

  /// Handles errors from member operations (save/create/delete)
  void _handleMemberOperationError(
    BuildContext context,
    dynamic error, {
    required String operation,
  }) {
    final msg = error is AppError
        ? error.userMessage
        : 'Failed to $operation member';
    final code = error is AppError ? error.statusCode : null;
    
    AppSnackbars.showError(
      context,
      title: '${operation.toUpperCase()} failed',
      message: msg,
      statusCode: code,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final MembersScreenState state = ref.watch(membersControllerProvider);
    final MembersController controller = ref.watch(
      membersControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Members', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Manage church members and their information.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: 'Member Directory',
              subtitle: 'A record of all church members.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick stats row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      QuickStatCard(
                        label: 'Total Members',
                        value: state.counts.value?.total.toString() ?? "",
                        icon: Icons.groups_outlined,
                        iconColor: Colors.orange.shade700,
                        iconBackgroundColor: Colors.orange.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: 'App Claimed',
                        value: state.counts.value?.claimed.toString() ?? "",
                        icon: Icons.phone_android_outlined,
                        iconColor: Colors.purple.shade600,
                        iconBackgroundColor: Colors.purple.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: 'Baptized',
                        value: state.counts.value?.baptized.toString() ?? "",
                        icon: Icons.water_drop_outlined,
                        iconColor: Colors.blue.shade600,
                        iconBackgroundColor: Colors.blue.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: 'Sidi',
                        value: state.counts.value?.sidi.toString() ?? "",
                        icon: Icons.emoji_people_outlined,
                        iconColor: Colors.green.shade600,
                        iconBackgroundColor: Colors.green.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTable<Account>(
                    loading: state.accounts.isLoading,
                    data: state.accounts.value?.data ?? [],
                    errorText: state.accounts.hasError
                        ? state.accounts.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    pagination: () {
                      final pageSize =
                          state.accounts.value?.pagination.pageSize ?? 10;
                      final page = state.accounts.value?.pagination.page ?? 1;
                      final total = state.accounts.value?.pagination.total ?? 0;

                      final hasPrev =
                          state.accounts.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          state.accounts.value?.pagination.hasNext ?? false;

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
                      searchHint: 'Search name / column / position ...',
                      onSearchChanged: controller.onChangedSearch,
                      positionOptions: state.positions.value,
                      positionValue: state.selectedPosition,
                      onPositionChanged: controller.onChangedPosition,
                      actionLabel: 'New Member',
                      actionIcon: Icons.add,
                      onActionPressed: () => _showMemberDrawer(),
                    ),
                    onRowTap: (account) async {
                      _showMemberDrawer(accountId: account.id);
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

  /// Builds the table column configuration for the members table
  static List<AppTableColumn<Account>> _buildTableColumns() {
    return [
      AppTableColumn<Account>(
        title: 'Name',
        flex: 4,
        cellBuilder: (ctx, account) => MemberNameCell(account: account),
      ),
      AppTableColumn<Account>(
        title: 'Phone',
        flex: 3,
        cellBuilder: (ctx, account) {
          final theme = Theme.of(ctx);
          return SelectableText(
            account.phone.formattedPhone,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
      AppTableColumn<Account>(
        title: 'Birth',
        flex: 2,
        cellBuilder: (ctx, account) {
          final theme = Theme.of(ctx);
          final formattedDob = AppDateUtils.formatCustom(account.dob, 'yyyy, MMMM dd');
          final age = account.calculateAge;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDob,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                age.formatted,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
      AppTableColumn<Account>(
        title: 'BIPRA',
        flex: 2,
        cellBuilder: (ctx, account) {
          final theme = Theme.of(ctx);
          final bipra = account.calculateBipra;
          return Text(
            bipra.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      AppTableColumn<Account>(
        title: 'Positions',
        flex: 3,
        cellBuilder: (ctx, account) {
          final positions = (account.membership?.membershipPositions ?? [])
              .map((e) => e.name)
              .toList();
          return PositionsCell(positions: positions);
        },
      ),
    ];
  }
}

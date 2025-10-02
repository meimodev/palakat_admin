import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/features/members/presentation/state/members_screen_state.dart';

import '../widgets/edit_member_drawer.dart';
import '../widgets/member_name_cell.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/app_table.dart';
import 'package:palakat_admin/core/widgets/status_badge.dart';
import 'package:palakat_admin/core/widgets/positions_cell.dart';

import '../state/members_controller.dart';
import 'package:palakat_admin/core/widgets/quick_stat_card.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: 'App Claimed',
                        value: state.counts.value?.claimed.toString() ?? "",
                        icon: Icons.phone_android_outlined,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: 'Baptized',
                        value: state.counts.value?.baptized.toString() ?? "",
                        icon: Icons.water_drop_outlined,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: 'Sidi',
                        value: state.counts.value?.sidi.toString() ?? "",
                        icon: Icons.emoji_people_outlined,
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
                      onActionPressed: () {
                        final now = DateTime.now();
                        final Account newAccount = Account(
                          id: now.microsecondsSinceEpoch,
                          name: '',
                          phone: '',
                          email: '',
                          gender: Gender.male,
                          married: false,
                          dob: DateTime(2000, 1, 1),
                          claimed: false,
                          createdAt: now,
                          updatedAt: now,
                          membership: Membership(
                            id: 0,
                            baptize: false,
                            sidi: false,
                            createdAt: now,
                            updatedAt: now,
                            membershipPositions: const [],
                          ),
                        );
                        showEditMemberDrawer(context, account: newAccount);
                      },
                    ),
                    onRowTap: (account) async {
                      await showEditMemberDrawer(context, account: account);
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
        title: 'Positions',
        flex: 3,
        cellBuilder: (ctx, account) {
          final positions =
              (account.membership?.membershipPositions ?? [])
                  .map((e) => e.name)
                  .toList();
          return PositionsCell(positions: positions);
        },
      ),
    ];
  }
}

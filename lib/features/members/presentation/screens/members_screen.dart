import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/features/members/presentation/state/members_state.dart';

import '../widgets/edit_member_drawer.dart';
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

    final MembersState state = ref.watch(membersControllerProvider);
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
                  // AppTable with built-in filter bar
                  AppTable<Account>(
                    loading: state.accounts.isLoading,
                    data: state.accounts.value ?? [],
                    errorText: state.accounts.hasError
                        ? state.accounts.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    pagination: AppTablePaginationConfig(
                      showingCount: 100,
                      totalCount: state.accounts.value?.length ?? 0,
                      rowsPerPage: 10,
                      page: 0,
                      pageCount: 1,
                      rowSizes: [5, 10, 15, 20, 30, 50, 100],
                      onRowsPerPageChanged: (page) {
                        print(page);
                      },
                      onPrev: () {
                        print("On Prev");
                      },
                      onNext: () {
                        print("On Next");
                      },
                    ),
                    filtersConfig: AppTableFiltersConfig(
                      searchHint: 'Search members...',
                      onSearchChanged: controller.setSearch,
                      positionOptions: controller.fetchMemberPositions(),
                      positionValue: null,
                      onPositionChanged: controller.setPositionFilter,
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
                    columns: [
                      AppTableColumn<Account>(
                        title: 'Name',
                        flex: 4,
                        cellBuilder: (ctx, account) {
                          final theme = Theme.of(ctx);
                          final membership = account.membership;
                          final isBaptized = membership?.baptize ?? false;
                          final isSidi = membership?.sidi ?? false;
                          final isLinked = account.claimed;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      account.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isBaptized)
                                        StatusBadge(
                                          icon: Icons.water_drop,
                                          color: Colors.blue.shade600,
                                          backgroundColor: Colors.blue.shade50,
                                          tooltip: 'Baptized',
                                        ),
                                      if (isSidi)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4.0,
                                          ),
                                          child: StatusBadge(
                                            icon: Icons.emoji_people,
                                            color: Colors.green.shade600,
                                            backgroundColor:
                                                Colors.green.shade50,
                                            tooltip: 'Sidi',
                                          ),
                                        ),
                                      if (isLinked)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4.0,
                                          ),
                                          child: StatusBadge(
                                            icon: Icons.phone_android,
                                            color: Colors.purple.shade600,
                                            backgroundColor:
                                                Colors.purple.shade50,
                                            tooltip: 'App Linked',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Member',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      AppTableColumn<Account>(
                        title: 'Phone',
                        flex: 3,
                        cellBuilder: (ctx, account) {
                          final theme = Theme.of(ctx);
                          return Text(
                            account.phone,
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

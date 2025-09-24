import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/expandable_surface_card.dart';
import '../../../../core/models/church.dart';
import '../../../../core/models/column.dart' as cm;
import '../../../../core/models/member_position.dart';
import '../../../../core/models/membership.dart';
import '../../../../core/models/location.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../widgets/church_info_edit_drawer.dart';
import '../widgets/column_edit_drawer.dart';
import '../widgets/position_edit_drawer.dart';
import '../../application/church_controller.dart';

class ChurchScreen extends ConsumerStatefulWidget {
  const ChurchScreen({super.key});

  @override
  ConsumerState<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends ConsumerState<ChurchScreen> {
  void _openEditDrawer(Church church) {
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
            child: ChurchInfoEditDrawer(
              church: church,
              onSave: (updatedChurch) {
                ref.read(churchControllerProvider.notifier).updateChurch(updatedChurch);
              },
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

  void _openColumnEditDrawer(cm.Column column) {
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
            child: ColumnEditDrawer(
              column: column,
              churchId: ref.read(churchControllerProvider).value?.id ?? 0,
              onSave: (updatedColumn) {
                final church = ref.read(churchControllerProvider).value;
                if (church == null) return;
                final index = church.columns.indexWhere((c) => c.id == column.id);
                if (index != -1) {
                  final updatedColumns = List<cm.Column>.from(church.columns);
                  updatedColumns[index] = updatedColumn;
                  ref
                      .read(churchControllerProvider.notifier)
                      .updateChurch(church.copyWith(columns: updatedColumns));
                }
              },
              onDelete: () {
                final church = ref.read(churchControllerProvider).value;
                if (church == null) return;
                final updatedColumns = church.columns.where((c) => c.id != column.id).toList();
                ref
                    .read(churchControllerProvider.notifier)
                    .updateChurch(church.copyWith(columns: updatedColumns));
              },
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

  void _openAddColumnDrawer() {
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
            child: ColumnEditDrawer(
              column: null,
              churchId: ref.read(churchControllerProvider).value?.id ?? 0,
              onSave: (newColumn) {
                final church = ref.read(churchControllerProvider).value;
                if (church == null) return;
                final updated = List<cm.Column>.from(church.columns)..add(newColumn);
                ref
                    .read(churchControllerProvider.notifier)
                    .updateChurch(church.copyWith(columns: updated));
              },
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

  void _openPositionEditDrawer(MemberPosition position) {
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
            child: PositionEditDrawer(
              position: position,
              onSave: (updatedPosition) {
                final church = ref.read(churchControllerProvider).value;
                if (church == null) return;
                final index = church.membershipPositions.indexWhere((p) => p.id == position.id);
                if (index != -1) {
                  final updatedPositions = List<MemberPosition>.from(church.membershipPositions);
                  updatedPositions[index] = updatedPosition;
                  ref
                      .read(churchControllerProvider.notifier)
                      .updateChurch(church.copyWith(membershipPositions: updatedPositions));
                }
              },
              onDelete: () {
                final church = ref.read(churchControllerProvider).value;
                if (church == null) return;
                final updatedPositions =
                    church.membershipPositions.where((p) => p.id != position.id).toList();
                ref
                    .read(churchControllerProvider.notifier)
                    .updateChurch(church.copyWith(membershipPositions: updatedPositions));
              },
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

  void _openAddPositionDrawer() {
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
            child: PositionEditDrawer(
              position: null,
              onSave: (newPosition) {
                final church = ref.read(churchControllerProvider).value;
                if (church == null) return;
                final updated = List<MemberPosition>.from(church.membershipPositions)
                  ..add(newPosition);
                ref
                    .read(churchControllerProvider.notifier)
                    .updateChurch(church.copyWith(membershipPositions: updated));
              },
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
    final churchAsync = ref.watch(churchControllerProvider);

    return churchAsync.when(
      loading: () => _buildLoadingSkeleton(theme),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Failed to load church profile'),
        ),
      ),
      data: (church) {
        return Material(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Church Profile', style: theme.textTheme.headlineMedium),
                Text(
                  'Manage your church\'s public information and columns.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Church Information Section
                _buildChurchInformationSection(theme, church),
                const SizedBox(height: 24),

                // Column Management Section
                _buildColumnManagementSection(theme, church),
                const SizedBox(height: 24),

                // Position Management Section
                _buildPositionManagementSection(theme, church),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Material(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoadingShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ShimmerPlaceholders.text(
                  width: 240,
                  height: 28,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                ShimmerPlaceholders.text(width: 360, height: 16),
                const SizedBox(height: 24),

                // Church Information Card skeleton
                ShimmerPlaceholders.card(height: 220),
                const SizedBox(height: 24),

                // Column Management section skeleton (table)
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ShimmerPlaceholders.table(rows: 4, columns: 4),
                  ),
                ),
                const SizedBox(height: 24),

                // Position Management section skeleton (table)
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ShimmerPlaceholders.table(rows: 4, columns: 4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChurchInformationSection(ThemeData theme, Church church) {
    return ExpandableSurfaceCard(
      title: 'Church Information',
      subtitle:
          'Update the details for your church. This information may be visible to members.',
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: () => _openEditDrawer(church),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildInfoRow('Church Name', church.name, theme),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Phone Number',
                  church.phoneNumber ?? '-',
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow('Email', church.email ?? '-', theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Address', church.location.name, theme),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Longitude',
                  church.location.longitude.toString(),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  'Latitude',
                  church.location.latitude.toString(),
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'About the Church',
            church.description ?? '-',
            theme,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildColumnManagementSection(ThemeData theme, Church church) {
    return ExpandableSurfaceCard(
      title: 'Column Management',
      subtitle:
          'Manage your church columns. Total columns: ${church.columns.length}',
      trailing: ElevatedButton.icon(
        onPressed: _openAddColumnDrawer,
        icon: const Icon(Icons.add),
        label: const Text('Add Column'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Column List
          ...church.columns.map((column) {
            final hoverColor = theme.colorScheme.primary.withValues(
              alpha: 0.04,
            );
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openColumnEditDrawer(column),
                  hoverColor: hoverColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${column.id.toString()} - ",
                          style: theme.textTheme.bodySmall,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            column.name,
                            style: theme.textTheme.bodyMedium,
                          ),
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPositionManagementSection(ThemeData theme, Church church) {
    return ExpandableSurfaceCard(
      title: 'Position Management',
      subtitle:
          'Manage member positions. Total positions: ${church.membershipPositions.length}',
      trailing: ElevatedButton.icon(
        onPressed: _openAddPositionDrawer,
        icon: const Icon(Icons.add),
        label: const Text('Add Position'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Position List (no header)
          ...church.membershipPositions.map((position) {
            final hoverColor = theme.colorScheme.primary.withValues(
              alpha: 0.04,
            );
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openPositionEditDrawer(position),
                  hoverColor: hoverColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            position.name,
                            style: theme.textTheme.bodyMedium,
                          ),
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
            );
          }),
        ],
      ),
    );
  }
}

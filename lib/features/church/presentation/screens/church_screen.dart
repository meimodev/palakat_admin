import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/church/application/church_state.dart';
import '../../../../core/widgets/expandable_surface_card.dart';
import '../../../../core/models/church.dart';
import '../../../../core/models/column.dart' as cm;
import '../../../../core/models/membership.dart';
import '../../../../core/models/member_position.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../widgets/church_info_edit_drawer.dart';
import '../widgets/church_location_edit_drawer.dart';
import '../widgets/column_edit_drawer.dart';
import '../widgets/position_edit_drawer.dart';
import '../../application/church_controller.dart';
import '../../../../core/models/app_error.dart';
import '../../../../core/widgets/app_snackbars.dart';

class ChurchScreen extends ConsumerStatefulWidget {
  const ChurchScreen({super.key});

  @override
  ConsumerState<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends ConsumerState<ChurchScreen> {

   ChurchController get churchController => ref.read(churchControllerProvider.notifier);
   ChurchState get state => ref.watch(churchControllerProvider);

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
               churchController
                    .saveChurch(updatedChurch)
                    .then((_) {
                      churchController.fetchChurch();
                      AppSnackbars.showSuccess(
                        context,
                        title: 'Saved',
                        message: 'Church updated successfully',
                      );
                    })
                    .catchError((e) {
                      final msg = e is AppError
                          ? e.userMessage
                          : 'Failed to update church';
                      final code = e is AppError ? e.statusCode : null;
                      AppSnackbars.showError(
                        context,
                        title: 'Update failed',
                        message: msg,
                        statusCode: code,
                      );
                    });
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

  void _openLocationEditDrawer(Church church) {
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
            child: ChurchLocationEditDrawer(
              church: church,
              onSave: (updatedChurch) {
                ref
                    .read(churchControllerProvider.notifier)
                    .saveLocation(updatedChurch.location)
                    .then((_) {
                      AppSnackbars.showSuccess(
                        context,
                        title: 'Saved',
                        message: 'Location updated successfully',
                      );
                    })
                    .catchError((e) {
                      final msg = e is AppError
                          ? e.userMessage
                          : 'Failed to update location';
                      final code = e is AppError ? e.statusCode : null;
                      AppSnackbars.showError(
                        context,
                        title: 'Update failed',
                        message: msg,
                        statusCode: code,
                      );
                    });
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

  Future<void> _openColumnEditDrawer(cm.Column column) async {
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
              columnId: column.id,
              churchId: column.churchId,
              onSave: (updatedColumn) {
                ref
                    .read(churchControllerProvider.notifier)
                    .saveColumn(updatedColumn);
              },
              onDelete: () {
                ref
                    .read(churchControllerProvider.notifier)
                    .deleteColumn(column.id!);
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

  void _openAddColumnDrawer(int churchId) {
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
              churchId: churchId,
              onSave: (newColumn) {
                final churchId =
                   state.church.value?.id ?? 0;
                final toCreate = cm.Column(
                  id: 0,
                  // placeholder; server will assign real id
                  name: newColumn.name,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  churchId: churchId,
                );
                ref
                    .read(churchControllerProvider.notifier)
                    .createColumn(toCreate);
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
              churchId: state.church.value!.id,
              positionId: position.id,
              onSave: (updatedPosition) {
                final church = state.church.value;
                if (church == null) return;
                final index = church.membershipPositions.indexWhere(
                  (p) => p.id == position.id,
                );
                if (index != -1) {
                  final updatedPositions = List<MemberPosition>.from(
                    church.membershipPositions,
                  );
                  updatedPositions[index] = updatedPosition;
                  ref
                      .read(churchControllerProvider.notifier)
                      .saveChurch(
                        church.copyWith(membershipPositions: updatedPositions),
                      );
                }
              },
              onDelete: () {
                final church = state.church.value;
                if (church == null) return;
                final updatedPositions = church.membershipPositions
                    .where((p) => p.id != position.id)
                    .toList();
                ref
                    .read(churchControllerProvider.notifier)
                    .saveChurch(
                      church.copyWith(membershipPositions: updatedPositions),
                    );
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
              churchId: state.church.value!.id,
              onSave: (newPosition) {
                final church = state.church.value;
                if (church == null) return;
                final updated = List<MemberPosition>.from(
                  church.membershipPositions,
                )..add(newPosition);
                ref
                    .read(churchControllerProvider.notifier)
                    .saveChurch(church.copyWith(membershipPositions: updated));
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

            _buildChurchInformationSection(theme),
            const SizedBox(height: 24),

            _buildLocationSection(theme),
            const SizedBox(height: 24),

            _buildColumnManagementSection(theme),
            const SizedBox(height: 24),

            _buildPositionManagementSection(theme),
          ],
        ),
      ),
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
                ShimmerPlaceholders.card(height: 160),
                const SizedBox(height: 24),

                // Location Card skeleton
                ShimmerPlaceholders.card(height: 160),
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

  Widget _cardError({
    required ThemeData theme,
    required Object error,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Failed to load this section.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChurchInformationSection(ThemeData theme) {
    final infoAsync = state.church;

    return ExpandableSurfaceCard(
      title: 'Church Information',
      subtitle:
          'Update the details for your church. This information may be visible to members.',
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: infoAsync.hasValue ? () => _openEditDrawer(infoAsync.value!) : null,
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceVariant,
        ),
      ),
      child: infoAsync.when(
        loading: () => LoadingShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ShimmerPlaceholders.text(width: 220, height: 16),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: ShimmerPlaceholders.text(width: double.infinity, height: 16)),
                const SizedBox(width: 16),
                Expanded(child: ShimmerPlaceholders.text(width: double.infinity, height: 16)),
              ]),
              const SizedBox(height: 16),
              ShimmerPlaceholders.text(width: double.infinity, height: 48),
              const SizedBox(height: 16),
            ],
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: () => churchController.fetchChurch(),
        ),
        data: (church) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildInfoRow('Church Name', church.name, theme),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildInfoRow('Phone Number', church.phoneNumber ?? '-', theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoRow('Email', church.email ?? '-', theme)),
            ]),
            const SizedBox(height: 16),
            _buildInfoRow('About the Church', church.description ?? '-', theme, maxLines: 3),
            const SizedBox(height: 16),
          ],
        ),
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

  Widget _buildLocationSection(ThemeData theme) {
    final locationAsync = state.location;

    return ExpandableSurfaceCard(
      title: 'Location',
      subtitle: 'Update address and coordinates for your church location.',
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: ()=> _openLocationEditDrawer(state.church.value!)  ,
        icon: const Icon(Icons.edit_location_alt),
        label: const Text('Edit Location'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceVariant,
        ),
      ),
      child: locationAsync.when(
        loading: () => LoadingShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ShimmerPlaceholders.text(width: double.infinity, height: 16),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: ShimmerPlaceholders.text(width: double.infinity, height: 16)),
                const SizedBox(width: 16),
                Expanded(child: ShimmerPlaceholders.text(width: double.infinity, height: 16)),
              ]),
              const SizedBox(height: 16),
            ],
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: () => churchController.fetchLocation(state.location.value!.id),
        ),
        data: (location) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildInfoRow('Address', location.name, theme),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildInfoRow('Longitude', location.longitude.toString(), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoRow('Latitude', location.latitude.toString(), theme)),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnManagementSection(ThemeData theme) {
    final columnsAsync = state.columns;

    return ExpandableSurfaceCard(
      title: 'Column Management',
      subtitle: columnsAsync.hasValue
          ? 'Manage your church columns. Total columns: ${columnsAsync.value!.length}'
          : 'Manage your church columns.',
      trailing: ElevatedButton.icon(
        onPressed:  () => _openAddColumnDrawer(state.church.value!.id) ,
        icon: const Icon(Icons.add),
        label: const Text('Add Column'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceVariant,
        ),
      ),
      child: columnsAsync.when(
        loading: () => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LoadingShimmer(child: ShimmerPlaceholders.table(rows: 4, columns: 3)),
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: () => churchController.fetchColumns(state.church.value!.id),
        ),
        data: (columns) => Column(
          children: [
            const SizedBox(height: 16),
            ...columns.map((column) {
              final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.04);
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await _openColumnEditDrawer(column);
                    },
                    hoverColor: hoverColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          Text("${column.id.toString()} - ", style: theme.textTheme.bodySmall),
                          Expanded(child: Text(column.name, style: theme.textTheme.bodyMedium)),
                          const Icon(Icons.chevron_right, size: 18, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionManagementSection(ThemeData theme) {
    final positionsAsync = state.positions;

    return ExpandableSurfaceCard(
      title: 'Position Management',
      subtitle: positionsAsync.hasValue
          ? 'Manage member positions. Total positions: ${positionsAsync.value!.length}'
          : 'Manage member positions.',
      trailing: ElevatedButton.icon(
        onPressed: _openAddPositionDrawer,
        icon: const Icon(Icons.add),
        label: const Text('Add Position'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: positionsAsync.when(
        loading: () => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LoadingShimmer(child: ShimmerPlaceholders.table(rows: 4, columns: 2)),
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: () => churchController.fetchPositions(state.church.value!.id),
        ),
        data: (positions) => Column(
          children: [
            const SizedBox(height: 16),
            ...positions.map((position) {
              final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.04);
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openPositionEditDrawer(position),
                    hoverColor: hoverColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          Expanded(child: Text(position.name, style: theme.textTheme.bodyMedium)),
                          const Icon(Icons.chevron_right, size: 18, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

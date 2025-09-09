import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/membership.dart';
import '../state/members_providers.dart';
import 'edit_member_drawer.dart';

class MembersTable extends ConsumerWidget {
  const MembersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slice = ref.watch(membersPageProvider);
    return Column(
      children: [
        const _MembersHeader(),
        for (final u in slice.rows)
          _MemberRow(member: u, onTap: () => _editMember(context, u, ref)),
      ],
    );
  }

  Future<void> _editMember(
    BuildContext context,
    Membership member,
    WidgetRef ref,
  ) async {
    final updatedMember = await showEditMemberDrawer(context, member: member);

    if (updatedMember != null) {
      // In a real app, you would update the member in your state management
      // For example, using Riverpod:
      // ref.read(membersProvider.notifier).updateMember(updatedMember);

      // For now, just show a snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Member updated')));
      }
    }
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          _cell(Text('Name', style: textStyle), flex: 4),
          _cell(Text('Phone', style: textStyle), flex: 3),
          _cell(Text('Positions', style: textStyle), flex: 3),
          const SizedBox(width: 20), // Space for chevron
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}

class _MemberRow extends StatelessWidget {
  final Membership member;
  final VoidCallback onTap;
  const _MemberRow({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoverColor = theme.colorScheme.surfaceContainerHighest;

    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              hoverColor: hoverColor,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _cell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  member.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status badges
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (member.isBaptized)
                                    _StatusBadge(
                                      icon: Icons.water_drop,
                                      color: Colors.blue.shade600,
                                      backgroundColor: Colors.blue.shade50,
                                      tooltip: 'Baptized',
                                    ),
                                  if (member.isSidi)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: _StatusBadge(
                                        icon: Icons.emoji_people,
                                        color: Colors.green.shade600,
                                        backgroundColor: Colors.green.shade50,
                                        tooltip: 'Sidi',
                                      ),
                                    ),
                                  if (member.isLinked)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: _StatusBadge(
                                        icon: Icons.phone_android,
                                        color: Colors.purple.shade600,
                                        backgroundColor: Colors.purple.shade50,
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
                      ),
                      flex: 4,
                    ),
                    _cell(
                      Text(
                        member.phone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      flex: 3,
                    ),
                    _cell(_PositionsCell(positions: member.positions), flex: 3),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
      ],
    );
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}

class _PositionsCell extends StatelessWidget {
  final List<String> positions;
  const _PositionsCell({required this.positions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (positions.isEmpty) return const Text('-');

    // Show only 1 position, then a "+N" text if there are more
    final firstPosition = positions.first;
    final remainingCount = positions.length - 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PositionChip(position: firstPosition),
        if (remainingCount > 0) ...[
          const SizedBox(width: 6),
          Text(
            '+$remainingCount',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String tooltip;

  const _StatusBadge({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _PositionChip extends StatelessWidget {
  final String position;
  const _PositionChip({required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Text(
        position,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

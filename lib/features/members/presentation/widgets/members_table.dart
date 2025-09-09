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
        const Divider(height: 1),
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
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Name'), flex: 4, style: textStyle),
          _cell(const Text('Phone'), flex: 3, style: textStyle),
          _cell(const Text('Positions'), flex: 3, style: textStyle),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) => Expanded(
    flex: flex,
    child: DefaultTextStyle.merge(style: style, child: child),
  );
}

class _MemberRow extends StatelessWidget {
  final Membership member;
  final VoidCallback onTap;
  const _MemberRow({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoverColor = theme.colorScheme.primary.withOpacity(0.04);
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _cell(
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      member.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Member',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (member.isBaptized ||
                                        member.isSidi ||
                                        member.isLinked)
                                      const SizedBox(width: 8),
                                    if (member.isBaptized)
                                      const Icon(
                                        Icons.water_drop_outlined,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                    if (member.isSidi)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4.0),
                                        child: Icon(
                                          Icons.emoji_people_outlined,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    if (member.isLinked)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4.0),
                                        child: Icon(
                                          Icons.phone_android_outlined,
                                          size: 16,
                                          color: Colors.purple,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      flex: 4,
                    ),
                    _cell(Text(member.phone), flex: 3),
                    _cell(_PositionsCell(positions: member.positions), flex: 3),
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

    // Show up to 2 position chips, then a "+N more" chip if there are more
    const maxVisible = 2;
    final visiblePositions = positions.take(maxVisible).toList();
    final remainingCount = positions.length - maxVisible;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        // Show visible position chips
        for (final position in visiblePositions)
          _PositionChip(position: position),

        // Show "+N more" chip if there are remaining positions
        if (remainingCount > 0)
          InkWell(
            onTap: () => _showAllPositions(context, positions),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '+$remainingCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAllPositions(BuildContext context, List<String> positions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Positions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: positions
                  .map((pos) => _PositionChip(position: pos))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        position,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

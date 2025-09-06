import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/members_providers.dart';
import 'edit_member_drawer.dart';

class MembersTable extends ConsumerWidget {
  const MembersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slice = ref.watch(membersPageProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Position')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final u in slice.rows)
            DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            u.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Member',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (u.isBaptized || u.isSidi || u.isLinked)
                            const SizedBox(width: 8),
                          if (u.isBaptized)
                            const Icon(
                              Icons.water_drop,
                              size: 14,
                              color: Colors.blue,
                            ),
                          if (u.isSidi)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.emoji_people,
                                size: 14,
                                color: Colors.green,
                              ),
                            ),
                          if (u.isLinked)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.link,
                                size: 14,
                                color: Colors.purple,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(Text(u.phone)),
                DataCell(
                  Builder(
                    builder: (context) {
                      if (u.positions.isEmpty) {
                        return const Text('-');
                      }

                      // If only one position, show it directly
                      if (u.positions.length == 1) {
                        return Text(
                          u.positions.first,
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }

                      // For multiple positions, show first one and +X for the rest
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('All Positions'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: u.positions
                                    .map(
                                      (pos) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Text('• $pos'),
                                      ),
                                    )
                                    .toList(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(text: '${u.positions.first} '),
                              TextSpan(
                                text: '+${u.positions.length - 1}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editMember(context, u, ref),
                    tooltip: 'Edit member',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _editMember(
      BuildContext context, Membership member, WidgetRef ref) async {
    final updatedMember = await showEditMemberDrawer(
      context,
      member: member,
    );

    if (updatedMember != null) {
      // In a real app, you would update the member in your state management
      // For example, using Riverpod:
      // ref.read(membersProvider.notifier).updateMember(updatedMember);
      
      // For now, just show a snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member updated')),
        );
      }
    }
  }
}

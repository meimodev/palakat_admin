import 'package:flutter/material.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = List.generate(8, (i) => (
      'Request #${1200 + i}',
      i % 2 == 0 ? 'Pending' : 'Approved',
      'By User ${i + 1}',
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Approvals', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final isApproved = item.$2 == 'Approved';
              final color = isApproved ? Colors.green : Colors.orange;
              return ListTile(
                title: Text(item.$1),
                subtitle: Text(item.$3),
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(item.$2),
                      side: BorderSide(color: color.withOpacity(0.4)),
                      backgroundColor: color.withOpacity(0.08),
                      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
                    ),
                    if (!isApproved)
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Approve'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

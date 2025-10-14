import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/expenses/expenses.dart';

class ExpenseDetailDrawer extends StatelessWidget {
  final ExpenseEntry entry;
  final VoidCallback onClose;
  const ExpenseDetailDrawer({
    super.key,
    required this.entry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: 'Expense Details',
      subtitle: 'View detailed information about this expense entry',
      onClose: onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          InfoSection(
            title: 'Basic Information',
            children: [
              InfoRow(label: 'Account ID', value: entry.accountId),
              InfoRow(
                label: 'Date',
                value: DateFormat('y-MM-dd').format(entry.date),
              ),
              InfoRow(
                label: 'Amount',
                value: NumberFormat.currency(
                  locale: 'en_PH',
                  symbol: '₱ ',
                ).format(entry.amount),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Approval Information
          InfoSection(
            title: 'Approval Information',
            children: [
              InfoRow(label: 'Approval ID', value: entry.approvalId),
              InfoRow(
                label: 'Approved Date',
                value: entry.approvedAt != null
                    ? DateFormat('y-MM-dd').format(entry.approvedAt!)
                    : '—',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Current Status (full-width)
          InfoSection(
            title: 'Current Status',
            children: [
              Builder(
                builder: (context) {
                  final (bg, fg, label, icon) = switch (entry.approvalStatus) {
                    ApprovalStatus.unconfirmed => (
                      Colors.orange.shade100,
                      Colors.orange.shade800,
                      'Pending',
                      Icons.schedule,
                    ),
                    ApprovalStatus.approved => (
                      Colors.green.shade100,
                      Colors.green.shade800,
                      'Approved',
                      Icons.check_circle,
                    ),
                    ApprovalStatus.rejected => (
                      Colors.red.shade100,
                      Colors.red.shade800,
                      'Rejected',
                      Icons.cancel,
                    ),
                  };
                  return StatusChip(
                    label: label,
                    background: bg,
                    foreground: fg,
                    icon: icon,
                    elevated: true,
                    fontSize: 13.5,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    fullWidth: true,
                  );
                },
              ),
            ],
          ),

          // TODO: Fix approvers display - Approver model doesn't have name/positions/decision fields
          // if (entry.approvers.isNotEmpty) ...[
          //   const SizedBox(height: 24),
          //   InfoSection(
          //     title: 'Approvers',
          //     children: [
          //       for (final approver in entry.approvers)
          //         Padding(
          //           padding: const EdgeInsets.only(bottom: 12),
          //           child: Builder(
          //             builder: (context) {
          //               IconData icon;
          //               Color color;
          //               String statusText;
          //               String? dateText;
          //
          //               switch (approver.status) {
          //                 case ApprovalStatus.approved:
          //                   icon = Icons.check_circle;
          //                   color = Colors.green;
          //                   statusText = 'Approved';
          //                   if (approver.updatedAt != null) {
          //                     final d = approver.updatedAt!;
          //                     dateText =
          //                         'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          //                   }
          //                   break;
          //                 case ApprovalStatus.rejected:
          //                   icon = Icons.cancel;
          //                   color = Colors.red;
          //                   statusText = 'Rejected';
          //                   if (approver.updatedAt != null) {
          //                     final d = approver.updatedAt!;
          //                     dateText =
          //                         'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          //                   }
          //                   break;
          //                 case ApprovalStatus.unconfirmed:
          //                   icon = Icons.pending;
          //                   color = Colors.orange;
          //                   statusText = 'Pending';
          //                   break;
          //               }
          //
          //               return ApproverCard(
          //                 name: approver.membership?.name ?? 'Unknown',
          //                 positions: approver.membership?.positions ?? [],
          //                 statusText: statusText,
          //                 statusColor: color,
          //                 leadingIcon: icon,
          //                 leadingColor: color,
          //                 trailingText: dateText,
          //               );
          //             },
          //           ),
          //         ),
          //     ],
          //   ),
          // ],

          const SizedBox(height: 24),

          // Notes
          InfoSection(
            title: 'Notes',
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(entry.notes, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ],
      ),
      footer: Center(
        child: FilledButton.icon(
          onPressed: () {
            // Placeholder for future actions (e.g., edit, export)
          },
          icon: const Icon(Icons.receipt_long),
          label: const Text('Export Expense'),
        ),
      ),
    );
  }
}

 

 

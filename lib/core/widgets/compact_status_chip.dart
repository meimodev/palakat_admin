import 'package:flutter/material.dart';
import 'package:palakat_admin/core/models/approval_status.dart';

class CompactStatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const CompactStatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  factory CompactStatusChip.forApproval(ApprovalStatus status) {
    final (bg, fg, label) = switch (status) {
      ApprovalStatus.pending => (
        Colors.orange.shade50,
        Colors.orange.shade700,
        'Pending',
      ),
      ApprovalStatus.approved => (
        Colors.green.shade50,
        Colors.green.shade700,
        'Approved',
      ),
      ApprovalStatus.rejected => (
        Colors.red.shade50,
        Colors.red.shade700,
        'Rejected',
      ),
    };
    return CompactStatusChip(label: label, background: bg, foreground: fg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foreground.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }
}

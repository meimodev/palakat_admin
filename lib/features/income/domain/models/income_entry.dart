import 'package:palakat_admin/core/models/approval_status.dart';
import 'package:palakat_admin/core/models/approver.dart';

class IncomeEntry {
  final String accountId;
  final DateTime date;
  final String notes;
  final double amount;

  // Approval metadata
  final String approvalId;
  final ApprovalStatus approvalStatus;
  final DateTime? approvedAt;
  final List<ApproverDecision> approvers;

  const IncomeEntry({
    required this.accountId,
    required this.date,
    required this.notes,
    required this.amount,
    required this.approvalId,
    required this.approvalStatus,
    this.approvedAt,
    this.approvers = const [],
  });
}

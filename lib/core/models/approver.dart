import 'package:palakat_admin/core/models/approval_status.dart';

class ApproverDecision {
  final String name;
  final List<String> positions;
  final ApprovalStatus decision;
  final DateTime? decisionAt;
  const ApproverDecision({
    required this.name,
    this.positions = const [],
    required this.decision,
    this.decisionAt,
  });
}

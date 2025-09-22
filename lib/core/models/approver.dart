import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/approval_status.dart';

part 'approver.freezed.dart';
part 'approver.g.dart';

@freezed
abstract class ApproverDecision with _$ApproverDecision {
  const factory ApproverDecision({
    required String name,
    @Default([]) List<String> positions,
    required ApprovalStatus decision,
    DateTime? decisionAt,
  }) = _ApproverDecision;

  factory ApproverDecision.fromJson(Map<String, dynamic> json) => _$ApproverDecisionFromJson(json);
}

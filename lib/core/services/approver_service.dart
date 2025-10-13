import 'package:palakat_admin/core/constants/enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/approver.dart';

part 'approver_service.g.dart';

/// Service for managing activity approvers and their decisions
class ApproverService {
  /// Generate mock approvers for an activity based on its status
  /// This consolidates the duplicated logic from activities_screen.dart and activity_detail_view.dart

  /// Calculate overall approval status from individual approver decisions
  ApprovalStatus calculateOverallStatus(List<Approver> approvers) {
    if (approvers.isEmpty) return ApprovalStatus.unconfirmed;

    final hasRejected = approvers.any(
      (a) => a.status == ApprovalStatus.rejected,
    );
    if (hasRejected) return ApprovalStatus.rejected;

    final allApproved = approvers.every(
      (a) => a.status == ApprovalStatus.approved,
    );
    if (allApproved) return ApprovalStatus.approved;

    return ApprovalStatus.unconfirmed;
  }

  /// Get status display information (label, colors, icon)
  ApprovalStatusDisplay getStatusDisplay(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return const ApprovalStatusDisplay(
          label: 'Approved',
          colorValue: 0xFF4CAF50, // Colors.green
          iconCodePoint: 0xe86c, // Icons.check_circle
        );
      case ApprovalStatus.rejected:
        return const ApprovalStatusDisplay(
          label: 'Rejected',
          colorValue: 0xFFF44336, // Colors.red
          iconCodePoint: 0xe5c9, // Icons.cancel
        );
      case ApprovalStatus.unconfirmed:
        return const ApprovalStatusDisplay(
          label: 'Unconfirmed',
          colorValue: 0xFFFF9800, // Colors.orange
          iconCodePoint: 0xe8b5, // Icons.pending
        );
    }
  }
}

/// Data class for approval status display information
class ApprovalStatusDisplay {
  final String label;
  final int colorValue;
  final int iconCodePoint;

  const ApprovalStatusDisplay({
    required this.label,
    required this.colorValue,
    required this.iconCodePoint,
  });
}

/// Riverpod provider for ApproverService
@riverpod
ApproverService approverService(Ref ref) {
  return ApproverService();
}

/// Provider for getting approvers for a specific activity


/// Provider for getting overall approval status for a specific activity
// @riverpod
// ApprovalStatus activityApprovalStatus(Ref ref, Activity activity) {
//   final approvers = ref.watch(activityApproversProvider(activity));
//   final service = ref.watch(approverServiceProvider);
//   return service.calculateOverallStatus(approvers);
// }

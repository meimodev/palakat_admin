import 'package:flutter/material.dart';
import 'package:palakat_admin/core/constants/enums.dart';

/// Extension for ApprovalStatus enum providing display properties
extension ApprovalStatusExtension on ApprovalStatus {
  /// Display label for the approval status
  String get displayLabel {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  /// Icon representing the approval status
  IconData get icon {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return Icons.schedule;
      case ApprovalStatus.approved:
        return Icons.check_circle;
      case ApprovalStatus.rejected:
        return Icons.cancel;
    }
  }

  /// Background color for status chips
  Color get backgroundColor {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return Colors.orange.shade100;
      case ApprovalStatus.approved:
        return Colors.green.shade100;
      case ApprovalStatus.rejected:
        return Colors.red.shade100;
    }
  }

  /// Foreground/text color for status chips
  Color get foregroundColor {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return Colors.orange.shade800;
      case ApprovalStatus.approved:
        return Colors.green.shade800;
      case ApprovalStatus.rejected:
        return Colors.red.shade800;
    }
  }

  /// Returns all display properties as a record for convenience
  /// Returns: (backgroundColor, foregroundColor, displayLabel, icon)
  (Color bg, Color fg, String label, IconData icon) get displayProperties {
    return (backgroundColor, foregroundColor, displayLabel, icon);
  }
}

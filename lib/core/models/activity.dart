import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

enum ActivityType {
  @JsonValue('service')
  service,
  @JsonValue('event')
  event,
  @JsonValue('announcement')
  announcement,
}

enum ActivityStatus {
  @JsonValue('planned')
  planned,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String title,
    required String description,
    required ActivityType type,
    required ActivityStatus status,
    required DateTime startDate,
    DateTime? endDate,
    required String supervisor,
    required List<String> supervisorPositions,
    required List<String> participants,
    String? location,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.service:
        return 'Service';
      case ActivityType.event:
        return 'Event';
      case ActivityType.announcement:
        return 'Announcement';
    }
  }
}

extension ActivityStatusExtension on ActivityStatus {
  String get displayName {
    switch (this) {
      case ActivityStatus.planned:
        return 'Planned';
      case ActivityStatus.ongoing:
        return 'Ongoing';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
    }
  }
}


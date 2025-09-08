enum ActivityType {
  service,
  event,
  announcement,
}

enum ActivityStatus {
  planned,
  ongoing,
  completed,
  cancelled,
}

class Activity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final ActivityStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String organizer;
  final List<String> organizerPositions;
  final List<String> participants;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.organizer,
    required this.organizerPositions,
    required this.participants,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    ActivityType? type,
    ActivityStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? organizer,
    List<String>? organizerPositions,
    List<String>? participants,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      organizer: organizer ?? this.organizer,
      organizerPositions: organizerPositions ?? this.organizerPositions,
      participants: participants ?? this.participants,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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

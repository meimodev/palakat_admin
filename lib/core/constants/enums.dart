import 'package:freezed_annotation/freezed_annotation.dart';

enum Gender {
  @JsonValue("MALE")
  male,
  @JsonValue("FEMALE")
  female,
}

enum MaritalStatus {
  @JsonValue("SINGLE")
  single,
  @JsonValue("MARRIED")
  married,
}

enum ActivityType {
  @JsonValue("SERVICE")
  service,
  @JsonValue("EVENT")
  event,
  @JsonValue("ANNOUNCEMENT")
  announcement,
  // articles,
}

@JsonEnum(valueField: 'abv')
enum Bipra {
  general("Jemaat", "JMT"),
  fathers("Pria / Kaum Bapa", "PKB"),
  mothers("Wanita / Kaum Ibu", "WKI"),
  youths("Pemuda", "PMD"),
  teens("Remaja", "RMJ"),
  kids("Anak Sekolah Minggu", "ASM");

  const Bipra(this.name, this.abv);

  final String name;
  final String abv;
}

enum Reminder {
  tenMinutes("10 Minutes Before"),
  thirtyMinutes("30 Minutes Before"),
  oneHour("1 Hour Before"),
  twoHour("2 Hour Before");

  const Reminder(this.name);

  final String name;
}

enum MapOperationType {
  pinPoint,
  read,
}

enum ApprovalStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}


// ===== Centralized reusable enums =====

// Account-related
enum UserRole {
  @JsonValue('administrator')
  administrator,
  @JsonValue('moderator')
  moderator,
  @JsonValue('member')
  member,
}

enum AccountStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
}

// Activities
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

// Errors
enum ErrorType {
  @JsonValue('network')
  network,
  @JsonValue('validation')
  validation,
  @JsonValue('authentication')
  authentication,
  @JsonValue('authorization')
  authorization,
  @JsonValue('notFound')
  notFound,
  @JsonValue('serverError')
  serverError,
  @JsonValue('unknown')
  unknown,
}

// Navigation / UI
enum PageTransitionType {
  fadeWithScale,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fade,
}

// Inventory
enum InventoryCondition {
  good,
  used,
  new_,
  notApplicable;

  String get displayName {
    switch (this) {
      case InventoryCondition.good:
        return 'Good';
      case InventoryCondition.used:
        return 'Used';
      case InventoryCondition.new_:
        return 'New';
      case InventoryCondition.notApplicable:
        return 'N/A';
    }
  }
}

// Billing
enum BillingType {
  @JsonValue('subscription')
  subscription,
  @JsonValue('oneTime')
  oneTime,
  @JsonValue('recurring')
  recurring,
}

enum BillingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

enum PaymentMethod {
  @JsonValue('creditCard')
  creditCard,
  @JsonValue('bankTransfer')
  bankTransfer,
  @JsonValue('cash')
  cash,
  @JsonValue('check')
  check,
  @JsonValue('digitalWallet')
  digitalWallet,
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
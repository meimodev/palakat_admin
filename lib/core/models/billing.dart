import 'package:freezed_annotation/freezed_annotation.dart';

part 'billing.freezed.dart';
part 'billing.g.dart';

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

@freezed
class BillingItem with _$BillingItem {
  const BillingItem._();

  const factory BillingItem({
    required String id,
    required String description,
    required double amount,
    required BillingType type,
    required BillingStatus status,
    required DateTime dueDate,
    DateTime? paidDate,
    PaymentMethod? paymentMethod,
    String? transactionId,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BillingItem;

  factory BillingItem.fromJson(Map<String, dynamic> json) => _$BillingItemFromJson(json);

  bool get isOverdue => status == BillingStatus.pending && DateTime.now().isAfter(dueDate);
  bool get isPaid => status == BillingStatus.paid;
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

@freezed
class PaymentHistory with _$PaymentHistory {
  const PaymentHistory._();

  const factory PaymentHistory({
    required String id,
    required String billingItemId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? transactionId,
    required DateTime paymentDate,
    String? notes,
    required String processedBy,
  }) = _PaymentHistory;

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => _$PaymentHistoryFromJson(json);

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

extension BillingTypeExtension on BillingType {
  String get displayName {
    switch (this) {
      case BillingType.subscription:
        return 'Subscription';
      case BillingType.oneTime:
        return 'One-time';
      case BillingType.recurring:
        return 'Recurring';
    }
  }
}

extension BillingStatusExtension on BillingStatus {
  String get displayName {
    switch (this) {
      case BillingStatus.pending:
        return 'Pending';
      case BillingStatus.paid:
        return 'Paid';
      case BillingStatus.overdue:
        return 'Overdue';
      case BillingStatus.cancelled:
        return 'Cancelled';
      case BillingStatus.refunded:
        return 'Refunded';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.check:
        return 'Check';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
    }
  }
}

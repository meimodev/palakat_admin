enum BillingType {
  subscription,
  oneTime,
  recurring,
}

enum BillingStatus {
  pending,
  paid,
  overdue,
  cancelled,
  refunded,
}

enum PaymentMethod {
  creditCard,
  bankTransfer,
  cash,
  check,
  digitalWallet,
}

class BillingItem {
  final String id;
  final String description;
  final double amount;
  final BillingType type;
  final BillingStatus status;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentMethod? paymentMethod;
  final String? transactionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillingItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.status,
    required this.dueDate,
    this.paidDate,
    this.paymentMethod,
    this.transactionId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  BillingItem copyWith({
    String? id,
    String? description,
    double? amount,
    BillingType? type,
    BillingStatus? status,
    DateTime? dueDate,
    DateTime? paidDate,
    PaymentMethod? paymentMethod,
    String? transactionId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue => status == BillingStatus.pending && DateTime.now().isAfter(dueDate);
  bool get isPaid => status == BillingStatus.paid;
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

class PaymentHistory {
  final String id;
  final String billingItemId;
  final double amount;
  final PaymentMethod paymentMethod;
  final String? transactionId;
  final DateTime paymentDate;
  final String? notes;
  final String processedBy;

  PaymentHistory({
    required this.id,
    required this.billingItemId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentDate,
    this.notes,
    required this.processedBy,
  });

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

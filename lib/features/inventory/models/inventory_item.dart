class InventoryItem {
  final String itemName;
  final String location;
  final InventoryCondition condition;
  final int quantity;
  final DateTime lastUpdate;
  final String updatedBy;

  const InventoryItem({
    required this.itemName,
    required this.location,
    required this.condition,
    required this.quantity,
    required this.lastUpdate,
    required this.updatedBy,
  });
}

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

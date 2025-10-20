import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/inventory/inventory.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 5;
  String _searchQuery = '';

  final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      itemName: 'Chairs',
      location: 'Main Hall',
      condition: InventoryCondition.good,
      quantity: 150,
      lastUpdate: DateTime.now().subtract(const Duration(days: 2)),
      updatedBy: 'Admin Bob',
    ),
    InventoryItem(
      itemName: 'Hymn Books',
      location: 'Sanctuary',
      condition: InventoryCondition.used,
      quantity: 25,
      lastUpdate: DateTime.now().subtract(const Duration(days: 10)),
      updatedBy: 'Deacon Mary',
    ),
    InventoryItem(
      itemName: 'Communion Wafers',
      location: 'Storage Room A',
      condition: InventoryCondition.new_,
      quantity: 500,
      lastUpdate: DateTime.now().subtract(const Duration(hours: 5)),
      updatedBy: 'Pastor John',
    ),
    InventoryItem(
      itemName: 'Projector Bulbs',
      location: 'AV Booth',
      condition: InventoryCondition.notApplicable,
      quantity: 0,
      lastUpdate: DateTime.now().subtract(const Duration(days: 30)),
      updatedBy: 'Admin Bob',
    ),
    InventoryItem(
      itemName: 'Offering Envelopes',
      location: 'Office',
      condition: InventoryCondition.new_,
      quantity: 1000,
      lastUpdate: DateTime.now().subtract(const Duration(days: 1)),
      updatedBy: 'Admin Bob',
    ),
  ];

  List<InventoryItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _inventoryItems;
    return _inventoryItems
        .where(
          (item) =>
              item.itemName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.location.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<InventoryItem> get _paginatedItems {
    final filtered = _filteredItems;
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredItems.length / _rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(48),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soon you will be able to:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _BulletPoint('Manage inventory across congregation'),
                    _BulletPoint('Centralize data and tracking'),
                    _BulletPoint('Monitor item location'),
                    _BulletPoint('Assign responsibility for items'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInventoryDetail(InventoryItem item) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: InventoryDetailDrawer(
        item: item,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Item Name'), flex: 3, style: style),
          _cell(const Text('Location'), flex: 2, style: style),
          _cell(const Text('Condition'), flex: 2, style: style),
          _cell(const Text('Quantity'), flex: 1, style: style),
          _cell(const Text('Last Update'), flex: 2, style: style),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: DefaultTextStyle(style: style ?? const TextStyle(), child: child),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;

  const _InventoryRow({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.04);
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              hoverColor: hoverColor,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    _cell(
                      Text(
                        item.itemName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      flex: 3,
                    ),
                    _cell(Text(item.location), flex: 2),
                    _cell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _ConditionBadge(condition: item.condition),
                      ),
                      flex: 2,
                    ),
                    _cell(Text('${item.quantity}'), flex: 1),
                    _cell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTimeAgo(item.lastUpdate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            item.updatedBy,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      flex: 2,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _cell(Widget child, {int flex = 1}) {
    return Expanded(flex: flex, child: child);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else {
        return 'about 1 month ago';
      }
    } else if (difference.inHours > 0) {
      return 'about ${difference.inHours} hours ago';
    } else {
      return 'just now';
    }
  }
}

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.condition});

  final InventoryCondition condition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;

    switch (condition) {
      case InventoryCondition.good:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
      case InventoryCondition.used:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
      case InventoryCondition.new_:
        backgroundColor = Colors.black;
        textColor = Colors.white;
        break;
      case InventoryCondition.notApplicable:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        condition.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

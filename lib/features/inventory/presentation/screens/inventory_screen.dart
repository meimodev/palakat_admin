import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/pagination_bar.dart';
import '../widgets/inventory_detail_drawer.dart';

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
    return _inventoryItems.where((item) =>
      item.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.location.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
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
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Text('Inventory', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Track church assets and supplies.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Main Content Card
          SurfaceCard(
            title: 'Inventory List',
            subtitle: 'All physical assets and supplies.',
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search inventory...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Table Header
                const _InventoryHeader(),
                const Divider(height: 1),

                // Table Rows
                ...[
                  for (final item in _paginatedItems)
                    _InventoryRow(
                      item: item,
                      onTap: () => _showInventoryDetail(item),
                    ),
                ],

                const SizedBox(height: 8),
                
                // Pagination
                PaginationBar(
                  showingCount: _paginatedItems.length,
                  totalCount: _filteredItems.length,
                  rowsPerPage: _rowsPerPage,
                  page: _currentPage - 1, // PaginationBar expects zero-based
                  pageCount: _totalPages,
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _rowsPerPage = value;
                      _currentPage = 1;
                    });
                  },
                  onPrev: () {
                    setState(() {
                      if (_currentPage > 1) _currentPage--;
                    });
                  },
                  onNext: () {
                    setState(() {
                      if (_currentPage < _totalPages) _currentPage++;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInventoryDetail(InventoryItem item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      pageBuilder: (ctx, anim, secAnim) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            Opacity(
              opacity: 0.4 * curved.value,
              child: const ModalBarrier(
                dismissible: true,
                color: Colors.black54,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: InventoryDetailDrawer(
                  item: item,
                  onClose: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
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

  Widget _cell(
    Widget child, {
    int flex = 1,
    TextStyle? style,
  }) {
    return Expanded(
      flex: flex,
      child: DefaultTextStyle(
        style: style ?? const TextStyle(),
        child: child,
      ),
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
    
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                _cell(_ConditionBadge(condition: item.condition), flex: 2),
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
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _cell(Widget child, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: child,
    );
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

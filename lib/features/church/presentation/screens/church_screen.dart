import 'package:flutter/material.dart';
import '../../../../core/widgets/expandable_surface_card.dart';
import '../../../../core/models/church.dart';
import '../../../../core/models/column.dart' as cm;
import '../../../../core/models/member_position.dart';
import '../../../../core/models/membership.dart';
import '../../../../core/models/location.dart';
import '../widgets/church_info_edit_drawer.dart';
import '../widgets/column_edit_drawer.dart';
import '../widgets/position_edit_drawer.dart';

class ChurchScreen extends StatefulWidget {
  const ChurchScreen({super.key});

  @override
  State<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends State<ChurchScreen> {
  late Church _church;

  @override
  void initState() {
    super.initState();
    _church = _generateMockChurch();
  }

  Church _generateMockChurch() {
    return Church(
      id: 1,
      name: 'Grace Community Church',
      phoneNumber: '(123) 456-7890',
      email: 'contact@gracecommunity.com',
      description:
          'Grace Community Church is a family of believers dedicated to knowing God and making Him known. We are committed to the teachings of the Bible and fostering a community of faith, hope, and love.',
      location: Location(
        id: 1,
        name: '123 Blessing Ave, Faith City, FS 12345',
        latitude: 14.5995,
        longitude: 120.9842,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      columns: [
        cm.Column(
          id: '1',
          number: 101,
          name: 'Alpha',
          createdAt: DateTime.now(),
        ),
        cm.Column(
          id: '2',
          number: 102,
          name: 'Beta',
          createdAt: DateTime.now(),
        ),
        cm.Column(
          id: '3',
          number: 103,
          name: 'Gamma',
          createdAt: DateTime.now(),
        ),
        cm.Column(
          id: '4',
          number: 201,
          name: 'Delta',
          createdAt: DateTime.now(),
        ),
        cm.Column(
          id: '5',
          number: 202,
          name: 'Epsilon',
          createdAt: DateTime.now(),
        ),
        cm.Column(
          id: '6',
          number: 203,
          name: 'Zeta',
          createdAt: DateTime.now(),
        ),
        cm.Column(id: '7', number: 301, name: 'Eta', createdAt: DateTime.now()),
        cm.Column(
          id: '8',
          number: 302,
          name: 'Theta',
          createdAt: DateTime.now(),
        ),
      ],
      memberships: const <Membership>[],
      membershipPositions: [
        MemberPosition(
          id: 1,
          churchId: 1,
          columnId: 1,
          name: 'Pastor',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 2,
          churchId: 1,
          columnId: 1,
          name: 'Deacon',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 3,
          churchId: 1,
          columnId: 2,
          name: 'Elder',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 4,
          churchId: 1,
          columnId: 2,
          name: 'Member',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 5,
          churchId: 1,
          columnId: 3,
          name: 'Choir Member',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 6,
          churchId: 1,
          columnId: 3,
          name: 'BPMS',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 7,
          churchId: 1,
          columnId: 4,
          name: 'Choir Leader',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 8,
          churchId: 1,
          columnId: 5,
          name: 'Sunday School Teacher',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MemberPosition(
          id: 9,
          churchId: 1,
          columnId: 6,
          name: 'Youth Leader',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _openEditDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: ChurchInfoEditDrawer(
              church: _church,
              onSave: (updatedChurch) {
                setState(() {
                  _church = updatedChurch;
                });
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }

  void _openColumnEditDrawer(cm.Column column) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: ColumnEditDrawer(
              column: column,
              onSave: (updatedColumn) {
                setState(() {
                  final index = _church.columns.indexWhere(
                    (c) => c.id == column.id,
                  );
                  if (index != -1) {
                    final updatedColumns = List<cm.Column>.from(
                      _church.columns,
                    );
                    updatedColumns[index] = updatedColumn;
                    _church = _church.copyWith(columns: updatedColumns);
                  }
                });
              },
              onDelete: () {
                setState(() {
                  final updatedColumns = _church.columns
                      .where((c) => c.id != column.id)
                      .toList();
                  _church = _church.copyWith(columns: updatedColumns);
                });
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }

  void _openAddColumnDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: ColumnEditDrawer(
              column: null,
              onSave: (newColumn) {
                setState(() {
                  final updated = List<cm.Column>.from(_church.columns)
                    ..add(newColumn);
                  _church = _church.copyWith(columns: updated);
                });
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }

  void _openPositionEditDrawer(MemberPosition position) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: PositionEditDrawer(
              position: position,
              onSave: (updatedPosition) {
                setState(() {
                  final index = _church.membershipPositions.indexWhere(
                    (p) => p.id == position.id,
                  );
                  if (index != -1) {
                    final updatedPositions = List<MemberPosition>.from(
                      _church.membershipPositions,
                    );
                    updatedPositions[index] = updatedPosition;
                    _church = _church.copyWith(
                      membershipPositions: updatedPositions,
                    );
                  }
                });
              },
              onDelete: () {
                setState(() {
                  final updatedPositions = _church.membershipPositions
                      .where((p) => p.id != position.id)
                      .toList();
                  _church = _church.copyWith(
                    membershipPositions: updatedPositions,
                  );
                });
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }

  void _openAddPositionDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: PositionEditDrawer(
              position: null,
              onSave: (newPosition) {
                setState(() {
                  final updated = List<MemberPosition>.from(
                    _church.membershipPositions,
                  )..add(newPosition);
                  _church = _church.copyWith(membershipPositions: updated);
                });
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Church Profile', style: theme.textTheme.headlineMedium),
            Text(
              'Manage your church\'s public information and columns.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Church Information Section
            _buildChurchInformationSection(theme),
            const SizedBox(height: 24),

            // Column Management Section
            _buildColumnManagementSection(theme),
            const SizedBox(height: 24),

            // Position Management Section
            _buildPositionManagementSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildChurchInformationSection(ThemeData theme) {
    return ExpandableSurfaceCard(
      title: 'Church Information',
      subtitle:
          'Update the details for your church. This information may be visible to members.',
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: _openEditDrawer,
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildInfoRow('Church Name', _church.name, theme),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Phone Number',
                  _church.phoneNumber ?? '-',
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow('Email', _church.email ?? '-', theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Address', _church.location.name, theme),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Longitude',
                  _church.location.longitude.toString(),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  'Latitude',
                  _church.location.latitude.toString(),
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'About the Church',
            _church.description ?? '-',
            theme,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildColumnManagementSection(ThemeData theme) {
    return ExpandableSurfaceCard(
      title: 'Column Management',
      subtitle:
          'Manage your church columns. Total columns: ${_church.columns.length}',
      trailing: ElevatedButton.icon(
        onPressed: _openAddColumnDrawer,
        icon: const Icon(Icons.add),
        label: const Text('Add Column'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Column List
          ...List.generate(_church.columns.length, (index) {
            final column = _church.columns[index];
            final hoverColor = theme.colorScheme.primary.withValues(
              alpha: 0.04,
            );
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openColumnEditDrawer(column),
                  hoverColor: hoverColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            column.number.toString(),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${_getMembersForColumn(column.id).length} member${_getMembersForColumn(column.id).length == 1 ? '' : 's'}',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPositionManagementSection(ThemeData theme) {
    return ExpandableSurfaceCard(
      title: 'Position Management',
      subtitle:
          'Manage member positions. Total positions: ${_church.membershipPositions.length}',
      trailing: ElevatedButton.icon(
        onPressed: _openAddPositionDrawer,
        icon: const Icon(Icons.add),
        label: const Text('Add Position'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Position List (no header)
          ...List.generate(_church.membershipPositions.length, (index) {
            final position = _church.membershipPositions[index];
            final hoverColor = theme.colorScheme.primary.withValues(
              alpha: 0.04,
            );
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openPositionEditDrawer(position),
                  hoverColor: hoverColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            position.name,
                            style: theme.textTheme.bodyMedium,
                          ),
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
            );
          }),
        ],
      ),
    );
  }

  // Mock method to get members for a column - replace with actual data source
  List<String> _getMembersForColumn(String columnId) {
    // This is mock data - replace with actual member data from your data source
    final mockColumnMembers = {
      'col1': ['Alice Johnson', 'Bob Smith', 'Carol Davis', 'David Wilson'],
      'col2': ['Eve Brown', 'Frank Miller', 'Grace Taylor'],
      'col3': [
        'Henry Clark',
        'Ivy Martinez',
        'Jack Anderson',
        'Kate Thompson',
        'Leo Garcia',
      ],
    };

    // For now, return mock data based on column ID
    // In a real app, you'd query your member database
    return mockColumnMembers[columnId] ?? [];
  }
}

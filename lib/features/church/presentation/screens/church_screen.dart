import 'package:flutter/material.dart';
import '../../../../core/widgets/expandable_surface_card.dart';
import '../../../../core/models/church_profile.dart';
import '../widgets/church_info_edit_drawer.dart';
import '../widgets/column_edit_drawer.dart';
import '../widgets/position_edit_drawer.dart';

class ChurchScreen extends StatefulWidget {
  const ChurchScreen({super.key});

  @override
  State<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends State<ChurchScreen> {
  late ChurchProfile _churchProfile;

  @override
  void initState() {
    super.initState();
    _churchProfile = _generateMockChurchProfile();
  }

  ChurchProfile _generateMockChurchProfile() {
    return ChurchProfile(
      id: '1',
      name: 'Grace Community Church',
      address: '123 Blessing Ave, Faith City, FS 12345',
      phoneNumber: '(123) 456-7890',
      email: 'contact@gracecommunity.com',
      aboutChurch:
          'Grace Community Church is a family of believers dedicated to knowing God and making Him known. We are committed to the teachings of the Bible and fostering a community of faith, hope, and love.',
      columns: [
        ChurchColumn(
          id: '1',
          number: 101,
          name: 'Alpha',
          createdAt: DateTime.now(),
        ),
        ChurchColumn(
          id: '2',
          number: 102,
          name: 'Beta',
          createdAt: DateTime.now(),
        ),
        ChurchColumn(
          id: '3',
          number: 103,
          name: 'Gamma',
          createdAt: DateTime.now(),
        ),
        ChurchColumn(
          id: '4',
          number: 201,
          name: 'Delta',
          createdAt: DateTime.now(),
        ),
        ChurchColumn(
          id: '5',
          number: 202,
          name: 'Epsilon',
          createdAt: DateTime.now(),
        ),
        ChurchColumn(
          id: '6',
          number: 203,
          name: 'Zeta',
          createdAt: DateTime.now(),
        ),
        ChurchColumn(
          id: '7',
          number: 301,
          name: 'Eta',
          createdAt: DateTime.now(),
        ),
        ChurchColumn(
          id: '8',
          number: 302,
          name: 'Theta',
          createdAt: DateTime.now(),
        ),
      ],
      positions: [
        ChurchPosition(id: '1', name: 'Pastor', createdAt: DateTime.now()),
        ChurchPosition(id: '2', name: 'Deacon', createdAt: DateTime.now()),
        ChurchPosition(id: '3', name: 'Elder', createdAt: DateTime.now()),
        ChurchPosition(id: '4', name: 'Member', createdAt: DateTime.now()),
        ChurchPosition(
          id: '5',
          name: 'Choir Member',
          createdAt: DateTime.now(),
        ),
        ChurchPosition(id: '6', name: 'BPMS', createdAt: DateTime.now()),
        ChurchPosition(
          id: '7',
          name: 'Choir Leader',
          createdAt: DateTime.now(),
        ),
        ChurchPosition(
          id: '8',
          name: 'Sunday School Teacher',
          createdAt: DateTime.now(),
        ),
        ChurchPosition(
          id: '9',
          name: 'Youth Leader',
          createdAt: DateTime.now(),
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
              churchProfile: _churchProfile,
              onSave: (updatedProfile) {
                setState(() {
                  _churchProfile = updatedProfile;
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

  void _openColumnEditDrawer(ChurchColumn column) {
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
                  final index = _churchProfile.columns.indexWhere(
                    (c) => c.id == column.id,
                  );
                  if (index != -1) {
                    final updatedColumns = List<ChurchColumn>.from(
                      _churchProfile.columns,
                    );
                    updatedColumns[index] = updatedColumn;
                    _churchProfile = _churchProfile.copyWith(
                      columns: updatedColumns,
                    );
                  }
                });
              },
              onDelete: () {
                setState(() {
                  final updatedColumns = _churchProfile.columns
                      .where((c) => c.id != column.id)
                      .toList();
                  _churchProfile = _churchProfile.copyWith(
                    columns: updatedColumns,
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
                  final updated = List<ChurchColumn>.from(
                    _churchProfile.columns,
                  )..add(newColumn);
                  _churchProfile = _churchProfile.copyWith(columns: updated);
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

  void _openPositionEditDrawer(ChurchPosition position) {
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
                  final index = _churchProfile.positions.indexWhere(
                    (p) => p.id == position.id,
                  );
                  if (index != -1) {
                    final updatedPositions = List<ChurchPosition>.from(
                      _churchProfile.positions,
                    );
                    updatedPositions[index] = updatedPosition;
                    _churchProfile = _churchProfile.copyWith(
                      positions: updatedPositions,
                    );
                  }
                });
              },
              onDelete: () {
                setState(() {
                  final updatedPositions = _churchProfile.positions
                      .where((p) => p.id != position.id)
                      .toList();
                  _churchProfile = _churchProfile.copyWith(
                    positions: updatedPositions,
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
                  final updated = List<ChurchPosition>.from(
                    _churchProfile.positions,
                  )..add(newPosition);
                  _churchProfile = _churchProfile.copyWith(positions: updated);
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
          _buildInfoRow('Church Name', _churchProfile.name, theme),
          const SizedBox(height: 16),
          _buildInfoRow('Address', _churchProfile.address, theme),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Phone Number',
                  _churchProfile.phoneNumber,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow('Email', _churchProfile.email, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'About the Church',
            _churchProfile.aboutChurch,
            theme,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Location Information
          if (_churchProfile.latitude != null &&
              _churchProfile.longitude != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Latitude',
                    _churchProfile.latitude!.toString(),
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    'Longitude',
                    _churchProfile.longitude!.toString(),
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Service Schedule
          if (_churchProfile.serviceSchedule != null)
            _buildInfoRow(
              'Service Schedule',
              _churchProfile.serviceSchedule!,
              theme,
              maxLines: 3,
            ),
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
          'Manage your church columns. Total columns: ${_churchProfile.columns.length}',
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
          ...List.generate(_churchProfile.columns.length, (index) {
            final column = _churchProfile.columns[index];
            final hoverColor = theme.colorScheme.primary.withOpacity(0.04);
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
          'Manage member positions. Total positions: ${_churchProfile.positions.length}',
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
          ...List.generate(_churchProfile.positions.length, (index) {
            final position = _churchProfile.positions[index];
            final hoverColor = theme.colorScheme.primary.withOpacity(0.04);
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
                        Text(
                          '${_getMembersForPosition(position.id).length} members',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.black54,
                          ),
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

  // Mock method to get members for a position - replace with actual data source
  List<String> _getMembersForPosition(String positionId) {
    // This is mock data - replace with actual member data from your data source
    final mockMembers = {
      'pos1': ['John Doe', 'Jane Smith'],
      'pos2': ['Mike Johnson', 'Sarah Wilson', 'David Brown'],
      'pos3': ['Emily Davis'],
    };

    // For now, return mock data based on position ID
    // In a real app, you'd query your member database
    return mockMembers[positionId] ?? [];
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

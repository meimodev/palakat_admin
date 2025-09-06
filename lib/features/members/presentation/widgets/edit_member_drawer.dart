import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/members/presentation/state/members_providers.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class EditMemberDrawer extends ConsumerStatefulWidget {
  final Membership member;

  const EditMemberDrawer({super.key, required this.member});

  @override
  ConsumerState<EditMemberDrawer> createState() => _EditMemberDrawerState();
}

class _EditMemberDrawerState extends ConsumerState<EditMemberDrawer> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late bool _isBaptized;
  late bool _isSidi;
  late bool _isLinked;
  late String _maritalStatus;
  late String _gender;
  final List<String> _positions = [];
  late final MultiSelectController<String> _positionsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _emailController = TextEditingController(text: widget.member.email);
    _phoneController = TextEditingController(text: widget.member.phone);
    _isBaptized = widget.member.isBaptized;
    _isSidi = widget.member.isSidi;
    _isLinked = widget.member.isLinked;
    _maritalStatus = widget.member.isMarried ? 'Married' : 'Single';
    _gender =
        widget.member.gender ?? 'Male'; // Default to Male if not specified
    _positions.addAll(widget.member.positions);

    // Initialize controller with items and preselect existing positions
    _positionsController = MultiSelectController<String>();
    final items = _pos
        .map((p) => DropdownItem<String>(label: p, value: p))
        .toList();
    _positionsController.setItems(items);
    _positionsController.selectWhere((item) => _positions.contains(item.value));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = width > 800 ? 600.0 : width * 0.75;

    return SizedBox(
      width: drawerWidth,
      height: MediaQuery.of(context).size.height,
      child: Material(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppBar(
                title: const Text('Edit Member'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      if (_isLinked) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This account has been claimed. Account info can only be changed by the owner.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else
                        const SizedBox(height: 12),
                      Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            enabled: !_isLinked,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              fillColor: _isLinked
                                  ? Colors.grey.shade100
                                  : null,
                              filled: _isLinked,
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            enabled: !_isLinked,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              fillColor: _isLinked
                                  ? Colors.grey.shade100
                                  : null,
                              filled: _isLinked,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _maritalStatus,
                            decoration: InputDecoration(
                              labelText: 'Marital Status',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              fillColor: _isLinked ? Colors.grey.shade100 : null,
                              filled: _isLinked,
                            ),
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'Single',
                                child: Text('Single'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Married',
                                child: Text('Married'),
                              ),
                            ],
                            onChanged: _isLinked
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _maritalStatus = newValue ?? 'Single';
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              fillColor: _isLinked ? Colors.grey.shade100 : null,
                              filled: _isLinked,
                            ),
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: _isLinked
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _gender = newValue ?? 'Male';
                                    });
                                  },
                          ),

                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Membership Information',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Baptized'),
                        value: _isBaptized,
                        onChanged: (value) =>
                            setState(() => _isBaptized = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: const Text('SIDI'),
                        value: _isSidi,
                        onChanged: (value) =>
                            setState(() => _isSidi = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Positions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      MultiDropdown<String>(
                        controller: _positionsController,
                        items: _pos
                            .map(
                              (p) => DropdownItem<String>(label: p, value: p),
                            )
                            .toList(),
                        fieldDecoration: const FieldDecoration(
                          hintText: 'Select positions',
                          showClearIcon: true,
                        ),

                        chipDecoration: ChipDecoration(
                          wrap: true,
                          runSpacing: 4,
                          spacing: 8,
                        ),
                        onSelectionChange: (selected) {
                          setState(() {
                            _positions
                              ..clear()
                              ..addAll(selected);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedColumn,
                        decoration: const InputDecoration(
                          labelText: 'Column',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableColumns.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedColumn = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 80), // Space for the save button
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveChanges,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> _pos = [
    'Elder',
    'Deacon',
    'Member',
    'Worship Leader',
    'Sunday School Teacher',
    'Youth Leader',
    'Small Group Leader',
    'Volunteer',
  ];

  String? _selectedColumn = 'General'; // Default column
  final List<String> _availableColumns = [
    'General',
    'Worship',
    'Children',
    'Youth',
    'Men',
    'Women',
    'Elders',
    'Deacons',
  ];

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedMember = widget.member.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        positions: _positions,
        isBaptized: _isBaptized,
        isSidi: _isSidi,
        isLinked: _isLinked,
        isMarried: _maritalStatus == 'Married',
        gender: _gender,
      );

      final membersNotifier = ref.read(membersProvider.notifier);

      // Check if this is a new member or an update
      final isNewMember = widget.member.email.isEmpty;

      if (isNewMember) {
        membersNotifier.addMember(updatedMember);
      } else {
        membersNotifier.updateMember(updatedMember);
      }

      if (mounted) {
        Navigator.of(context).pop(updatedMember);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Member ${isNewMember ? 'added' : 'updated'} successfully',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// Function to show the edit drawer
Future<Membership?> showEditMemberDrawer(
  BuildContext context, {
  required Membership member,
}) async {
  return await showGeneralDialog<Membership>(
    context: context,
    pageBuilder: (context, _, __) => Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // This expands to take remaining space and handles tap to dismiss
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black54),
            ),
          ),
          EditMemberDrawer(member: member),
        ],
      ),
    ),
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.fastEaseInToSlowEaseOut;
      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));

      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

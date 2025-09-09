import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/features/members/presentation/state/members_providers.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';

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
  // Positions will use the same UX as approval route editor: add via dropdown + chips
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
    final isNewMember = widget.member.email.isEmpty;
    return Material(
      child: SideDrawer(
        title: isNewMember ? 'Add New Member' : 'Edit Member',
        subtitle: isNewMember
            ? 'Add a new member to the church'
            : 'Update member information',
        onClose: () => Navigator.of(context).pop(),
        content: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Information Section
              _InfoSection(
                title: 'Account Information',
                children: [
                  if (_isLinked) ...[
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
                    const SizedBox(height: 16),
                  ],
                  _FormField(
                    label: 'Name',
                    child: TextFormField(
                      controller: _nameController,
                      enabled: !_isLinked,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        fillColor: _isLinked ? Colors.grey.shade100 : null,
                        filled: _isLinked,
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                  ),
                  _FormField(
                    label: 'Phone',
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: !_isLinked,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        fillColor: _isLinked ? Colors.grey.shade100 : null,
                        filled: _isLinked,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  _FormField(
                    label: 'Marital Status',
                    child: DropdownButtonFormField<String>(
                      value: _maritalStatus,
                      decoration: InputDecoration(
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
                  ),
                  _FormField(
                    label: 'Gender',
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
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
                      ],
                      onChanged: _isLinked
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _gender = newValue ?? 'Male';
                              });
                            },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Membership Information Section
              _InfoSection(
                title: 'Membership Information',
                children: [
                  _FormField(
                    label: 'Positions',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey(_positions.length),
                          value: null,
                          items: _pos
                              .where((p) => !_positions.contains(p))
                              .map(
                                (p) =>
                                    DropdownMenuItem(value: p, child: Text(p)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _positions.add(v);
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Add a position...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final p in _positions)
                              Chip(
                                label: Text(p),
                                onDeleted: () =>
                                    setState(() => _positions.remove(p)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _FormField(
                    label: 'Column',
                    child: DropdownButtonFormField<String>(
                      value: _selectedColumn,
                      decoration: const InputDecoration(
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
                  ),
                  _CheckboxField(
                    label: 'Baptized',
                    value: _isBaptized,
                    onChanged: (value) =>
                        setState(() => _isBaptized = value ?? false),
                  ),
                  _CheckboxField(
                    label: 'SIDI',
                    value: _isSidi,
                    onChanged: (value) =>
                        setState(() => _isSidi = value ?? false),
                  ),
                ],
              ),
            ],
          ),
        ),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: _saveChanges,
              child: Text(isNewMember ? 'Add Member' : 'Save Changes'),
            ),
          ],
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

    // pageBuilder: (context, _, _) => Scaffold(
    //   backgroundColor: Colors.transparent,
    //   body: Row(
    //     children: [
    //       // This expands to take remaining space and handles tap to dismiss
    //       Expanded(
    //         child: GestureDetector(
    //           onTap: () => Navigator.of(context).pop(),
    //           child: Container(color: Colors.black54),
    //         ),
    //       ),
    //       EditMemberDrawer(member: member),
    //     ],
    //   ),
    // ),
    barrierDismissible: true,
    barrierLabel: 'Close',
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, anim, secAnim) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, anim, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return Stack(
        children: [
          // Dimmed background
          Opacity(
            opacity: 0.4 * curved.value,
            child: ModalBarrier(dismissible: true, color: Colors.black54),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: EditMemberDrawer(member: member),
            ),
          ),
        ],
      );
    },
  );
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _CheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

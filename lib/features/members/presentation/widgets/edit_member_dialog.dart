import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:palakat_admin/core/models/membership.dart';

class EditMemberDialog extends StatefulWidget {
  final Membership member;
  
  const EditMemberDialog({
    super.key,
    required this.member,
  });

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late bool _isBaptized;
  late bool _isSidi;
  late bool _isLinked;
  final List<String> _positions = [];
  late final MultiSelectController<String> _positionsController;
  final _formKey = GlobalKey<FormState>();
  final List<String> _pos = const [
    'Elder',
    'Deacon',
    'Member',
    'Worship Leader',
    'Sunday School Teacher',
    'Youth Leader',
    'Small Group Leader',
    'Volunteer',
  ];

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nameController = TextEditingController(text: member.name);
    _emailController = TextEditingController(text: member.email);
    _phoneController = TextEditingController(text: member.phone);
    _isBaptized = member.isBaptized;
    _isSidi = member.isSidi;
    _isLinked = member.isLinked;
    _positions.addAll(member.positions);

    // Initialize positions controller with available options and preselect
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
    return AlertDialog(
      title: const Text('Edit Member'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Email is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text('Additional Information',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                onChanged: (value) => setState(() => _isSidi = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Linked to Family'),
                value: _isLinked,
                onChanged: (value) =>
                    setState(() => _isLinked = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              const SizedBox(height: 8),
              const Text('Positions',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              MultiDropdown<String>(
                controller: _positionsController,
                items: _pos
                    .map((p) => DropdownItem<String>(label: p, value: p))
                    .toList(),
                fieldDecoration: const FieldDecoration(
                  hintText: 'Select positions',
                  showClearIcon: true,
                ),
                chipDecoration: const ChipDecoration(
                  wrap: true,
                  spacing: 8,
                  runSpacing: 4,
                ),
                searchEnabled: true,
                onSelectionChange: (selected) {
                  setState(() {
                    _positions
                      ..clear()
                      ..addAll(selected);
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveChanges,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedMember = widget.member.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        positions: _positions,
        isBaptized: _isBaptized,
        isSidi: _isSidi,
        isLinked: _isLinked,
      );
      Navigator.of(context).pop(updatedMember);
    }
  }
}

// Extension to create a copy of AppMember with updated fields
extension AppMemberExtension on Membership {
  Membership copyWith({
    String? name,
    String? email,
    String? role,
    String? status,
    String? phone,
    List<String>? positions,
    bool? isBaptized,
    bool? isSidi,
    bool? isLinked,
  }) {
    return Membership(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      positions: positions ?? List.from(this.positions),
      isBaptized: isBaptized ?? this.isBaptized,
      isSidi: isSidi ?? this.isSidi,
      isLinked: isLinked ?? this.isLinked,
    );
  }
}

// Function to show the edit dialog
Future<Membership?> showEditMemberDialog(
  BuildContext context, {
  required Membership member,
}) async {
  return showDialog<Membership>(
    context: context,
    builder: (context) => EditMemberDialog(member: member),
  );
}

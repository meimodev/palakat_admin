import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/validation/validators.dart';

class EditMemberDialog extends StatefulWidget {
  final Account account;

  const EditMemberDialog({super.key, required this.account});

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late bool _isBaptized;
  late bool _isSidi;
  late bool _isClaimed;
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
    final account = widget.account;
    _nameController = TextEditingController(text: account.name);
    _emailController = TextEditingController(text: account.email);
    _phoneController = TextEditingController(text: account.phone);
    _isBaptized = account.membership?.baptize ?? false;
    _isSidi = account.membership?.sidi ?? false;
    _isClaimed = account.claimed;
    _positions.addAll(
      (account.membership?.membershipPositions ?? []).map((e) => e.name),
    );

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
                validator: (value) => Validators.required('Name is required')
                    .asFormFieldValidator(value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => Validators.required('Email is required')
                    .asFormFieldValidator(value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text(
                'Additional Information',
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
                onChanged: (value) => setState(() => _isSidi = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Linked to Family'),
                value: _isClaimed,
                onChanged: (value) =>
                    setState(() => _isClaimed = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Positions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
      final now = DateTime.now();
      final updatedMembership =
          (widget.account.membership ??
                  Membership(
                    id: 0,
                    baptize: false,
                    sidi: false,
                    createdAt: now,
                    updatedAt: now,
                    membershipPositions: const [],
                  ))
              .copyWith(
                baptize: _isBaptized,
                sidi: _isSidi,
                updatedAt: now,
                membershipPositions: [
                  for (var idx = 0; idx < _positions.length; idx++)
                    MemberPosition(
                      id: (widget.account.membership?.id ?? 0) * 100 + idx + 1,
                      churchId: 0,
                      name: _positions[idx],
                      createdAt: now,
                      updatedAt: now,
                    ),
                ],
              );

      final updatedAccount = widget.account.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        claimed: _isClaimed,
        updatedAt: now,
        membership: updatedMembership,
      );

      Navigator.of(context).pop(updatedAccount);
    }
  }
}

Future<Account?> showEditMemberDialog(
  BuildContext context, {
  required Account account,
}) async {
  return showDialog<Account>(
    context: context,
    builder: (context) => EditMemberDialog(account: account),
  );
}

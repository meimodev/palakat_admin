import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/core/validation/validators.dart';
import 'package:palakat_admin/core/widgets/info_section.dart';
import 'package:palakat_admin/core/widgets/position_selector.dart';
import 'package:palakat_admin/features/church/application/church_controller.dart';

class EditMemberDrawer extends ConsumerStatefulWidget {
  final Account account;

  const EditMemberDrawer({super.key, required this.account});

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
  late String _genderText;
  DateTime? _dateOfBirth;
  final List<MemberPosition> _positions = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _emailController = TextEditingController(text: widget.account.email);
    _phoneController = TextEditingController(text: widget.account.phone);
    _isBaptized = widget.account.membership?.baptize ?? false;
    _isSidi = widget.account.membership?.sidi ?? false;
    _isLinked = widget.account.claimed;
    _maritalStatus = widget.account.married ? 'Married' : 'Single';
    _genderText = widget.account.gender == Gender.female ? 'Female' : 'Male';
    _dateOfBirth = widget.account.dob;
    _positions.addAll(
      widget.account.membership?.membershipPositions ?? [],
    );
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
    final isNewMember = widget.account.email == null;
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
              InfoSection(
                title: 'Account Information',
                titleSpacing: 12,
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LabeledField(
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
                        validator: (value) => Validators.required('Name is required')
                            .asFormFieldValidator(value),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LabeledField(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LabeledField(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LabeledField(
                      label: 'Gender',
                      child: DropdownButtonFormField<String>(
                        value: _genderText,
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
                                  _genderText = newValue ?? 'Male';
                                });
                              },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LabeledField(
                      label: 'Date of Birth',
                      child: InkWell(
                        onTap: _isLinked ? null : _selectDateOfBirth,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            fillColor: _isLinked ? Colors.grey.shade100 : null,
                            filled: _isLinked,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: _isLinked ? Colors.grey : null,
                            ),
                          ),
                          child: Text(
                            _dateOfBirth != null
                                ? DateFormat('MMM dd, yyyy').format(_dateOfBirth!)
                                : 'Select date of birth',
                            style: TextStyle(
                              color: _dateOfBirth != null
                                  ? Theme.of(context).textTheme.bodyLarge?.color
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Membership Information Section
              InfoSection(
                title: 'Membership Information',
                titleSpacing: 12,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Builder(
                      builder: (context) {
                        final churchState = ref.watch(churchControllerProvider);
                        final availablePositions = churchState.positions.value ?? [];
                        
                        return PositionSelector(
                          selectedPositions: _positions,
                          onPositionsChanged: (positions) {
                            setState(() {
                              _positions
                                ..clear()
                                ..addAll(positions);
                            });
                          },
                          availablePositions: availablePositions,
                          label: 'Positions',
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LabeledField(
                      label: 'Column',
                      child: DropdownButtonFormField<String>(
                        value: _selectedColumn,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _availableColumns.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedColumn = newValue;
                          });
                        },
                      ),
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

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ??
          DateTime.now().subtract(
            const Duration(days: 365 * 25),
          ), // Default to 25 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final gender = _genderText == 'Female' ? Gender.female : Gender.male;
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
                membershipPositions: _positions,
              );

      final updatedAccount = widget.account.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        married: _maritalStatus == 'Married',
        gender: gender,
        dob: _dateOfBirth ?? widget.account.dob,
        updatedAt: now,
        membership: updatedMembership,
      );


      // Check if this is a new member or an update
      final isNewMember = widget.account.email == null;

      if (isNewMember) {
      } else {
      }

      if (mounted) {
        Navigator.of(context).pop(updatedAccount);
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
Future<Account?> showEditMemberDrawer(
  BuildContext context, {
  required Account account,
}) async {
  return await showGeneralDialog<Account>(
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
    //       EditMemberDrawer(account: account),
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
              child: EditMemberDrawer(account: account),
            ),
          ),
        ],
      );
    },
  );
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

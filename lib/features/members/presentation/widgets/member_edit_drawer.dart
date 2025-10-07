import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/core/models/account.dart';
import 'package:palakat_admin/core/models/membership.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/widgets/date_of_birth_picker.dart';
import 'package:palakat_admin/core/widgets/gender_dropdown.dart';
import 'package:palakat_admin/core/widgets/marital_status_dropdown.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';
import 'package:palakat_admin/core/validation/validators.dart';
import 'package:palakat_admin/core/widgets/info_section.dart';
import 'package:palakat_admin/core/widgets/position_selector.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/church/application/church_controller.dart';
import 'package:palakat_admin/features/members/presentation/state/members_controller.dart';
import 'package:palakat_admin/core/models/column.dart' as cm;

class MemberEditDrawer extends ConsumerStatefulWidget {
  final Function(Account) onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;
  final int? accountId;

  const MemberEditDrawer({
    super.key,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    this.accountId,
  });

  @override
  ConsumerState<MemberEditDrawer> createState() => _MemberEditDrawerState();
}

class _MemberEditDrawerState extends ConsumerState<MemberEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Account? _fetchedAccount; // latest member copy (fetched)
  bool _loading = false;
  bool _deleting = false;
  bool _saving = false;
  bool _isBaptized = false;
  bool _isSidi = false;
  bool _isClaimed = false;
  MaritalStatus _maritalStatus = MaritalStatus.single;
  Gender _gender = Gender.male;
  DateTime? _dateOfBirth;
  final List<MemberPosition> _positions = [];
  cm.Column? _selectedColumn;
  String? _errorMessage;
  bool _isFormatting = false; // Prevent recursive formatting in onChanged

  @override
  void initState() {
    super.initState();
    // Only fetch when editing an existing member
    if (widget.accountId != null) {
      _fetchAccountDetails();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhoneDigits(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _formatLocalPhone(String digits) {
    // Group per 4 digits; when length == 13, last group is 5 digits (4-4-5). Use '-' as separator.
    if (digits.isEmpty) return digits;
    final len = digits.length;
    // Cap at 13 for display
    final capped = len > 13 ? digits.substring(0, 13) : digits;
    final n = capped.length;

    if (n <= 4) return capped; // up to 4: raw
    if (n <= 8) {
      // 4 + remainder
      return '${capped.substring(0, 4)}-${capped.substring(4)}';
    }
    if (n < 13) {
      // 9..12: 4-4-remaining (1..4)
      return '${capped.substring(0, 4)}-${capped.substring(4, 8)}-${capped.substring(8)}';
    }
    // n == 13: 4-4-5
    return '${capped.substring(0, 4)}-${capped.substring(4, 8)}-${capped.substring(8, 13)}';
  }

  Future<void> _fetchAccountDetails() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final latest = await ref
          .read(membersControllerProvider.notifier)
          .fetchMember(widget.accountId!);

      setState(() {
        _loading = false;
        _errorMessage = null;
        _fetchedAccount = latest;
        _nameController.text = latest.name;
        _emailController.text = latest.email ?? '';
        // Format phone number for display
        final phoneDigits = _normalizePhoneDigits(latest.phone);
        _phoneController.text = _formatLocalPhone(phoneDigits);
        _isBaptized = latest.membership?.baptize ?? false;
        _isSidi = latest.membership?.sidi ?? false;
        _isClaimed = latest.claimed;
        _maritalStatus = latest.maritalStatus;
        _gender = latest.gender;
        _dateOfBirth = latest.dob;
        _positions.clear();
        _positions.addAll(latest.membership?.membershipPositions ?? []);
        _selectedColumn = latest.membership?.column;
      });
    } catch (e) {
      // Surface error inline but keep drawer open
      setState(() {
        _errorMessage = 'Failed to load member details';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    Account account;

    //read locally saved account
    final localAccount = ref.read(authControllerProvider).value!.account;

    // Normalize phone number (strip formatting) before saving
    final normalizedPhone = _normalizePhoneDigits(_phoneController.text.trim());
    
    account = Account(
      id: _fetchedAccount?.id,
      claimed: _fetchedAccount?.claimed ?? false,
      name: _nameController.text.trim(),
      phone: normalizedPhone,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      maritalStatus: _maritalStatus,
      gender: _gender,
      dob: _dateOfBirth!,
      createdAt: _fetchedAccount?.createdAt ?? DateTime.now(),
      membership: Membership(
        id: _fetchedAccount?.membership?.id,
        baptize: _isBaptized,
        sidi: _isSidi,
        createdAt: _fetchedAccount?.membership?.createdAt ?? DateTime.now(),
        membershipPositions: _positions,
        column: _selectedColumn,
        church:
            _fetchedAccount?.membership?.church ??
            localAccount.membership!.church,
      ),
    );

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(account);
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to save member';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _deleteMember() {
    if (widget.onDelete != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Member'),
          content: const Text(
            'Are you sure you want to delete this member? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // close confirm dialog
                setState(() {
                  _deleting = true;
                  _errorMessage = null;
                });
                try {
                  widget.onDelete!();
                  if (!mounted) return;
                  widget.onClose();
                } catch (e) {
                  // Surface error inline; parent shows snackbar too
                  if (!mounted) return;
                  setState(() {
                    _errorMessage = 'Failed to delete member';
                  });
                } finally {
                  if (mounted) setState(() => _deleting = false);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Single watch for church data (positions & columns)
    final churchState = ref.watch(churchControllerProvider);
    final availablePositions = churchState.positions.value ?? [];
    final availableColumns = churchState.columns.value ?? [];

    return SideDrawer(
      title: widget.accountId == null ? 'Add Member' : 'Edit Member',
      subtitle: widget.accountId == null
          ? 'Create a new member'
          : 'Update member information',
      onClose: widget.onClose,
      isLoading: (widget.accountId != null && _loading) || _deleting || _saving,
      loadingMessage: _deleting
          ? 'Deleting member...'
          : _saving
          ? 'Saving member...'
          : 'Loading member details...',
      errorMessage: _errorMessage,
      onRetry: widget.accountId != null && !_deleting
          ? _fetchAccountDetails
          : null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Information Section
            InfoSection(
              title: 'Account Information',
              titleSpacing: 16,
              children: [
                // Show ID field only when editing existing member
                if (_fetchedAccount != null) ...[
                  LabeledField(
                    label: 'Member ID',
                    child: Text(
                      "# ${_fetchedAccount!.id}",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_isClaimed) ...[
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
                LabeledField(
                  label: 'Name',
                  child: TextFormField(
                    controller: _nameController,
                    enabled: !_isClaimed,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Enter member name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: _isClaimed
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surface,
                    ),
                    validator: (value) => Validators.required(
                      'Name is required',
                    ).asFormFieldValidator(value),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Email',
                  child: TextFormField(
                    controller: _emailController,
                    enabled: !_isClaimed,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: _isClaimed
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Phone',
                  child: TextFormField(
                    controller: _phoneController,
                    enabled: !_isClaimed,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'e.g. 1234-5678-9012',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: _isClaimed
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surface,
                    ),
                    onChanged: (value) {
                      if (_isFormatting) return;
                      // Strip all non-digits and limit to 13 (no country code)
                      final digits = _normalizePhoneDigits(value);
                      final limited = digits.length > 13 ? digits.substring(0, 13) : digits;
                      final formatted = _formatLocalPhone(limited);
                      if (formatted != value) {
                        _isFormatting = true;
                        final baseOffset = formatted.length;
                        _phoneController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: baseOffset),
                        );
                        _isFormatting = false;
                      }
                    },
                    validator: (v) => Validators.combine<String>([
                      Validators.required('Phone number is required'),
                      Validators.optionalPhoneMinDigits(12, 'Phone number must contain at least 12 digits'),
                    ]).asFormFieldValidator(v),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Marital Status',
                  child: MaritalStatusDropdown(
                    value: _maritalStatus,
                    enabled: !_isClaimed,
                    onChanged: (MaritalStatus? newValue) {
                      setState(() {
                        _maritalStatus = newValue ?? MaritalStatus.single;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Gender',
                  child: GenderDropdown(
                    value: _gender,
                    enabled: !_isClaimed,
                    onChanged: (Gender? newValue) {
                      setState(() {
                        _gender = newValue ?? Gender.male;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Date of Birth',
                  child: DateOfBirthPicker(
                    value: _dateOfBirth,
                    enabled: !_isClaimed,
                    onChanged: (DateTime? newDate) {
                      setState(() {
                        _dateOfBirth = newDate;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Membership Information Section
            InfoSection(
              title: 'Membership Information',
              titleSpacing: 16,
              children: [
                PositionSelector(
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
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Column',
                  child: DropdownButtonFormField<cm.Column?>(
                    value: _selectedColumn,
                    decoration: InputDecoration(
                      hintText: 'Select a column',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: availableColumns.map((column) {
                      return DropdownMenuItem<cm.Column?>(
                        value: column,
                        child: Text(column.name),
                      );
                    }).toList(),
                    onChanged: (cm.Column? newValue) {
                      setState(() {
                        _selectedColumn = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Baptized'),
                        value: _isBaptized,
                        onChanged: (value) =>
                            setState(() => _isBaptized = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('SIDI'),
                        value: _isSidi,
                        onChanged: (value) =>
                            setState(() => _isSidi = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      footer: Row(
        children: [
          if (widget.onDelete != null && widget.accountId != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _deleteMember,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(widget.accountId == null ? 'Create' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}

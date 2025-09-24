import 'package:flutter/material.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/models/church.dart';
import '../../../../core/widgets/info_section.dart';

class ChurchInfoEditDrawer extends StatefulWidget {
  final Church church;
  final Function(Church) onSave;
  final VoidCallback onClose;

  const ChurchInfoEditDrawer({
    super.key,
    required this.church,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<ChurchInfoEditDrawer> createState() => _ChurchInfoEditDrawerState();
}

class _ChurchInfoEditDrawerState extends State<ChurchInfoEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.church.name);
    _addressController = TextEditingController(text: widget.church.location.name);
    _phoneController = TextEditingController(text: widget.church.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.church.email ?? '');
    _descriptionController = TextEditingController(text: widget.church.description ?? '');
    _latitudeController =
        TextEditingController(text: widget.church.location.latitude.toString());
    _longitudeController =
        TextEditingController(text: widget.church.location.longitude.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // parse coordinates
      final parsedLat = double.tryParse(_latitudeController.text.trim());
      final parsedLng = double.tryParse(_longitudeController.text.trim());

      final updatedLocation = widget.church.location.copyWith(
        name: _addressController.text.trim(),
        latitude: parsedLat ?? widget.church.location.latitude,
        longitude: parsedLng ?? widget.church.location.longitude,
        updatedAt: DateTime.now(),
      );

      final updatedChurch = widget.church.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        location: updatedLocation,
        updatedAt: DateTime.now(),
      );

      widget.onSave(updatedChurch);
      widget.onClose();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Church updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: 'Edit Church Information',
      subtitle: 'Update your church details',
      onClose: widget.onClose,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            InfoSection(
              title: 'Basic Information',
              titleSpacing: 16,
              children: [
                _FormField(
                  label: 'Church Name',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter church name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) => value?.trim().isEmpty == true ? 'Church name is required' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Address',
                  child: TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter church address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) => value?.trim().isEmpty == true ? 'Address is required' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        label: 'Latitude',
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            hintText: 'e.g. -6.1754',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Latitude is required';
                            }
                            final v = double.tryParse(value.trim());
                            if (v == null || v < -90 || v > 90) {
                              return 'Latitude must be a number between -90 and 90';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FormField(
                        label: 'Longitude',
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            hintText: 'e.g. 106.8272',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Longitude is required';
                            }
                            final v = double.tryParse(value.trim());
                            if (v == null || v < -180 || v > 180) {
                              return 'Longitude must be a number between -180 and 180';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        label: 'Phone Number (Optional)',
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            // Basic phone sanity check
                            final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
                            if (digits.length < 8) return 'Please enter a valid phone number';
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FormField(
                        label: 'Email (Optional)',
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter email address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Description (Optional)',
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe your church (visible to members)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      alignLabelWithHint: true,
                    ),
                    // Optional
                    validator: (_) => null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

 

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

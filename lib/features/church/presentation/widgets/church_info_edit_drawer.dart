import 'package:flutter/material.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/models/church_profile.dart';

class ChurchInfoEditDrawer extends StatefulWidget {
  final ChurchProfile churchProfile;
  final Function(ChurchProfile) onSave;
  final VoidCallback onClose;

  const ChurchInfoEditDrawer({
    super.key,
    required this.churchProfile,
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
  late TextEditingController _aboutController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _serviceScheduleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.churchProfile.name);
    _addressController = TextEditingController(text: widget.churchProfile.address);
    _phoneController = TextEditingController(text: widget.churchProfile.phoneNumber);
    _emailController = TextEditingController(text: widget.churchProfile.email);
    _aboutController = TextEditingController(text: widget.churchProfile.aboutChurch);
    _latitudeController = TextEditingController(text: widget.churchProfile.latitude?.toString() ?? '');
    _longitudeController = TextEditingController(text: widget.churchProfile.longitude?.toString() ?? '');
    _serviceScheduleController = TextEditingController(text: widget.churchProfile.serviceSchedule ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _serviceScheduleController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = widget.churchProfile.copyWith(
        name: _nameController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        aboutChurch: _aboutController.text,
        latitude: _latitudeController.text.isEmpty ? null : double.tryParse(_latitudeController.text),
        longitude: _longitudeController.text.isEmpty ? null : double.tryParse(_longitudeController.text),
        serviceSchedule: _serviceScheduleController.text.isEmpty ? null : _serviceScheduleController.text,
        updatedAt: DateTime.now(),
      );
      
      widget.onSave(updatedProfile);
      widget.onClose();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Church profile updated successfully')),
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
            _InfoSection(
              title: 'Basic Information',
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
                    validator: (value) => value?.isEmpty == true ? 'Church name is required' : null,
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
                    validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        label: 'Phone Number',
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
                          validator: (value) => value?.isEmpty == true ? 'Phone number is required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FormField(
                        label: 'Email',
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
                            if (value?.isEmpty == true) return 'Email is required';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
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
                  label: 'About the Church',
                  child: TextFormField(
                    controller: _aboutController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe your church...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => value?.isEmpty == true ? 'About the church is required' : null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Location Information Section
            _InfoSection(
              title: 'Location Information',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        label: 'Latitude (Optional)',
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'e.g., 14.5995',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                              return 'Please enter a valid latitude';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FormField(
                        label: 'Longitude (Optional)',
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'e.g., 120.9842',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                              return 'Please enter a valid longitude';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Service Information Section
            _InfoSection(
              title: 'Service Information',
              children: [
                _FormField(
                  label: 'General Service Schedule (Optional)',
                  child: TextFormField(
                    controller: _serviceScheduleController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'e.g., Sunday Service: 9:00 AM - 11:00 AM\nWednesday Prayer: 7:00 PM - 8:00 PM',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      alignLabelWithHint: true,
                    ),
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

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

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
        const SizedBox(height: 16),
        ...children,
      ],
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

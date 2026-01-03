import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../bloc/coach_profile_bloc.dart';
import '../bloc/coach_profile_event.dart';
import '../bloc/coach_profile_state.dart';

/// Screen: Edit coach profile
/// Allows coaches to update their profile information
class EditCoachProfileScreen extends StatefulWidget {
  const EditCoachProfileScreen({super.key});

  @override
  State<EditCoachProfileScreen> createState() => _EditCoachProfileScreenState();
}

class _EditCoachProfileScreenState extends State<EditCoachProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _clubNameController = TextEditingController();
  final _yearsController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  // Dropdown selections
  String? _selectedRole;
  String? _selectedLicense;

  // Multi-select
  final List<String> _selectedSpecializations = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final state = context.read<CoachProfileBloc>().state;
    if (state is CoachProfileLoaded) {
      final profile = state.profile;
      _clubNameController.text = profile.clubName;
      _yearsController.text = profile.yearsOfExperience.toString();
      _bioController.text = profile.bio ?? '';
      _emailController.text = profile.contactEmail ?? '';
      _phoneController.text = profile.contactPhone ?? '';
      _cityController.text = profile.city ?? '';
      _selectedRole = profile.currentRole;
      _selectedLicense = profile.coachingLicense;
      if (profile.specializations != null) {
        _selectedSpecializations.addAll(profile.specializations!);
      }
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _yearsController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('coach.edit_profile'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: BlocConsumer<CoachProfileBloc, CoachProfileState>(
        listener: (context, state) {
          if (state is CoachProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('success.profile_updated'.tr()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.pop(context);
          } else if (state is CoachProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CoachProfileLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Professional Information
                  _buildSectionHeader('coach.professional_info'.tr()),
                  _buildTextField(
                    controller: _clubNameController,
                    label: 'coach.club_name'.tr(),
                    icon: Icons.sports_soccer,
                  ),
                  _buildRoleDropdown(),
                  _buildLicenseDropdown(),
                  _buildTextField(
                    controller: _yearsController,
                    label: 'coach.years_of_experience'.tr(),
                    icon: Icons.trending_up,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _cityController,
                    label: 'coach.city'.tr(),
                    icon: Icons.location_city,
                  ),

                  const SizedBox(height: 16),
                  _buildSpecializationsSection(),

                  const SizedBox(height: 24),

                  // Bio
                  _buildSectionHeader('coach.about_you'.tr()),
                  _buildBioField(),

                  const SizedBox(height: 24),

                  // Contact Information
                  _buildSectionHeader('coach.contact_info'.tr()),
                  _buildTextField(
                    controller: _emailController,
                    label: 'auth.email'.tr(),
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'auth.phone'.tr(),
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'common.save'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    final roles = [
      'coach.role_head_coach'.tr(),
      'coach.role_assistant_coach'.tr(),
      'coach.role_youth_coach'.tr(),
      'coach.role_goalkeeping_coach'.tr(),
      'coach.role_fitness_coach'.tr(),
      'coach.role_technical_director'.tr(),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: InputDecoration(
          labelText: 'coach.current_role'.tr(),
          prefixIcon: const Icon(Icons.work, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: roles
            .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedRole = value),
      ),
    );
  }

  Widget _buildLicenseDropdown() {
    final licenses = [
      'UEFA Pro',
      'UEFA A',
      'UEFA B',
      'UEFA C',
      'CAF A',
      'CAF B',
      'CAF C',
      'coach.other_license'.tr(),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedLicense,
        decoration: InputDecoration(
          labelText: 'coach.coaching_license'.tr(),
          prefixIcon: const Icon(Icons.card_membership, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: licenses
            .map((license) => DropdownMenuItem(
                  value: license,
                  child: Text(license),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedLicense = value),
      ),
    );
  }

  Widget _buildSpecializationsSection() {
    final specializations = [
      'coach.spec_tactics'.tr(),
      'coach.spec_fitness'.tr(),
      'coach.spec_youth_development'.tr(),
      'coach.spec_goalkeeper_training'.tr(),
      'coach.spec_technical_skills'.tr(),
      'coach.spec_match_analysis'.tr(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'coach.specializations'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specializations.map((spec) {
            final isSelected = _selectedSpecializations.contains(spec);
            return FilterChip(
              label: Text(spec),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecializations.add(spec);
                  } else {
                    _selectedSpecializations.remove(spec);
                  }
                });
              },
              selectedColor: AppColors.primaryBlue,
              checkmarkColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      decoration: InputDecoration(
        labelText: 'coach.bio'.tr(),
        hintText: 'coach.bio_hint'.tr(),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      maxLines: 5,
      maxLength: 500,
    );
  }

  void _saveProfile() {
    final updates = <String, dynamic>{};

    if (_clubNameController.text.isNotEmpty) {
      updates['club_name'] = _clubNameController.text.trim();
    }
    if (_selectedRole != null) {
      updates['current_role'] = _selectedRole;
    }
    if (_selectedLicense != null) {
      updates['coaching_license'] = _selectedLicense;
    }
    if (_yearsController.text.isNotEmpty) {
      updates['years_of_experience'] = int.tryParse(_yearsController.text.trim());
    }
    if (_selectedSpecializations.isNotEmpty) {
      updates['specializations'] = _selectedSpecializations;
    }
    if (_bioController.text.isNotEmpty) {
      updates['bio'] = _bioController.text.trim();
    }
    if (_cityController.text.isNotEmpty) {
      updates['city'] = _cityController.text.trim();
    }
    if (_emailController.text.isNotEmpty) {
      updates['contact_email'] = _emailController.text.trim();
    }
    if (_phoneController.text.isNotEmpty) {
      updates['contact_phone'] = _phoneController.text.trim();
    }

    context.read<CoachProfileBloc>().add(UpdateCoachProfile(updates));
  }
}

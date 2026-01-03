import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../bloc/coach_profile_bloc.dart';
import '../bloc/coach_profile_event.dart';
import '../bloc/coach_profile_state.dart';

/// Screen: Coach profile setup
/// Collects coach information during registration
class CoachProfileSetupScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CoachProfileSetupScreen({
    super.key,
    this.initialData,
  });

  @override
  State<CoachProfileSetupScreen> createState() =>
      _CoachProfileSetupScreenState();
}

class _CoachProfileSetupScreenState extends State<CoachProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _clubNameController = TextEditingController();
  final _yearsController = TextEditingController();
  final _bioController = TextEditingController();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _cityController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _facebookController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Dropdown selections
  String? _selectedCountry;
  String? _selectedRole;
  String? _selectedLicense;

  // Multi-select
  final List<String> _selectedSpecializations = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialData?['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.initialData?['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData?['phone'] ?? '');
    
    if (widget.initialData?['country'] != null) {
      // Check if country exists in list (defined in build method, but we can try to set it)
      // Since the list is local to build, we'll just set it and let the dropdown handle validation or default
      _selectedCountry = widget.initialData!['country'];
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _clubNameController.dispose();
    _yearsController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('coach.setup_profile'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: BlocConsumer<CoachProfileBloc, CoachProfileState>(
        listener: (context, state) {
          if (state is CoachProfileCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('coach.profile_created_success'.tr()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.pushReplacementNamed(context, '/coach/dashboard');
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
                  // Header
                  Text(
                    'coach.complete_your_profile'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'coach.profile_setup_desc'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information
                  _buildSectionHeader('coach.basic_info'.tr()),
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'auth.first_name'.tr(),
                    icon: Icons.person,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'common.required'.tr() : null,
                  ),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'auth.last_name'.tr(),
                    icon: Icons.person,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'common.required'.tr() : null,
                  ),
                  _buildCountryDropdown(),
                  _buildTextField(
                    controller: _cityController,
                    label: 'coach.city'.tr(),
                    icon: Icons.location_city,
                  ),

                  const SizedBox(height: 24),

                  // Professional Information
                  _buildSectionHeader('coach.professional_info'.tr()),
                  _buildTextField(
                    controller: _clubNameController,
                    label: 'coach.club_name'.tr(),
                    icon: Icons.sports_soccer,
                    hint: 'coach.club_name_hint'.tr(),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'common.required'.tr() : null,
                  ),
                  _buildRoleDropdown(),
                  _buildLicenseDropdown(),
                  _buildTextField(
                    controller: _yearsController,
                    label: 'coach.years_of_experience'.tr(),
                    icon: Icons.trending_up,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'common.required'.tr();
                      final years = int.tryParse(value!);
                      if (years == null || years < 0 || years > 50) {
                        return 'coach.invalid_years'.tr();
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildSpecializationsSection(),

                  const SizedBox(height: 24),

                  // About
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
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!_validateEmail(value)) {
                          return 'coach.invalid_email'.tr();
                        }
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'auth.phone'.tr(),
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),

                  // Social Links
                  _buildSectionHeader('coach.social_links'.tr()),
                  _buildSocialLinksSection(),

                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitProfile,
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
                            'coach.create_profile'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
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
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
        validator: validator,
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final countries = [
      'Egypt',
      'Saudi Arabia',
      'UAE',
      'Qatar',
      'Morocco',
      'Tunisia',
      'Algeria',
      'Jordan',
      'Lebanon',
      'Kuwait',
      'Oman',
      'Bahrain',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedCountry,
        decoration: InputDecoration(
          labelText: 'auth.country'.tr(),
          prefixIcon: const Icon(Icons.flag, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: countries
            .map((country) => DropdownMenuItem(
                  value: country,
                  child: Text(country),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedCountry = value),
        validator: (value) =>
            value == null ? 'common.required'.tr() : null,
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
        validator: (value) =>
            value == null ? 'common.required'.tr() : null,
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
        validator: (value) =>
            value == null ? 'common.required'.tr() : null,
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
              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
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

  Widget _buildSocialLinksSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _instagramController,
          label: 'Instagram',
          icon: Icons.camera_alt,
          hint: '@username',
        ),
        _buildTextField(
          controller: _twitterController,
          label: 'X',
          icon: Icons.close,
          hint: '@username',
        ),
        _buildTextField(
          controller: _facebookController,
          label: 'Facebook',
          icon: Icons.facebook,
          hint: 'profile-url',
        ),
        _buildTextField(
          controller: _linkedinController,
          label: 'LinkedIn',
          icon: Icons.work,
          hint: 'profile-url',
        ),
      ],
    );
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _submitProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCountry == null || _selectedRole == null || _selectedLicense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('coach.complete_all_required'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Build social links map
    final socialLinks = <String, String>{};
    if (_instagramController.text.isNotEmpty) {
      socialLinks['instagram'] = _instagramController.text;
    }
    if (_twitterController.text.isNotEmpty) {
      socialLinks['twitter'] = _twitterController.text;
    }
    if (_facebookController.text.isNotEmpty) {
      socialLinks['facebook'] = _facebookController.text;
    }
    if (_linkedinController.text.isNotEmpty) {
      socialLinks['linkedin'] = _linkedinController.text;
    }

    // Dispatch create profile event
    context.read<CoachProfileBloc>().add(
          CreateCoachProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            clubName: _clubNameController.text.trim(),
            currentRole: _selectedRole!,
            coachingLicense: _selectedLicense!,
            yearsOfExperience: int.parse(_yearsController.text.trim()),
            specializations: _selectedSpecializations.isEmpty
                ? null
                : _selectedSpecializations,
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            country: _selectedCountry!,
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            contactEmail: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            contactPhone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            socialLinks: socialLinks.isEmpty ? null : socialLinks,
          ),
        );
  }
}

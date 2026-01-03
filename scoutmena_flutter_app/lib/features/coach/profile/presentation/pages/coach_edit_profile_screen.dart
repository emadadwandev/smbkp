import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../injection.dart';
import '../../../../../core/services/academy_service.dart';
import '../bloc/coach_profile_bloc.dart';
import '../bloc/coach_profile_event.dart';
import '../bloc/coach_profile_state.dart';
import '../../domain/entities/coach_profile_entity.dart';

/// Screen: Coach edit profile
/// Allows coaches to update their profile information
class CoachEditProfileScreen extends StatefulWidget {
  const CoachEditProfileScreen({super.key});

  @override
  State<CoachEditProfileScreen> createState() => _CoachEditProfileScreenState();
}

class _CoachEditProfileScreenState extends State<CoachEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _academyService = getIt<AcademyService>();
  
  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _clubNameController;
  late TextEditingController _yearsController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _facebookController;
  late TextEditingController _linkedinController;

  // Dropdown selections
  String? _selectedCountry;
  String? _selectedRole;
  String? _selectedLicense;
  int? _selectedAcademyId;

  // Data
  List<Map<String, dynamic>> _academies = [];
  bool _isLoadingAcademies = false;

  // Multi-select
  List<String> _selectedSpecializations = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadAcademies();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _clubNameController = TextEditingController();
    _yearsController = TextEditingController();
    _bioController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _facebookController = TextEditingController();
    _linkedinController = TextEditingController();
  }

  void _populateData(CoachProfileEntity profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _clubNameController.text = profile.clubName;
    _yearsController.text = profile.yearsOfExperience.toString();
    _bioController.text = profile.bio ?? '';
    _emailController.text = profile.contactEmail ?? '';
    _phoneController.text = profile.contactPhone ?? '';
    _cityController.text = profile.city ?? '';
    
    _selectedCountry = profile.country;
    _selectedRole = profile.currentRole;
    _selectedLicense = profile.coachingLicense;
    _selectedSpecializations = List.from(profile.specializations ?? []);

    // Social links
    if (profile.socialLinks != null) {
      _instagramController.text = profile.socialLinks!['instagram'] ?? '';
      _twitterController.text = profile.socialLinks!['twitter'] ?? '';
      _facebookController.text = profile.socialLinks!['facebook'] ?? '';
      _linkedinController.text = profile.socialLinks!['linkedin'] ?? '';
    }

    // Academy
    if (profile.academies != null && profile.academies!.isNotEmpty) {
      _selectedAcademyId = profile.academies!.first['id'];
    }
  }

  Future<void> _loadAcademies() async {
    setState(() => _isLoadingAcademies = true);
    try {
      final academies = await _academyService.getAcademies();
      if (mounted) {
        setState(() {
          _academies = academies;
          _isLoadingAcademies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAcademies = false);
        // Fail silently or show toast
      }
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
        title: Text('coach.edit_profile'.tr()),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CoachProfileBloc, CoachProfileState>(
        listener: (context, state) {
          if (state is CoachProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('coach.profile_updated_success'.tr()),
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
          if (state is CoachProfileLoaded) {
            // Only populate once
            if (_firstNameController.text.isEmpty) {
              _populateData(state.profile);
            }
          }

          final isLoading = state is CoachProfileLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  _buildAcademyDropdown(),
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
                      if (years == null || years < 0 || years > 70) {
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
                            'coach.update_profile'.tr(),
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

  Widget _buildAcademyDropdown() {
    if (_isLoadingAcademies) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: _selectedAcademyId,
        decoration: InputDecoration(
          labelText: 'Academy',
          prefixIcon: const Icon(Icons.school, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          helperText: 'Select your academy to join as staff',
        ),
        items: [
          const DropdownMenuItem<int>(
            value: null,
            child: Text('None'),
          ),
          ..._academies.map((academy) => DropdownMenuItem<int>(
                value: academy['id'] as int,
                child: Text(academy['academy_name'] as String),
              )),
        ],
        onChanged: (value) => setState(() => _selectedAcademyId = value),
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
          label: 'Twitter',
          icon: Icons.alternate_email,
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

    // Dispatch update profile event
    context.read<CoachProfileBloc>().add(
          UpdateCoachProfile({
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'club_name': _clubNameController.text.trim(),
            'current_role': _selectedRole!,
            'coaching_license': _selectedLicense!,
            'years_of_experience': int.parse(_yearsController.text.trim()),
            'specializations': _selectedSpecializations.isEmpty
                ? null
                : _selectedSpecializations,
            'bio': _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            'country': _selectedCountry!,
            'city': _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            'contact_email': _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            'contact_phone': _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            'social_links': socialLinks.isEmpty ? null : socialLinks,
            'academy_id': _selectedAcademyId,
          }),
        );
  }
}

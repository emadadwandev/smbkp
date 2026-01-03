import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';

/// Step 1 of 4: Main Profile Info
/// Auto-populated from registration with additional fields
class ProfileStepOneScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onNext;

  const ProfileStepOneScreen({
    super.key,
    required this.initialData,
    required this.onNext,
  });

  @override
  State<ProfileStepOneScreen> createState() => _ProfileStepOneScreenState();
}

class _ProfileStepOneScreenState extends State<ProfileStepOneScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Pre-filled from registration
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late DateTime? _dateOfBirth;
  
  // Additional fields
  late TextEditingController _cityController;
  // late TextEditingController _nationalityController; // Replaced with dropdown
  late TextEditingController _displayNameController;

  String? _selectedNationality;

  final List<Map<String, String>> _countries = [
    {'name': 'Egypt', 'code': 'EG', 'nationality': 'EGY'},
    {'name': 'Saudi Arabia', 'code': 'SA', 'nationality': 'SAU'},
    {'name': 'United Arab Emirates', 'code': 'AE', 'nationality': 'ARE'},
    {'name': 'Qatar', 'code': 'QA', 'nationality': 'QAT'},
    {'name': 'Kuwait', 'code': 'KW', 'nationality': 'KWT'},
    {'name': 'Bahrain', 'code': 'BH', 'nationality': 'BHR'},
    {'name': 'Oman', 'code': 'OM', 'nationality': 'OMN'},
    {'name': 'Jordan', 'code': 'JO', 'nationality': 'JOR'},
    {'name': 'Lebanon', 'code': 'LB', 'nationality': 'LBN'},
    {'name': 'Iraq', 'code': 'IQ', 'nationality': 'IRQ'},
    {'name': 'Morocco', 'code': 'MA', 'nationality': 'MAR'},
    {'name': 'Tunisia', 'code': 'TN', 'nationality': 'TUN'},
    {'name': 'Algeria', 'code': 'DZ', 'nationality': 'DZA'},
    {'name': 'Libya', 'code': 'LY', 'nationality': 'LBY'},
    {'name': 'Palestine', 'code': 'PS', 'nationality': 'PSE'},
    {'name': 'Syria', 'code': 'SY', 'nationality': 'SYR'},
    {'name': 'Yemen', 'code': 'YE', 'nationality': 'YEM'},
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(ProfileStepOneScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      _updateControllers();
    }
  }

  void _initControllers() {
    // Initialize from registration data
    _firstNameController = TextEditingController(
      text: widget.initialData['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.initialData['lastName'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialData['phone'] ?? '',
    );
    _countryController = TextEditingController(
      text: widget.initialData['country'] ?? '',
    );
    _dateOfBirth = widget.initialData['dateOfBirth'];
    
    // Initialize additional fields
    _cityController = TextEditingController(
      text: widget.initialData['city'] ?? '',
    );
    
    // Initialize Nationality
    String? initialNat = widget.initialData['nationality'] ?? widget.initialData['country'];
    if (initialNat != null && initialNat.isNotEmpty) {
      final match = _countries.firstWhere(
        (c) => c['nationality'] == initialNat || c['name'] == initialNat || c['code'] == initialNat,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        _selectedNationality = match['nationality'];
      }
    }

    _displayNameController = TextEditingController(
      text: widget.initialData['displayName'] ?? widget.initialData['firstName'] ?? '',
    );
  }

  void _updateControllers() {
    if (_firstNameController.text.isEmpty) {
      _firstNameController.text = widget.initialData['firstName'] ?? '';
    }
    if (_lastNameController.text.isEmpty) {
      _lastNameController.text = widget.initialData['lastName'] ?? '';
    }
    if (_emailController.text.isEmpty) {
      _emailController.text = widget.initialData['email'] ?? '';
    }
    if (_phoneController.text.isEmpty) {
      _phoneController.text = widget.initialData['phone'] ?? '';
    }
    if (_countryController.text.isEmpty) {
      _countryController.text = widget.initialData['country'] ?? '';
    }
    if (_dateOfBirth == null) {
      _dateOfBirth = widget.initialData['dateOfBirth'];
    }
    if (_selectedNationality == null) {
       String? initialNat = widget.initialData['nationality'] ?? widget.initialData['country'];
       if (initialNat != null && initialNat.isNotEmpty) {
          final match = _countries.firstWhere(
            (c) => c['nationality'] == initialNat || c['name'] == initialNat || c['code'] == initialNat,
            orElse: () => {},
          );
          if (match.isNotEmpty) {
            _selectedNationality = match['nationality'];
          }
       }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    // _nationalityController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      String countryValue = _countryController.text.trim();
      
      // Try to find the country code if the user entered a name
      final countryMatch = _countries.firstWhere(
        (c) => c['name']?.toLowerCase() == countryValue.toLowerCase() || 
               c['code']?.toLowerCase() == countryValue.toLowerCase(),
        orElse: () => {},
      );
      
      if (countryMatch.isNotEmpty) {
        countryValue = countryMatch['code']!;
      }

      final data = {
        ...widget.initialData,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'country': countryValue,
        'dateOfBirth': _dateOfBirth,
        'city': _cityController.text.trim(),
        'nationality': _selectedNationality ?? '',
        'displayName': _displayNameController.text.trim(),
      };
      
      widget.onNext(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.create_profile'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _buildProgressIndicator(1),
              const SizedBox(height: 24),
              
              // Step title
              Text(
                'profile.main_info'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'profile.main_info_subtitle'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Pre-filled fields (editable)
              Text(
                'profile.basic_information'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildReadOnlyField(
                label: 'auth.first_name'.tr(),
                controller: _firstNameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              
              _buildReadOnlyField(
                label: 'auth.last_name'.tr(),
                controller: _lastNameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              _buildReadOnlyField(
                label: 'auth.email'.tr(),
                controller: _emailController,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              
              _buildReadOnlyField(
                label: 'auth.phone_number'.tr(),
                controller: _phoneController,
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
              
              _buildReadOnlyField(
                label: 'auth.country'.tr(),
                controller: _countryController,
                icon: Icons.flag,
              ),
              const SizedBox(height: 16),
              
              if (_dateOfBirth != null)
                _buildReadOnlyField(
                  label: 'auth.date_of_birth'.tr(),
                  value: DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
                  icon: Icons.calendar_today,
                ),
              const SizedBox(height: 32),
              
              // Additional editable fields
              Text(
                'profile.additional_information'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: 'profile.city'.tr(),
                controller: _cityController,
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'errors.field_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedNationality,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'profile.nationality'.tr(),
                  prefixIcon: const Icon(Icons.public, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
                items: _countries.map((c) => DropdownMenuItem(
                  value: c['nationality'],
                  child: Text(
                    c['name']!,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _selectedNationality = v),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'errors.field_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: 'profile.display_name'.tr(),
                controller: _displayNameController,
                icon: Icons.badge,
                hint: 'profile.display_name_hint'.tr(),
                required: false,
              ),
              const SizedBox(height: 32),
              
              // Next button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'common.next'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppColors.primaryBlue
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    TextEditingController? controller,
    String? value,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? value : null,
      enabled: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'errors.field_required'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/scout_profile_bloc.dart';
import '../bloc/scout_profile_event.dart';
import '../bloc/scout_profile_state.dart';
import '../../../../../core/themes/app_colors.dart';

/// Scout profile setup screen
/// Shown after admin approves scout verification
class ScoutProfileSetupScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ScoutProfileSetupScreen({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<ScoutProfileSetupScreen> createState() =>
      _ScoutProfileSetupScreenState();
}

class _ScoutProfileSetupScreenState extends State<ScoutProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _clubNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _bioController = TextEditingController();
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;

  String _selectedCountry = 'Egypt';
  final List<String> _selectedSpecializations = [];
  final List<String> _selectedLeagues = [];
  final List<String> _certificates = [];
  final Map<String, String> _socialLinks = {};
  final List<File> _verificationDocuments = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialData?['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.initialData?['lastName'] ?? '');
    _contactEmailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    _contactPhoneController = TextEditingController(text: widget.initialData?['phone'] ?? '');
    
    if (widget.initialData?['country'] != null && _countries.contains(widget.initialData!['country'])) {
      _selectedCountry = widget.initialData!['country'];
    }
  }

  // Map country names to ISO 2-letter codes
  final Map<String, String> _countryCodeMap = {
    'Egypt': 'EG',
    'Saudi Arabia': 'SA',
    'United Arab Emirates': 'AE',
    'Kuwait': 'KW',
    'Qatar': 'QA',
    'Bahrain': 'BH',
    'Oman': 'OM',
    'Jordan': 'JO',
    'Lebanon': 'LB',
    'Morocco': 'MA',
    'Tunisia': 'TN',
    'Algeria': 'DZ',
  };

  final List<String> _countries = [
    'Egypt',
    'Saudi Arabia',
    'United Arab Emirates',
    'Kuwait',
    'Qatar',
    'Bahrain',
    'Oman',
    'Jordan',
    'Lebanon',
    'Morocco',
    'Tunisia',
    'Algeria',
  ];

  final List<String> _specializationOptions = [
    'Striker Scouts',
    'Defender Specialists',
    'Goalkeeper Scouts',
    'Midfield Specialists',
    'Youth Development',
    'Talent Identification',
    'Performance Analysis',
    'Technical Skills',
  ];

  final List<String> _leagueOptions = [
    'Jordanian Pro League',
    'Jordanian First Division',
    'Jordanian Second Division',
    'Jordanian Third Division',
    'Jordan FA Cup',
    'Jordan FA Shield',
    'Reserve League',
    'Jordan Super Cup',
    'Under-21 League',
    'Under-19 League',
    'Under-17 League',
    'Under-15 League',
    'Egyptian Premier League',
    'Saudi Pro League',
    'UAE Pro League',
    'Qatari Stars League',
    
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _clubNameController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scout.setup_profile'.tr()),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<ScoutProfileBloc, ScoutProfileState>(
        listener: (context, state) {
          if (state is ScoutProfileCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('scout.profile_created_success'.tr()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            // Navigate to scout dashboard
            Navigator.pushReplacementNamed(context, '/scout/dashboard');
          } else if (state is ScoutProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ScoutProfileLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'scout.complete_your_profile'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'scout.profile_setup_desc'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Basic Info Section
                  _buildSectionTitle('scout.basic_info'.tr()),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'profile.first_name'.tr(),
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'profile.last_name'.tr(),
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildCountryDropdown(),
                  const SizedBox(height: 32),

                  // Professional Info Section
                  _buildSectionTitle('scout.professional_info'.tr()),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _clubNameController,
                    label: 'scout.club_name'.tr(),
                    hint: 'scout.club_name_hint'.tr(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _jobTitleController,
                    label: 'Job Title',
                    hint: 'e.g., Senior Scout, Head of Recruitment',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSpecializationsSection(),
                  const SizedBox(height: 16),
                  _buildLeaguesSection(),
                  const SizedBox(height: 16),
                  _buildCertificatesSection(),
                  const SizedBox(height: 32),

                  // Bio Section
                  _buildSectionTitle('scout.about_you'.tr()),
                  const SizedBox(height: 16),
                  _buildBioField(),
                  const SizedBox(height: 32),

                  // Contact Info Section
                  _buildSectionTitle('scout.contact_info'.tr()),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactEmailController,
                    label: 'profile.email'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactPhoneController,
                    label: 'profile.phone'.tr(),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),

                  // Social Links Section (optional)
                  _buildSectionTitle('scout.social_links'.tr() + ' (${tr('common.optional')})'),
                  const SizedBox(height: 16),
                  _buildSocialLinksSection(),
                  const SizedBox(height: 32),

                  // Verification Documents Section
                  _buildSectionTitle('Verification Documents (Optional)'),
                  const SizedBox(height: 8),
                  Text(
                    'Upload documents to verify your scout credentials (e.g., Scout License, Club ID, Business Card)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVerificationDocumentsSection(),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'scout.create_profile'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      validator: validator ?? (required ? (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label ${tr('common.required')}';
        }
        return null;
      } : null),
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountry,
      decoration: InputDecoration(
        labelText: 'profile.country'.tr() + ' *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      items: _countries.map((country) {
        return DropdownMenuItem(
          value: country,
          child: Text(country),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCountry = value!;
        });
      },
    );
  }

  Widget _buildSpecializationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'scout.specializations'.tr(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _specializationOptions.map((spec) {
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
              selectedColor: AppColors.primaryBlue.withOpacity(0.3),
              checkmarkColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLeaguesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'scout.leagues_of_interest'.tr(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _leagueOptions.map((league) {
            final isSelected = _selectedLeagues.contains(league);
            return FilterChip(
              label: Text(league),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLeagues.add(league);
                  } else {
                    _selectedLeagues.remove(league);
                  }
                });
              },
              selectedColor: AppColors.primaryGreen.withOpacity(0.3),
              checkmarkColor: AppColors.primaryGreen,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'scout.certificates'.tr(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            TextButton.icon(
              onPressed: _addCertificate,
              icon: const Icon(Icons.add, size: 18),
              label: Text('common.add'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._certificates.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(entry.value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _certificates.removeAt(entry.key);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      maxLines: 5,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: 'profile.bio'.tr(),
        hintText: 'scout.bio_hint'.tr(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSocialLinksSection() {
    final platforms = ['Instagram', 'X', 'Facebook', 'LinkedIn'];
    return Column(
      children: platforms.map((platform) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: platform,
              prefixIcon: Icon(_getSocialIcon(platform)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              if (value.trim().isNotEmpty) {
                // For X, we can store as 'twitter' for backward compatibility if needed,
                // or 'x' if the backend supports it. Given the player profile screen checks for both,
                // 'x' is likely fine, but let's stick to the platform name lowercased which will be 'x'.
                _socialLinks[platform.toLowerCase()] = value.trim();
              } else {
                _socialLinks.remove(platform.toLowerCase());
              }
            },
          ),
        );
      }).toList(),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform) {
      case 'Instagram':
        return Icons.camera_alt;
      case 'X':
        return Icons.close; // Using close icon as X, or alternate_email if preferred. 
                            // FontAwesome usually has a specific X icon, but with standard Material Icons, 
                            // 'close' or 'cancel' is the closest visual match to the X logo, 
                            // or we can use a text icon. 
                            // Let's use a generic icon or keep chat_bubble_outline but the user asked for X.
                            // Icons.close is an X.
        return Icons.close; 
      case 'Twitter': // Keep for safety if called with old value
        return Icons.chat_bubble_outline;
      case 'Facebook':
        return Icons.facebook;
      case 'LinkedIn':
        return Icons.work_outline;
      default:
        return Icons.link;
    }
  }

  Widget _buildVerificationDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload button
        OutlinedButton.icon(
          onPressed: _pickVerificationDocuments,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Documents'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: BorderSide(color: AppColors.primaryBlue),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        const SizedBox(height: 12),
        
        // Display selected documents
        if (_verificationDocuments.isNotEmpty) ...[
          Text(
            '${_verificationDocuments.length} document(s) selected:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ..._verificationDocuments.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            final fileName = file.path.split('/').last;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(fileName),
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getFileSize(file),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.error,
                    onPressed: () {
                      setState(() {
                        _verificationDocuments.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Future<void> _pickVerificationDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _verificationDocuments.add(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _addCertificate() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('scout.add_certificate'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'scout.certificate_name'.tr(),
            hintText: 'scout.certificate_hint'.tr(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _certificates.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: Text('common.add'.tr()),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value)) {
        return 'profile.invalid_email'.tr();
      }
    }
    return null;
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      // Convert country name to ISO code
      final countryCode = _countryCodeMap[_selectedCountry] ?? 'EG';
      
      context.read<ScoutProfileBloc>().add(
            CreateScoutProfile(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              country: countryCode,
              clubName: _clubNameController.text.trim().isEmpty
                  ? null
                  : _clubNameController.text.trim(),
              jobTitle: _jobTitleController.text.trim().isEmpty
                  ? null
                  : _jobTitleController.text.trim(),
              specializations: _selectedSpecializations.isEmpty
                  ? null
                  : _selectedSpecializations,
              leaguesOfInterest:
                  _selectedLeagues.isEmpty ? null : _selectedLeagues,
              certificates: _certificates.isEmpty ? null : _certificates,
              bio: _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
              contactEmail: _contactEmailController.text.trim().isEmpty
                  ? null
                  : _contactEmailController.text.trim(),
              contactPhone: _contactPhoneController.text.trim().isEmpty
                  ? null
                  : _contactPhoneController.text.trim(),
              socialLinks: _socialLinks.isEmpty ? null : _socialLinks,
            ),
          );
      
      // Upload verification documents if any are selected
      if (_verificationDocuments.isNotEmpty) {
        context.read<ScoutProfileBloc>().add(
          UploadVerificationDocuments(_verificationDocuments),
        );
      }
    }
  }
}

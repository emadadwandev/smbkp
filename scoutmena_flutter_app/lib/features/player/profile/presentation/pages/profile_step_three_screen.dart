import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';

/// Step 3 of 4: Contact Info & Privacy Settings
class ProfileStepThreeScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;

  const ProfileStepThreeScreen({
    super.key,
    required this.initialData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ProfileStepThreeScreen> createState() => _ProfileStepThreeScreenState();
}

class _ProfileStepThreeScreenState extends State<ProfileStepThreeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _emailController;
  Map<String, String> _socialLinks = {};
  String _privacyLevel = 'scouts_only';
  
  final List<String> _socialPlatforms = [
    'instagram',
    'twitter',
    'facebook',
    'tiktok',
    'youtube',
  ];
  
  final List<String> _privacyOptions = [
    'public',
    'scouts_only',
    'private',
  ];

  @override
  void initState() {
    super.initState();
    
    _emailController = TextEditingController(
      text: widget.initialData['email'] ?? '',
    );
    _socialLinks = Map<String, String>.from(widget.initialData['socialLinks'] ?? {});
    _privacyLevel = widget.initialData['privacyLevel'] ?? 'scouts_only';
  }

  @override
  void didUpdateWidget(ProfileStepThreeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      if (_emailController.text.isEmpty) {
        _emailController.text = widget.initialData['email'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      final data = {
        ...widget.initialData,
        'contactEmail': _emailController.text.trim(),
        'socialLinks': _socialLinks,
        'privacyLevel': _privacyLevel,
      };
      
      widget.onNext(data);
    }
  }

  void _addSocialLink(String platform, String username) {
    if (username.trim().isNotEmpty) {
      setState(() {
        _socialLinks[platform] = username.trim();
      });
    }
  }

  void _removeSocialLink(String platform) {
    setState(() {
      _socialLinks.remove(platform);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.create_profile'.tr()),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(3),
              const SizedBox(height: 24),
              
              Text(
                'profile.contact_privacy'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'profile.contact_privacy_subtitle'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Contact Information
              _buildSectionTitle('profile.contact_info'.tr()),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                enabled: true,
                decoration: InputDecoration(
                  labelText: 'auth.email'.tr(),
                  prefixIcon: Icon(Icons.email, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'errors.field_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'profile.email_verified'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Social Links
              _buildSectionTitle('profile.social_links'.tr()),
              const SizedBox(height: 8),
              Text(
                'profile.social_links_hint'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSocialLinksList(),
              const SizedBox(height: 32),
              
              // Privacy Settings
              _buildSectionTitle('profile.privacy_settings'.tr()),
              const SizedBox(height: 16),
              
              _buildPrivacySelector(),
              const SizedBox(height: 32),
              
              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'common.previous'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSocialLinksList() {
    return Column(
      children: [
        ..._socialPlatforms.map((platform) {
          final hasLink = _socialLinks.containsKey(platform);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(_getSocialIcon(platform)),
              title: Text(platform == 'twitter' ? 'X' : 'profile.social_$platform'.tr()),
              subtitle: hasLink
                  ? Text(_socialLinks[platform]!)
                  : Text('profile.add_username'.tr()),
              trailing: hasLink
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSocialLink(platform),
                    )
                  : IconButton(
                      icon: Icon(Icons.add, color: AppColors.primaryBlue),
                      onPressed: () => _showAddSocialLinkDialog(platform),
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPrivacySelector() {
    return Column(
      children: _privacyOptions.map((option) {
        final isSelected = _privacyLevel == option;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : null,
          child: ListTile(
            leading: Icon(
              _getPrivacyIcon(option),
              color: isSelected ? AppColors.primaryBlue : Colors.grey,
            ),
            title: Text(
              'privacy.$option'.tr(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryBlue : Colors.black,
              ),
            ),
            subtitle: Text('privacy.${option}_desc'.tr()),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: AppColors.primaryBlue)
                : null,
            onTap: () => setState(() => _privacyLevel = option),
          ),
        );
      }).toList(),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform) {
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.close;
      case 'facebook':
        return Icons.facebook;
      case 'tiktok':
        return Icons.play_circle_outline;
      case 'youtube':
        return Icons.video_library;
      default:
        return Icons.link;
    }
  }

  IconData _getPrivacyIcon(String privacy) {
    switch (privacy) {
      case 'public':
        return Icons.public;
      case 'scouts_only':
        return Icons.verified_user;
      case 'private':
        return Icons.lock;
      default:
        return Icons.help;
    }
  }

  Future<void> _showAddSocialLinkDialog(String platform) async {
    final controller = TextEditingController(
      text: _socialLinks[platform] ?? '',
    );
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('profile.add_social_link'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSocialIcon(platform), color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  platform == 'twitter' ? 'X' : 'profile.social_$platform'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'profile.username_or_url'.tr(),
                prefixText: '@',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              _addSocialLink(platform, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: Text('common.add'.tr()),
          ),
        ],
      ),
    );
  }
}

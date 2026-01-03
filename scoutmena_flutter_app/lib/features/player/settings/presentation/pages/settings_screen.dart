import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/scoutmena_logo.dart';

/// Settings Screen - Account, preferences, notifications, support, and logout
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _profileViewAlerts = true;
  bool _contactRequestAlerts = true;
  bool _videoUploadStatus = true;
  
  String _selectedLanguage = 'en';
  String _selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _profileViewAlerts = prefs.getBool('profile_view_alerts') ?? true;
      _contactRequestAlerts = prefs.getBool('contact_request_alerts') ?? true;
      _videoUploadStatus = prefs.getBool('video_upload_status') ?? true;
      _selectedLanguage = context.locale.languageCode;
      _selectedTheme = prefs.getString('app_theme') ?? 'system';
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme);
    setState(() {
      _selectedTheme = theme;
    });
    // Theme change requires app restart to take full effect
    // In production, implement ThemeBloc to update theme dynamically
  }

  Future<void> _changeLanguage(String languageCode) async {
    await context.setLocale(Locale(languageCode));
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.logout_confirmation'.tr()),
        content: Text('settings.logout_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('settings.logout'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Call backend logout endpoint
      // final response = await dio.post('/api/v1/auth/logout');
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Navigate to login screen
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.logout_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.settings'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView(
        children: [
          _buildAccountSection(),
          const Divider(height: 1),
          _buildPreferencesSection(),
          const Divider(height: 1),
          _buildSupportSection(),
          const Divider(height: 1),
          _buildLogoutSection(),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'settings.account'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person_outline, color: AppColors.primaryBlue),
          title: Text('settings.profile_settings'.tr()),
          subtitle: Text('settings.profile_settings_desc'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to player dashboard profile tab
            Navigator.pop(context); // Return to dashboard
          },
        ),
        ListTile(
          leading: Icon(Icons.lock_outline, color: AppColors.primaryBlue),
          title: Text('settings.privacy_settings'.tr()),
          subtitle: Text('settings.privacy_settings_desc'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Privacy settings screen coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'settings.preferences'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        
        // Notifications section
        ExpansionTile(
          leading: Icon(Icons.notifications_outlined, color: AppColors.primaryBlue),
          title: Text('settings.notifications'.tr()),
          children: [
            SwitchListTile(
              title: Text('settings.push_notifications'.tr()),
              subtitle: Text('settings.push_notifications_desc'.tr()),
              value: _pushNotifications,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _savePreference('push_notifications', value);
              },
            ),
            SwitchListTile(
              title: Text('settings.email_notifications'.tr()),
              subtitle: Text('settings.email_notifications_desc'.tr()),
              value: _emailNotifications,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _savePreference('email_notifications', value);
              },
            ),
            SwitchListTile(
              title: Text('settings.profile_view_alerts'.tr()),
              value: _profileViewAlerts,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                setState(() => _profileViewAlerts = value);
                _savePreference('profile_view_alerts', value);
              },
            ),
            SwitchListTile(
              title: Text('settings.contact_request_alerts'.tr()),
              value: _contactRequestAlerts,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                setState(() => _contactRequestAlerts = value);
                _savePreference('contact_request_alerts', value);
              },
            ),
            SwitchListTile(
              title: Text('settings.video_upload_status'.tr()),
              value: _videoUploadStatus,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                setState(() => _videoUploadStatus = value);
                _savePreference('video_upload_status', value);
              },
            ),
          ],
        ),
        
        // Language section
        ListTile(
          leading: Icon(Icons.language, color: AppColors.primaryBlue),
          title: Text('settings.language'.tr()),
          subtitle: Text(_selectedLanguage == 'en' ? 'English' : 'العربية'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(),
        ),
        
        // Theme section
        ListTile(
          leading: Icon(Icons.palette_outlined, color: AppColors.primaryBlue),
          title: Text('settings.theme'.tr()),
          subtitle: Text('settings.theme_${_selectedTheme}'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showThemeDialog(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'settings.support'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.help_outline, color: AppColors.primaryBlue),
          title: Text('settings.help_support'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Help & Support screen coming soon')),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.description_outlined, color: AppColors.primaryBlue),
          title: Text('settings.terms_conditions'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Terms & Conditions will open in web view')),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.privacy_tip_outlined, color: AppColors.primaryBlue),
          title: Text('settings.privacy_policy'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Privacy Policy will open in web view')),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: AppColors.primaryBlue),
          title: Text('settings.about'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showAboutDialog(),
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: Text(
          'settings.logout'.tr(),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: _showLogoutConfirmation,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.select_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  _changeLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _selectedLanguage,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  _changeLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.select_theme'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('settings.theme_light'.tr()),
              value: 'light',
              groupValue: _selectedTheme,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  _saveTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text('settings.theme_dark'.tr()),
              value: 'dark',
              groupValue: _selectedTheme,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  _saveTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text('settings.theme_system'.tr()),
              value: 'system',
              groupValue: _selectedTheme,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  _saveTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.about_scoutmena'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: ScoutMenaAppIcon(
                size: 80,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'ScoutMena',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'settings.version'.tr(args: ['1.0.0']),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'settings.about_description'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '© 2025 ScoutMena',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }
}

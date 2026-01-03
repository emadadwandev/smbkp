import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/themes/theme_cubit.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/scoutmena_logo.dart';
import '../../../../core/services/support_service.dart';
import '../../../../injection.dart';
import 'contact_us_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool embed;
  const SettingsScreen({super.key, this.embed = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supportService = getIt<SupportService>();
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      // Keep default version
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      children: [
        // Preferences Section
        _buildSectionHeader(context, 'settings.preferences'.tr()),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDark = themeMode == ThemeMode.dark;
            return ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primaryBlue,
              ),
              title: Text('settings.theme'.tr()),
              subtitle: Text(
                isDark
                    ? 'settings.theme_dark'.tr()
                    : 'settings.theme_light'.tr(),
              ),
              trailing: Switch(
                value: isDark,
                activeColor: AppColors.primaryBlue,
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.language, color: AppColors.primaryBlue),
          title: Text('settings.language'.tr()),
          subtitle: Text(
            context.locale.languageCode == 'ar' ? 'العربية' : 'English',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(),
        ),
        ListTile(
          leading: Icon(
            Icons.notifications_outlined,
            color: AppColors.primaryBlue,
          ),
          title: Text('settings.notifications'.tr()),
          subtitle: Text('settings.notification_preferences'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('settings.coming_soon'.tr())),
            );
          },
        ),

        const Divider(height: 32),

        // Support Section
        _buildSectionHeader(context, 'settings.support'.tr()),
        ListTile(
          leading: Icon(Icons.help_outline, color: AppColors.primaryBlue),
          title: Text('settings.help_support'.tr()),
          subtitle: Text('settings.help_support_desc'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.contact_mail_outlined,
            color: AppColors.primaryBlue,
          ),
          title: Text('settings.contact_us'.tr()),
          subtitle: Text('settings.contact_us_desc'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.feedback_outlined, color: AppColors.primaryBlue),
          title: Text('settings.send_feedback'.tr()),
          subtitle: Text('settings.send_feedback_desc'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactUsScreen(isFeedback: true),
              ),
            );
          },
        ),

        const Divider(height: 32),

        // Legal Section
        _buildSectionHeader(context, 'settings.legal'.tr()),
        ListTile(
          leading: Icon(
            Icons.description_outlined,
            color: AppColors.primaryBlue,
          ),
          title: Text('settings.terms_conditions'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _openUrl('https://scoutmena.com/page/terms'),
        ),
        ListTile(
          leading: Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.primaryBlue,
          ),
          title: Text('settings.privacy_policy'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _openUrl('https://scoutmena.com/page/privacy'),
        ),

        const Divider(height: 32),

        // Data & Privacy Section
        _buildSectionHeader(context, 'settings.data_privacy'.tr()),
        ListTile(
          leading: Icon(Icons.download_outlined, color: AppColors.primaryBlue),
          title: Text('settings.request_my_data'.tr()),
          subtitle: Text('settings.request_my_data_desc'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showDataRequestDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
          title: Text(
            'settings.delete_account'.tr(),
            style: const TextStyle(color: Colors.red),
          ),
          subtitle: Text('settings.delete_account_desc'.tr()),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.red,
          ),
          onTap: () => _showDeleteAccountDialog(),
        ),

        const Divider(height: 32),

        // About Section
        _buildSectionHeader(context, 'settings.about'.tr()),
        ListTile(
          leading: Icon(Icons.info_outline, color: AppColors.primaryBlue),
          title: Text('settings.about_scoutmena'.tr()),
          subtitle: Text('settings.version'.tr(args: [_appVersion])),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showAboutDialog(),
        ),

        const SizedBox(height: 24),
      ],
    );

    if (widget.embed) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('common.settings'.tr()),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: content,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final currentLanguage = context.locale.languageCode;
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
              groupValue: currentLanguage,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  context.setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: currentLanguage,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  context.setLocale(Locale(value));
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: ScoutMenaAppIcon(size: 80)),
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
                  'settings.version'.tr(args: [_appVersion]),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
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

  void _showDataRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_outlined, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(child: Text('settings.request_my_data'.tr())),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'settings.data_request_message'.tr(),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'settings.data_request_info'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitDataRequest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: Text(
              'settings.submit_request'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text('settings.delete_account'.tr())),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'settings.delete_account_warning'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'settings.delete_account_details'.tr(),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'settings.reason_optional'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'settings.reason_hint'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'settings.delete_request_info'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(context);
              await _submitDeleteAccountRequest(reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'settings.submit_request'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDataRequest() async {
    try {
      final response = await _supportService.requestUserData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.data_request_submitted'.tr()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.request_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitDeleteAccountRequest(String reason) async {
    try {
      final response = await _supportService.requestAccountDeletion(
        reason: reason.isNotEmpty ? reason : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.delete_request_submitted'.tr()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.request_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('settings.cannot_open_url'.tr())),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('settings.url_error'.tr())));
      }
    }
  }
}

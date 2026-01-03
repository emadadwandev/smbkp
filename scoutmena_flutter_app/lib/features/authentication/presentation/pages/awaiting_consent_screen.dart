import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../injection.dart';

class AwaitingConsentScreen extends StatelessWidget {
  final String parentEmail;

  const AwaitingConsentScreen({
    Key? key,
    required this.parentEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('auth.awaiting_approval'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clock icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule,
                  size: 60,
                  color: Colors.orange.shade900,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'auth.awaiting_parental_approval'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'auth.consent_email_sent'.tr(args: [parentEmail]),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // What happens next card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'auth.what_happens_next'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      Icons.email,
                      'auth.email_sent_to_parent'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildStep(
                      Icons.check_circle_outline,
                      'auth.parent_reviews_approves'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildStep(
                      Icons.verified,
                      'auth.account_activated'.tr(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Resend Email button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Resend parental consent email via backend API
                    // POST /api/v1/parent/consent/{token}/resend
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('auth.email_resent'.tr()),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'auth.resend_email'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout button
              TextButton(
                onPressed: () async {
                  try {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Call logout service
                    await getIt<AuthService>().logout();

                    if (context.mounted) {
                      // Close loading dialog
                      Navigator.of(context).pop();
                      
                      // Navigate to main auth screen
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      // Close loading dialog
                      Navigator.of(context).pop();
                      
                      // Show error but still navigate to login
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logout failed: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      
                      // Navigate anyway
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                      );
                    }
                  }
                },
                child: Text(
                  'settings.logout'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}



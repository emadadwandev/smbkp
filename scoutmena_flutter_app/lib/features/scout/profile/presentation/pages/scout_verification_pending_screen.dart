import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/scout_profile_bloc.dart';
import '../bloc/scout_profile_event.dart';
import '../bloc/scout_profile_state.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../injection.dart';

/// Verification pending screen
/// Shown after scout uploads documents and waits for admin approval
class ScoutVerificationPendingScreen extends StatelessWidget {
  const ScoutVerificationPendingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scout.verification_status'.tr()),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<ScoutProfileBloc, ScoutProfileState>(
        listener: (context, state) {
          if (state is ScoutProfileVerified) {
            // Account verified! Navigate to profile setup
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('scout.account_verified'.tr()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.pushReplacementNamed(
              context,
              '/scout/profile-setup',
            );
          } else if (state is ScoutProfileVerificationRejected) {
            // Show rejection dialog
            _showRejectionDialog(context, state.reason);
          }
        },
        builder: (context, state) {
          if (state is ScoutProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildPendingView(context, state);
        },
      ),
    );
  }

  Widget _buildPendingView(BuildContext context, ScoutProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Clock icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule,
              size: 64,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'scout.awaiting_verification'.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Message
          Text(
            'scout.verification_pending_message'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Timeline card
          _buildTimelineCard(),
          const SizedBox(height: 24),

          // Status info card
          if (state is ScoutProfilePendingVerification)
            _buildStatusCard(state.profile.verificationDocumentUrls?.length ?? 0),
          const SizedBox(height: 32),

          // Refresh button
          OutlinedButton.icon(
            onPressed: () {
              context.read<ScoutProfileBloc>().add(const RefreshScoutProfile());
            },
            icon: const Icon(Icons.refresh),
            label: Text('scout.check_status'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                    (route) => false,
                  );
                }
              }
            },
            child: Text(
              'common.logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'scout.what_happens_next'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimelineStep(
              icon: Icons.check_circle,
              title: 'scout.documents_submitted'.tr(),
              isCompleted: true,
            ),
            _buildTimelineStep(
              icon: Icons.schedule,
              title: 'scout.under_review'.tr(),
              isCompleted: false,
            ),
            _buildTimelineStep(
              icon: Icons.verified_user,
              title: 'scout.account_activation'.tr(),
              isCompleted: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              icon,
              color: isCompleted ? AppColors.primaryGreen : Colors.grey.shade400,
              size: 24,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
                color: isCompleted ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(int documentsCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'scout.submission_details'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'scout.documents_uploaded'.tr(),
            '$documentsCount',
          ),
          _buildDetailRow(
            'scout.status'.tr(),
            'scout.pending'.tr(),
          ),
          _buildDetailRow(
            'scout.estimated_time'.tr(),
            '24-48 ' + 'common.hours'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            const SizedBox(width: 8),
            Text('scout.verification_rejected'.tr()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('scout.rejection_message'.tr()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reason,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to document upload
              Navigator.pushReplacementNamed(
                context,
                '/scout/document-upload',
              );
            },
            child: Text('scout.resubmit_documents'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text(
              'common.logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

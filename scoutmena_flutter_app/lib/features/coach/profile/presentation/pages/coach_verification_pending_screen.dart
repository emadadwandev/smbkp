import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../bloc/coach_profile_bloc.dart';
import '../bloc/coach_profile_event.dart';
import '../bloc/coach_profile_state.dart';

/// Screen: Coach verification pending
/// Shows verification status while admin reviews documents
class CoachVerificationPendingScreen extends StatelessWidget {
  const CoachVerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('coach.verification_status'.tr()),
        backgroundColor: AppColors.primaryBlue,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<CoachProfileBloc, CoachProfileState>(
        listener: (context, state) {
          if (state is CoachProfileVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('coach.account_verified'.tr()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.pushReplacementNamed(context, '/coach/profile-setup');
          } else if (state is CoachVerificationRejected) {
            _showRejectionDialog(context, state.reason);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 60,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'coach.awaiting_verification'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'coach.verification_pending_message'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Timeline Card
                _buildTimelineCard(context),
                const SizedBox(height: 24),

                // Status Card
                _buildStatusCard(context, state),
                const SizedBox(height: 24),

                // Refresh Button
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<CoachProfileBloc>().add(
                          const RefreshCoachProfile(),
                        );
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('coach.check_status'.tr()),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    foregroundColor: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),

                // Logout Button
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    'common.logout'.tr(),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'coach.what_happens_next'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineStep(
              icon: Icons.check_circle,
              title: 'coach.documents_submitted'.tr(),
              isCompleted: true,
              isLast: false,
            ),
            _buildTimelineStep(
              icon: Icons.schedule,
              title: 'coach.under_review'.tr(),
              isCompleted: false,
              isLast: false,
            ),
            _buildTimelineStep(
              icon: Icons.verified_user,
              title: 'coach.account_activation'.tr(),
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
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              icon,
              color: isCompleted ? AppColors.primaryGreen : Colors.grey,
              size: 24,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isCompleted ? Colors.black87 : Colors.grey[600],
                fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, CoachProfileState state) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'coach.submission_details'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'coach.status'.tr(),
              'coach.pending'.tr(),
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'coach.estimated_time'.tr(),
              '24-48 ${'common.hours'.tr()}',
              AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showRejectionDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('coach.verification_rejected'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('coach.rejection_message'.tr()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reason,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('common.logout'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/coach/document-upload');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: Text(
              'coach.resubmit_documents'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

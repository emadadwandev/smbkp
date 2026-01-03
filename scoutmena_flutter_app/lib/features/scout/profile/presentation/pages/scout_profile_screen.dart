import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../bloc/scout_profile_bloc.dart';
import '../bloc/scout_profile_state.dart';
import '../../domain/entities/scout_profile_entity.dart';
import 'scout_profile_edit_screen.dart';

class ScoutProfileScreen extends StatelessWidget {
  const ScoutProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoutProfileBloc, ScoutProfileState>(
      builder: (context, state) {
        if (state is ScoutProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ScoutProfileLoaded) {
          return _buildProfileView(context, state.profile);
        } else if (state is ScoutProfileVerified) {
          return _buildProfileView(context, state.profile);
        } else if (state is ScoutProfileUpdated) {
          return _buildProfileView(context, state.profile);
        } else if (state is ScoutProfileCreated) {
          return _buildProfileView(context, state.profile);
        } else if (state is ScoutProfilePendingVerification) {
          return _buildProfileView(context, state.profile, isPending: true);
        } else if (state is ScoutProfileError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildProfileView(BuildContext context, ScoutProfileEntity profile, {bool isPending = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryBlue,
                      backgroundImage: profile.profilePhotoUrl != null
                          ? NetworkImage(profile.profilePhotoUrl!)
                          : null,
                      child: profile.profilePhotoUrl == null
                          ? Text(
                              profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'S',
                              style: const TextStyle(fontSize: 40, color: Colors.white),
                            )
                          : null,
                    ),
                    if (profile.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.jobTitle ?? 'Scout',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (profile.clubName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.clubName!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'Verification Pending',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // About Section
          _buildSectionTitle('About'),
          const SizedBox(height: 8),
          Text(
            profile.bio ?? 'No bio available.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Details Section
          _buildSectionTitle('Details'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.location_on_outlined, 'Location', profile.country),
          if (profile.contactEmail != null)
            _buildDetailRow(Icons.email_outlined, 'Email', profile.contactEmail!),
          if (profile.contactPhone != null)
            _buildDetailRow(Icons.phone_outlined, 'Phone', profile.contactPhone!),
          
          const SizedBox(height: 24),

          // Specializations
          if (profile.specializations != null && profile.specializations!.isNotEmpty) ...[
            _buildSectionTitle('Specializations'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.specializations!.map((spec) => Chip(
                label: Text(spec),
                backgroundColor: AppColors.cardBackground,
                labelStyle: const TextStyle(color: AppColors.textPrimary),
                side: BorderSide(color: Colors.grey[800]!),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Leagues of Interest
          if (profile.leaguesOfInterest != null && profile.leaguesOfInterest!.isNotEmpty) ...[
            _buildSectionTitle('Leagues of Interest'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.leaguesOfInterest!.map((league) => Chip(
                label: Text(league),
                backgroundColor: AppColors.cardBackground,
                labelStyle: const TextStyle(color: AppColors.textPrimary),
                side: BorderSide(color: Colors.grey[800]!),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Actions
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final bloc = context.read<ScoutProfileBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: bloc,
                      child: ScoutProfileEditScreen(profile: profile),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

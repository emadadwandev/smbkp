import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../app/routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/player_service.dart';
import '../../../../../injection.dart';
import '../../../profile/presentation/bloc/player_profile_bloc.dart';
import '../../../profile/presentation/pages/edit_profile_screen.dart';
import '../../../profile/presentation/pages/edit_attributes_screen.dart';
import '../../../profile/presentation/pages/edit_career_screen.dart';
import '../../../profile/presentation/widgets/career_timeline_widget.dart';
import '../../../media/presentation/pages/upload_photos_screen.dart';
import '../../../media/presentation/pages/upload_videos_screen.dart';
import '../../../stats/presentation/pages/update_stats_screen.dart';
import '../../../profile/presentation/bloc/player_profile_event.dart';
import '../../../profile/presentation/bloc/player_profile_state.dart';
import '../../../../settings/presentation/pages/settings_screen.dart';
import '../../../profile/presentation/pages/match_reports_screen.dart';
import '../../../../scout/dashboard/presentation/pages/player_profile_screen.dart';

/// Player Dashboard - Home screen with stats, contact requests, and quick actions
class PlayerDashboardScreen extends StatefulWidget {
  const PlayerDashboardScreen({super.key});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _playerService = getIt<PlayerService>();
  List<ContactRequest> _recentRequests = [];
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Load player profile on first build
      context.read<PlayerProfileBloc>().add(const LoadPlayerProfile());
      _loadRecentRequests();
      _isInitialized = true;
    }
  }

  Future<void> _loadRecentRequests() async {
    try {
      final requests = await _playerService.getContactRequests();
      if (mounted) {
        setState(() {
          _recentRequests = requests;
        });
      }
    } catch (e) {
      debugPrint('Error loading contact requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerProfileBloc, PlayerProfileState>(
      listener: (context, state) {
        if (state is PlayerProfileError) {
          // Check for profile not found error and redirect to creation
          if (state.message.contains('Profile not found') || 
              state.message.contains('create your profile first')) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.playerProfileSetup);
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        appBar: AppBar(
          title: Text('dashboard.home'.tr()),
          backgroundColor: AppColors.primaryBlue,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildMessagesTab();
      case 2:
        return _buildProfileTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
      builder: (context, state) {
        if (state is PlayerProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlayerProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PlayerProfileBloc>().add(const LoadPlayerProfile());
                  },
                  child: Text('common.retry'.tr()),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<PlayerProfileBloc>().add(const LoadPlayerProfile());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildContactRequestsWidget(),
                const SizedBox(height: 24),
                _buildTeamFeatureWidget(),
                const SizedBox(height: 24),
                _buildProfileUpdatesWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
      builder: (context, state) {
        String userName = 'Player';
        String? photoUrl;

        if (state is PlayerProfileLoaded) {
          userName = state.profile.fullName;
          photoUrl = state.profile.profilePhotoUrl;
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dashboard.welcome_back'.tr(),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
      builder: (context, state) {
        String profileViews = '-';
        String videoViews = '-';
        String contactRequests = '-';
        String completion = '0%';

        if (state is PlayerProfileLoaded) {
          completion = '${state.profile.calculateCompletionPercentage()}%';
          
          if (state.analytics != null) {
            profileViews = state.analytics!['total_views']?.toString() ?? '0';
            // videoViews and contactRequests would come from analytics or other services
            // For now we use placeholders or 0 if not available
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dashboard.your_stats'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  icon: Icons.visibility,
                  label: 'dashboard.profile_views'.tr(),
                  value: profileViews,
                  color: AppColors.primaryBlue,
                ),
                _buildStatCard(
                  icon: Icons.play_circle_outline,
                  label: 'dashboard.video_views'.tr(),
                  value: videoViews,
                  color: AppColors.primaryGreen,
                ),
                _buildStatCard(
                  icon: Icons.mail_outline,
                  label: 'dashboard.contact_requests'.tr(),
                  value: contactRequests,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'dashboard.profile_completion'.tr(),
                  value: completion,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRequestsWidget() {
    final displayRequests = _recentRequests.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'dashboard.recent_requests'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.contactRequests);
              },
              child: Text('dashboard.view_all'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (displayRequests.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Icon(Icons.mail_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'dashboard.no_requests'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: displayRequests.map((request) => _buildRequestItem(request)).toList(),
          ),
      ],
    );
  }

  Widget _buildRequestItem(ContactRequest request) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: Text(
            request.senderName.isNotEmpty ? request.senderName[0].toUpperCase() : '?',
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ),
        title: Text(
          request.senderName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          request.senderRole ?? 'Scout',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(request.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            request.status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(request.status),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
           Navigator.pushNamed(context, AppRoutes.contactRequests);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.primaryGreen;
      case 'declined':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildTeamFeatureWidget() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.groups, size: 32, color: Colors.grey[500]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboard.team_feature'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'dashboard.team_feature_message'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileUpdatesWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard.profile_updates'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
              builder: (context, state) {
                int completionPercentage = 0;
                if (state is PlayerProfileLoaded) {
                  completionPercentage = state.profile.calculateCompletionPercentage();
                }

                return Column(
                  children: [
                    // Profile completion progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'dashboard.profile_completion'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$completionPercentage%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: completionPercentage / 100,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 20),
                    // Quick actions
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.edit,
                          label: 'dashboard.edit_info'.tr(),
                          onTap: () async {
                            final bloc = context.read<PlayerProfileBloc>();
                            final currentState = bloc.state;
                            if (currentState is PlayerProfileLoaded) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: bloc,
                                    child: EditProfileScreen(profile: currentState.profile),
                                  ),
                                ),
                              );
                              bloc.add(const LoadPlayerProfile());
                            }
                          },
                        ),
                        _buildQuickActionButton(
                          icon: Icons.photo_library,
                          label: 'dashboard.upload_photos'.tr(),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadPhotosScreen(),
                              ),
                            );
                            context.read<PlayerProfileBloc>().add(const LoadPlayerProfile());
                          },
                        ),
                        _buildQuickActionButton(
                          icon: Icons.video_library,
                          label: 'dashboard.upload_videos'.tr(),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadVideosScreen(),
                              ),
                            );
                            context.read<PlayerProfileBloc>().add(const LoadPlayerProfile());
                          },
                        ),
                        _buildQuickActionButton(
                          icon: Icons.sports_soccer,
                          label: 'dashboard.update_stats'.tr(),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpdateStatsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          icon: Icons.analytics,
                          label: 'dashboard.match_reports'.tr(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MatchReportsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          icon: Icons.tune,
                          label: 'dashboard.edit_attributes'.tr(),
                          onTap: () async {
                            final bloc = context.read<PlayerProfileBloc>();
                            final currentState = bloc.state;
                            if (currentState is PlayerProfileLoaded) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: bloc,
                                    child: EditAttributesScreen(profile: currentState.profile),
                                  ),
                                ),
                              );
                              bloc.add(const LoadPlayerProfile());
                            }
                          },
                        ),
                        _buildQuickActionButton(
                          icon: Icons.timeline,
                          label: 'dashboard.career_timeline'.tr(),
                          onTap: () async {
                            final bloc = context.read<PlayerProfileBloc>();
                            final currentState = bloc.state;
                            if (currentState is PlayerProfileLoaded) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text('dashboard.career_timeline'.tr()),
                                      backgroundColor: AppColors.primaryBlue,
                                    ),
                                    body: CareerTimelineWidget(
                                      careerHistory: currentState.profile.careerHistory ?? [],
                                    ),
                                  ),
                                ),
                              );
                              bloc.add(const LoadPlayerProfile());
                            }
                          },
                        ),
                        _buildQuickActionButton(
                          icon: Icons.work_outline,
                          label: 'dashboard.edit_career'.tr(),
                          onTap: () async {
                            final bloc = context.read<PlayerProfileBloc>();
                            final currentState = bloc.state;
                            if (currentState is PlayerProfileLoaded) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: bloc,
                                    child: EditCareerScreen(profile: currentState.profile),
                                  ),
                                ),
                              );
                              bloc.add(const LoadPlayerProfile());
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'dashboard.messages_coming_soon'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
      builder: (context, state) {
        if (state is PlayerProfileLoaded) {
          final profile = state.profile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryBlue,
                        backgroundImage: profile.profilePhotoUrl != null
                            ? NetworkImage(profile.profilePhotoUrl!)
                            : null,
                        child: profile.profilePhotoUrl == null
                            ? Text(
                                profile.firstName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'positions.${profile.primaryPosition}'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Personal Information
                _buildSectionHeader('profile.personal_info'.tr()),
                _buildInfoRow('profile.nationality'.tr(), profile.nationality ?? '-'),
                _buildInfoRow('profile.city'.tr(), profile.city ?? '-'),
                _buildInfoRow('profile.country'.tr(), profile.country),
                _buildInfoRow('profile.gender'.tr(), profile.gender != null ? 'profile.gender_${profile.gender}'.tr() : '-'),
                _buildInfoRow('profile.bio'.tr(), profile.bio ?? '-'),
                const SizedBox(height: 24),

                // Physical Data
                _buildSectionHeader('profile.physical_data'.tr()),
                _buildInfoRow('profile.height'.tr(), '${profile.heightCm ?? '-'} cm'),
                _buildInfoRow('profile.weight'.tr(), '${profile.weightKg ?? '-'} kg'),
                _buildInfoRow('profile.preferred_foot'.tr(), profile.preferredFoot ?? '-'),
                if (profile.physicalData != null)
                  ...profile.physicalData!.entries.map((e) => _buildInfoRow('attributes.${e.key}'.tr(), e.value.toString())),
                const SizedBox(height: 24),

                // Technical Data
                if (profile.technicalData != null && profile.technicalData!.isNotEmpty) ...[
                  _buildSectionHeader('profile.technical_data'.tr()),
                  ...profile.technicalData!.entries.map((e) => _buildInfoRow('attributes.${e.key}'.tr(), e.value.toString())),
                  const SizedBox(height: 24),
                ],

                // Tactical Data
                if (profile.tacticalData != null && profile.tacticalData!.isNotEmpty) ...[
                  _buildSectionHeader('profile.tactical_data'.tr()),
                  ...profile.tacticalData!.entries.map((e) => _buildInfoRow('attributes.${e.key}'.tr(), e.value.toString())),
                  const SizedBox(height: 24),
                ],

                // Training Progress
                if (profile.trainingData != null && profile.trainingData!.isNotEmpty) ...[
                  _buildSectionHeader('profile.training_progress'.tr()),
                  ...profile.trainingData!.entries.map((e) => _buildInfoRow(e.key, e.value.toString())),
                  const SizedBox(height: 24),
                ],

                // Career History
                if (profile.careerHistory != null && profile.careerHistory!.isNotEmpty) ...[
                  _buildSectionHeader('dashboard.career_timeline'.tr()),
                  CareerTimelineWidget(careerHistory: profile.careerHistory!),
                  const SizedBox(height: 24),
                ],

                // Achievements
                if (profile.achievements != null && profile.achievements!.isNotEmpty) ...[
                  _buildSectionHeader('profile.achievements'.tr()),
                  ...profile.achievements!.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                ],

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final bloc = context.read<PlayerProfileBloc>();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: bloc,
                                child: EditProfileScreen(profile: state.profile),
                              ),
                            ),
                          );
                          bloc.add(const LoadPlayerProfile());
                        },
                        icon: const Icon(Icons.edit),
                        label: Text('common.edit'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          if (profile.id != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerProfileScreen(playerId: profile.id!),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.visibility),
                        label: Text('dashboard.view_public'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const SettingsScreen(embed: true);
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 3) {
          _scaffoldKey.currentState?.openDrawer();
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'dashboard.home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.mail),
          label: 'dashboard.messages'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'dashboard.profile'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: 'settings.settings'.tr(),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
        builder: (builderContext, state) {
          String userName = 'Player';
          String? photoUrl;
          
          if (state is PlayerProfileLoaded) {
            userName = state.profile.fullName;
            photoUrl = state.profile.profilePhotoUrl;
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName),
                accountEmail: const Text(''), 
                currentAccountPicture: CircleAvatar(
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  backgroundColor: Colors.white,
                  child: photoUrl == null 
                    ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'P', style: TextStyle(fontSize: 24, color: AppColors.primaryBlue))
                    : null,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: Text('dashboard.home'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail),
                title: Text('dashboard.messages'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('dashboard.profile'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 2);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text('settings.settings'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'common.logout'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context); // Close drawer
                  
                  // Show confirmation dialog
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text('settings.logout_confirmation'.tr()),
                      content: Text('settings.logout_message'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text('common.cancel'.tr()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(
                            'common.logout'.tr(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    try {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      // Call logout service
                      await getIt<AuthService>().logout();

                      if (mounted) {
                        // Close loading dialog
                        Navigator.of(context).pop();
                        
                        // Navigate to main auth screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.main,
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
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
                          AppRoutes.main,
                          (route) => false,
                        );
                      }
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

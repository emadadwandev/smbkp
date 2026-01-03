import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/side_menu.dart';
import '../../../../../core/widgets/player_card.dart';
import '../../../../../app/routes.dart';
import '../../../profile/presentation/bloc/coach_profile_bloc.dart';
import '../../../profile/presentation/bloc/coach_profile_event.dart';
import '../../../profile/presentation/bloc/coach_profile_state.dart';
import '../../../../settings/presentation/pages/settings_screen.dart';
import '../../../../../core/services/scout_service.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../injection.dart';
import '../../../../scout/dashboard/presentation/pages/player_profile_screen.dart';
import '../../../../../core/constants/api_constants.dart';

/// Screen: Coach dashboard
/// Main navigation hub for coaches with 4 tabs: Search, Bookmarks, Requests, Profile
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final _scoutService = getIt<ScoutService>();
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  bool _isInitialized = false;
  List<PlayerSearchResult> _players = [];
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      context.read<CoachProfileBloc>().add(const LoadCoachProfile());
      _searchPlayers();
      _isInitialized = true;
    }
  }

  Future<void> _searchPlayers([String? query]) async {
    setState(() => _isLoading = true);
    try {
      final response = await _scoutService.searchPlayers(
        query: query,
        perPage: 20,
        endpoint: ApiConstants.coachPlayersSearch,
      );
      if (mounted) {
        setState(() {
          _players = response.players;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching players: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoachProfileBloc, CoachProfileState>(
      listener: (context, state) {
        // Handle profile not found - redirect to setup
        if (state is CoachProfileNotFound) {
          Navigator.pushReplacementNamed(context, '/coach/profile-setup');
        }
        
        // Handle verification states - redirect accordingly
        if (state is CoachProfilePendingVerification) {
          Navigator.pushReplacementNamed(
            context,
            '/coach/verification-pending',
          );
        } else if (state is CoachVerificationRejected) {
          Navigator.pushReplacementNamed(
            context,
            '/coach/document-upload',
          );
        } else if (state is CoachProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading while checking profile/verification status
        if (state is CoachProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show dashboard only if verified and profile complete
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _getAppBarTitle(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: AppColors.primaryBlue,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          drawer: BlocBuilder<CoachProfileBloc, CoachProfileState>(
            builder: (blocContext, state) {
              final profile = state is CoachProfileLoaded ? state.profile : null;
              return SideMenu(
                userName: profile?.fullName ?? 'Coach',
                userRole: 'Coach',
                photoUrl: profile?.profilePhotoUrl,
                onLogout: () async {
                  // Drawer is already closed by SideMenu
                  
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
                          AppRoutes.login,
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
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    }
                  }
                },
              );
            },
          ),
          body: _buildBody(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: 'coach.search_players'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.groups),
                label: 'Team',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: 'coach.profile'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: 'settings.settings'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'coach.search_players'.tr();
      case 1:
        return 'Team';
      case 2:
        return 'coach.profile'.tr();
      case 3:
        return 'settings.settings'.tr();
      default:
        return 'coach.dashboard'.tr();
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildSearchTab();
      case 1:
        return _buildTeamTab();
      case 2:
        return _buildProfileTab();
      case 3:
        return const SettingsScreen(embed: true);
      default:
        return const SizedBox.shrink();
    }
  }

  // Tab 0: Search Players
  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'coach.search_by_name'.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _searchController.clear());
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              // Debounce search could be added here
              if (value.length > 2 || value.isEmpty) {
                _searchPlayers(value);
              }
            },
          ),
        ),

        // Players List
        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildPlayersList(),
        ),
      ],
    );
  }

  Widget _buildPlayersList() {
    if (_players.isEmpty) {
      return Center(
        child: Text(
          'No players found',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final player = _players[index];
        return _buildPlayerCard(player);
      },
    );
  }

  Widget _buildPlayerCard(PlayerSearchResult player) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ProfessionalPlayerCard(
        name: player.name,
        age: player.age,
        position: player.primaryPosition,
        nationality: player.nationality,
        club: player.currentClub,
        photoUrl: player.profilePhotoUrl,
        completionScore: player.profileCompletionScore,
        isBookmarked: player.isBookmarked,
        onTap: () {
          // Navigate to player profile
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerProfileScreen(playerId: player.id),
            ),
          );
        },
        // onBookmark removed as per request to replace with Team feature
        onAddToTeam: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feature coming soon')),
          );
        },
      ),
    );
  }

  // Tab 1: Team
  Widget _buildTeamTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Team feature coming in next update',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Tab 3: Profile
  Widget _buildProfileTab() {
    return BlocBuilder<CoachProfileBloc, CoachProfileState>(
      builder: (context, state) {
        if (state is CoachProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CoachProfileLoaded) {
          final profile = state.profile;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile Header
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBlue, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: profile.profilePhotoUrl != null
                        ? NetworkImage(profile.profilePhotoUrl!)
                        : null,
                    child: profile.profilePhotoUrl == null
                        ? Text(
                            _getInitials(profile.fullName),
                            style: const TextStyle(
                              fontSize: 32,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Role
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.currentRole} • ${profile.clubName}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Location (if available)
                if (profile.fullLocation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        profile.fullLocation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Stats Row
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Experience',
                        '${profile.yearsOfExperience} Years',
                        Icons.timeline,
                      ),
                      _buildVerticalDivider(),
                      _buildStatItem(
                        'License',
                        profile.coachingLicense.isEmpty ? 'N/A' : profile.coachingLicense,
                        Icons.card_membership,
                      ),
                      if (profile.academies != null && profile.academies!.isNotEmpty) ...[
                        _buildVerticalDivider(),
                        _buildStatItem(
                          'Academies',
                          '${profile.academies!.length}',
                          Icons.school,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/coach/edit-profile');
                      },
                      icon: const Icon(Icons.edit, size: 20),
                      label: Text('coach.edit_profile'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Content Sections
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Section
                      _buildSectionTitle('About'),
                      const SizedBox(height: 8),
                      Text(
                        profile.bio ?? 'No bio added yet.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Specializations Section
                      _buildSectionTitle('coach.specializations'.tr()),
                      const SizedBox(height: 12),
                      if (profile.specializations != null && profile.specializations!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.specializations!.map((spec) => Chip(
                            label: Text(
                              spec,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          )).toList(),
                        )
                      else
                        Text(
                          'No specializations listed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Academies Section
                      if (profile.academies != null && profile.academies!.isNotEmpty) ...[
                        _buildSectionTitle('Academies'),
                        const SizedBox(height: 12),
                        ...profile.academies!.map((academy) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: const Icon(Icons.school, size: 20, color: AppColors.primaryBlue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      academy['name'] ?? 'Unknown Academy',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (academy['role'] != null)
                                      Text(
                                        academy['role'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 24),
                      ],

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () async {
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
                                    AppRoutes.login,
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
                                    AppRoutes.login,
                                    (route) => false,
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          label: Text(
                            'common.logout'.tr(),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('State: ${state.runtimeType}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<CoachProfileBloc>().add(const LoadCoachProfile());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Removed old helper methods as they are no longer used
  // _buildInfoCard, _buildChipsCard, _buildAcademiesCard replaced by inline widgets


  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../app/routes.dart';
import '../../../../../core/widgets/side_menu.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../profile/presentation/bloc/scout_profile_bloc.dart';
import '../../../profile/presentation/bloc/scout_profile_event.dart';
import '../../../profile/presentation/bloc/scout_profile_state.dart';
import '../../../profile/domain/entities/scout_profile_entity.dart';
import '../../../../../core/services/scout_service.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../injection.dart';
import '../widgets/recommended_player_card.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/upcoming_event_card.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/player_list_card.dart';
import 'player_profile_screen.dart';
import 'player_filter_screen.dart';
import 'match_report_details_screen.dart';
import '../../../profile/presentation/pages/scout_profile_screen.dart';

/// Scout Dashboard - Main screen with player search, bookmarks, and profile
class ScoutDashboardScreen extends StatefulWidget {
  const ScoutDashboardScreen({super.key});

  @override
  State<ScoutDashboardScreen> createState() => _ScoutDashboardScreenState();
}

class _ScoutDashboardScreenState extends State<ScoutDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final _scoutService = getIt<ScoutService>();
  final ImagePicker _picker = ImagePicker();
  
  // Player search state
  List<PlayerSearchResult> _players = [];
  bool _isLoadingPlayers = false;
  
  // Bookmarks state
  List<PlayerSearchResult> _bookmarkedPlayers = [];
  bool _isLoadingBookmarks = false;
  
  // Filter state
  String? _selectedPosition;
  int? _ageMin;
  int? _ageMax;
  String? _selectedCountry;
  String? _selectedFoot;
  bool _isInitialized = false;

  // Dashboard Stats
  ScoutDashboardStats? _dashboardStats;
  
  // Recent Match Reports
  List<MatchReport> _recentMatchReports = [];
  bool _isLoadingReports = false;

  ScoutProfileEntity? _getProfileFromState(ScoutProfileState state) {
    if (state is ScoutProfileLoaded) return state.profile;
    if (state is ScoutProfileUpdated) return state.profile;
    if (state is ScoutProfileCreated) return state.profile;
    if (state is ScoutProfileVerified) return state.profile;
    if (state is ScoutProfilePendingVerification) return state.profile;
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Load scout profile on init
      context.read<ScoutProfileBloc>().add(const LoadScoutProfile());
      // Load players
      _searchPlayers();
      // Load stats
      _loadDashboardStats();
      // Load recent match reports
      _loadRecentMatchReports();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      if (mounted) {
        context.read<ScoutProfileBloc>().add(UploadScoutProfilePhoto(file));
      }
    }
  }

  Future<void> _loadRecentMatchReports() async {
    setState(() {
      _isLoadingReports = true;
    });
    try {
      final reports = await _scoutService.getRecentMatchReports();
      setState(() {
        _recentMatchReports = reports;
        _isLoadingReports = false;
      });
    } catch (e) {
      debugPrint('Failed to load recent match reports: $e');
      setState(() {
        _isLoadingReports = false;
      });
    }
  }

  Future<void> _searchPlayers({String? query}) async {
    setState(() {
      _isLoadingPlayers = true;
    });

    try {
      final response = await _scoutService.searchPlayers(
        query: query ?? _searchController.text,
        position: _selectedPosition,
        ageMin: _ageMin,
        ageMax: _ageMax,
        country: _selectedCountry,
        preferredFoot: _selectedFoot,
        page: 1,
        perPage: 20,
      );

      setState(() {
        _players = response.players;
        _isLoadingPlayers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlayers = false;
      });
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await _scoutService.getDashboardStats();
      setState(() {
        _dashboardStats = stats;
      });
    } catch (e) {
      // Silently fail for stats or show snackbar
      debugPrint('Failed to load dashboard stats: $e');
    }
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoadingBookmarks = true;
    });

    try {
      final bookmarks = await _scoutService.getBookmarkedPlayers();
      setState(() {
        _bookmarkedPlayers = bookmarks;
        _isLoadingBookmarks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookmarks = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bookmarks: $e')),
        );
      }
    }
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'dashboard.home'.tr();
      case 1:
        return 'My Network';
      case 2:
        return 'Messages';
      case 3:
        return 'profile.profile'.tr();
      default:
        return 'Scout Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
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
      drawer: BlocBuilder<ScoutProfileBloc, ScoutProfileState>(
        builder: (blocContext, state) {
          final profile = _getProfileFromState(state);
          return SideMenu(
            userName: profile?.fullName ?? 'Scout',
            userRole: 'Scout',
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
            onMatchReportAdded: () {
              _loadRecentMatchReports();
              _loadDashboardStats(); // Also refresh stats as match count increases
            },
          );
        },
      ),
      body: BlocConsumer<ScoutProfileBloc, ScoutProfileState>(
        listener: (context, state) {
          if (state is ScoutProfilePendingVerification) {
            // Redirect to verification pending screen
            Navigator.pushReplacementNamed(
              context,
              '/scout/verification-pending',
            );
          } else if (state is ScoutProfileNotFound) {
            // Redirect to profile setup
            Navigator.pushReplacementNamed(
              context,
              '/scout/profile-setup',
            );
          } else if (state is UploadingScoutProfilePhoto) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('profile.uploading_photo'.tr())),
            );
          } else if (state is ScoutProfileUpdated) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('success.photo_uploaded'.tr()), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody(ScoutProfileState state) {
    if (state is ScoutProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ScoutProfileError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(state.message, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ScoutProfileBloc>().add(const LoadScoutProfile());
              },
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      );
    }

    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab(state);
      case 1:
        return _buildBookmarksTab(); // My Network
      case 2:
        return _buildRequestsTab(); // Messages
      case 3:
        return _buildProfileTab(state);
      default:
        return _buildDashboardTab(state);
    }
  }

  Widget _buildDashboardTab(ScoutProfileState state) {
    final profile = _getProfileFromState(state);
    final userName = profile?.firstName ?? 'Scout';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          _buildWelcomeCard(userName, profile?.profilePhotoUrl),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              QuickStatCard(
                number: _dashboardStats?.playersScouted.toString() ?? '-',
                label: 'Players Scouted',
                icon: Icons.search,
              ),
              const SizedBox(width: 8),
              QuickStatCard(
                number: _dashboardStats?.matchesWatched.toString() ?? '-',
                label: 'Matches Watched',
                icon: Icons.sports_soccer,
              ),
              const SizedBox(width: 8),
              QuickStatCard(
                number: _dashboardStats?.newProfiles.toString() ?? '-',
                label: 'New Profiles',
                icon: Icons.person_add,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Row(
            children: [
              QuickActionButton(
                label: 'Find Players',
                icon: Icons.search,
                glowColor: const Color(0xFF4285F4),
                onTap: () {
                  // Navigate to search or show search modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlayerFilterScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              QuickActionButton(
                label: 'My Network',
                icon: Icons.people,
                glowColor: const Color(0xFF4CAF50),
                onTap: () {
                  setState(() => _currentIndex = 1);
                },
              ),
              const SizedBox(width: 8),
              QuickActionButton(
                label: 'Messages',
                icon: Icons.chat_bubble,
                glowColor: const Color(0xFF8AB4F8),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Messages feature coming soon!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recommended Players
          Text(
            'Recommended Players',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: _isLoadingPlayers
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _players.isEmpty ? 3 : _players.length,
                    itemBuilder: (context, index) {
                      if (_players.isEmpty) {
                        // Mock data if no players found
                        final mockPlayers = [
                          {'name': 'Ahmed Hassan', 'pos': 'Midfielder', 'rating': 8.5},
                          {'name': 'Fatima Ali', 'pos': 'Forward', 'rating': 9.1},
                          {'name': 'Youseff Saber', 'pos': 'Defender', 'rating': 7.9},
                        ];
                        final p = mockPlayers[index];
                        return RecommendedPlayerCard(
                          name: p['name'] as String,
                          position: p['pos'] as String,
                          rating: p['rating'] as double,
                          isSelected: index == 0,
                        );
                      }
                      
                      final player = _players[index];
                      return RecommendedPlayerCard(
                        name: player.name,
                        position: player.primaryPosition,
                        rating: (player.profileCompletionScore / 10).clamp(0.0, 10.0), // Mock rating
                        imageUrl: player.profilePhotoUrl,
                        isSelected: index == 0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerProfileScreen(
                                playerId: player.id,
                                initialName: player.name,
                                initialPhotoUrl: player.profilePhotoUrl,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Recent Match Reports & Top Scouted Players
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Match Reports
              Text(
                'Recent Match Reports',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoadingReports)
                const Center(child: CircularProgressIndicator())
              else if (_recentMatchReports.isEmpty)
                Text(
                  'No match reports yet.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                )
              else
                ..._recentMatchReports.map((report) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MatchReportCard(
                    tournament: report.tournamentName,
                    date: DateFormat('MMM dd, yyyy').format(report.matchDate),
                    teams: '${report.teamA} vs ${report.teamB}',
                    goals: report.result,
                    players: (report.playersToWatch?.length ?? 0).toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchReportDetailsScreen(report: report),
                        ),
                      );
                    },
                  ),
                )),
              
              const SizedBox(height: 24),
              
              // Top 5 Scouted Players
              Text(
                'Top 5 Scouted Players',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const RankedPlayerCard(
                rank: 1,
                name: 'Ahmed Hassan',
                position: 'Forward',
                rating: '92',
                color: Color(0xFF4285F4),
              ),
              const RankedPlayerCard(
                rank: 2,
                name: 'Karim Ramadan',
                position: 'Midfielder',
                rating: '88',
                color: Color(0xFF4CAF50),
              ),
              const RankedPlayerCard(
                rank: 3,
                name: 'Youssef Mohamed',
                position: 'Defender',
                rating: '85',
                color: Color(0xFF9AA0A6),
              ),
              const RankedPlayerCard(
                rank: 4,
                name: 'Mohamed Farouk',
                position: 'Striker',
                rating: '83',
                color: Color(0xFF8AB4F8),
              ),
              const RankedPlayerCard(
                rank: 5,
                name: 'Ali Samir',
                position: 'Winger',
                rating: '80',
                color: Color(0xFF9AA0A6),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const RecentActivityWidget(),
          const SizedBox(height: 24),

          // Upcoming Events
          Text(
            'Upcoming Events',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                UpcomingEventCard(
                  title: 'Youth Tournament - Cairo',
                  date: 'Nov 25, 2025',
                ),
                UpcomingEventCard(
                  title: 'Talent Showcase - Alexandria',
                  date: 'Dec 3, 2025',
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // Bottom padding for nav bar
        ],
      ),
    );
  }

  Widget _buildBookmarksTab() {
    if (_isLoadingBookmarks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarkedPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Bookmarked Players',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark players you\'re interested in to view them here.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarkedPlayers.length,
      itemBuilder: (context, index) {
        final player = _bookmarkedPlayers[index];
        return PlayerListCard(
          id: player.id,
          name: player.name,
          primaryPosition: player.primaryPosition,
          currentClub: player.currentClub,
          profilePhotoUrl: player.profilePhotoUrl,
          nationality: player.nationality,
          city: player.city,
          country: player.country,
          onReturn: () => _loadBookmarks(),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return Center(
      child: Text(
        'Messages',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
      ),
    );
  }

  Widget _buildProfileTab(ScoutProfileState state) {
    return const ScoutProfileScreen();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        onTap: (index) {
          if (index == 1) {
            _loadBookmarks();
          }
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Messages feature coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Players',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'My Network',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String userName, String? photoUrl) {
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
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
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
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

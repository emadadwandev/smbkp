import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/services/scout_service.dart';
import '../../../../../injection.dart';

class PlayerProfileScreen extends StatefulWidget {
  final String playerId;
  final String? initialName;
  final String? initialPhotoUrl;

  const PlayerProfileScreen({
    super.key,
    required this.playerId,
    this.initialName,
    this.initialPhotoUrl,
  });

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final _scoutService = getIt<ScoutService>();
  PlayerProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _scoutService.getPlayerProfile(widget.playerId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : _buildContent(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !_isLoading && _error == null && _profile != null
          ? _buildStickyBottomBar(_profile!)
          : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            'errors.error_loading_profile'.tr(),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          TextButton(
            onPressed: _loadProfile,
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildProfileHeader(profile),
              Transform.translate(
                offset: const Offset(0, -60),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      _buildSectionTitle('profile.about'.tr()),
                      const SizedBox(height: 8),
                      Text(
                        profile.bio!,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildSkillsChart(profile),
                    const SizedBox(height: 24),
                    
                    _buildTechnicalSkills(profile),
                    const SizedBox(height: 24),

                    if (profile.tacticalData != null && profile.tacticalData!.isNotEmpty) ...[
                      _buildTacticalChart(profile),
                      const SizedBox(height: 24),
                    ],

                    if (profile.stats.isNotEmpty) ...[
                      _buildSectionTitle('profile.career_stats'.tr()),
                      const SizedBox(height: 16),
                      _buildCareerStats(profile),
                      const SizedBox(height: 24),
                    ],

                    if (profile.achievements != null && profile.achievements!.isNotEmpty) ...[
                      _buildAchievementsSection(profile.achievements!),
                      const SizedBox(height: 24),
                    ],

                    if (profile.careerHistory != null && profile.careerHistory!.isNotEmpty) ...[
                      _buildSectionTitle('profile.career_history'.tr()),
                      const SizedBox(height: 16),
                      _buildCareerHistory(profile.careerHistory!),
                      const SizedBox(height: 24),
                    ],

                    if (profile.photoUrls.isNotEmpty) ...[
                      _buildSectionTitle('profile.photos'.tr()),
                      const SizedBox(height: 16),
                      _buildPhotoGallery(profile),
                      const SizedBox(height: 24),
                    ],

                    if (profile.videos.isNotEmpty) ...[
                      _buildSectionTitle('profile.highlight_videos'.tr()),
                      const SizedBox(height: 16),
                      _buildVideoGallery(profile),
                      const SizedBox(height: 24),
                    ],

                    _buildContactInfoSection(profile),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildProfileHeader(PlayerProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: profile.heroImageUrl ?? "https://images.unsplash.com/photo-1522778119026-d647f0565c6a?auto=format&fit=crop&w=800&q=80",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.stadium, size: 50, color: Colors.white24),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black45,
                      Colors.transparent,
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 280),
            Transform.translate(
              offset: const Offset(0, -80),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: profile.profilePhotoUrl != null
                          ? CachedNetworkImageProvider(profile.profilePhotoUrl!)
                          : null,
                      child: profile.profilePhotoUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.primaryPosition,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("profile.physical".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.height, "profile.height".tr(), profile.heightCm != null ? "${profile.heightCm} cm" : "-"),
                            _buildInfoRow(Icons.monitor_weight, "profile.weight".tr(), profile.weightKg != null ? "${profile.weightKg} kg" : "-"),
                            _buildInfoRow(Icons.person, "profile.gender".tr(), profile.gender != null ? "profile.gender_${profile.gender}".tr() : "-"),
                            _buildInfoRow(Icons.sports_soccer, "profile.preferred_foot".tr(), profile.preferredFoot ?? "-"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text("profile.age".tr(args: [profile.age.toString()]), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                             const SizedBox(height: 8),
                             Text("profile.nationality_label".tr(args: [profile.nationality ?? "-"]), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                             const SizedBox(height: 4),
                             const Icon(Icons.flag, size: 20),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("profile.club".tr(), style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.shield, size: 20),
                                const SizedBox(width: 4),
                                Expanded(child: Text(profile.currentClub ?? "-", style: const TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(PlayerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildActionButtons(profile),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                children: [
                  TextSpan(text: "$label: ", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                  TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PlayerProfile profile) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showContactRequestDialog(context, profile),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'scout.contact_request'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              final String shareLink = 'https://scoutmena.com/player/${profile.id}';
              Share.share('Check out ${profile.name} on ScoutMena! $shareLink');
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              profile.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: profile.isBookmarked ? AppColors.primaryBlue : Theme.of(context).iconTheme.color,
            ),
            onPressed: () async {
              try {
                if (profile.isBookmarked) {
                  await _scoutService.unbookmarkPlayer(profile.id);
                } else {
                  await _scoutService.bookmarkPlayer(profile.id);
                }
                _loadProfile();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        profile.isBookmarked 
                            ? 'scout.removed_bookmark'.tr() 
                            : 'scout.added_bookmark'.tr()
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCareerStats(PlayerProfile profile) {
    // Filter out any 'career' record to get actual seasons
    final seasonStats = profile.stats.where((s) => s.season.toLowerCase() != 'career').toList();

    // Calculate totals from actual seasons
    int apps = 0;
    int goals = 0;
    int assists = 0;
    int mins = 0;
    
    for (var s in seasonStats) {
      apps += s.appearances;
      goals += s.goals;
      assists += s.assists;
      mins += s.minutesPlayed;
    }
    
    final totals = PlayerStat(
      season: 'career', 
      appearances: apps, 
      goals: goals, 
      assists: assists, 
      minutesPlayed: mins
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLifetimeTotals(totals),
        if (seasonStats.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildPerformanceTrends(seasonStats),
        ],
      ],
    );
  }

  Widget _buildLifetimeTotals(PlayerStat totals) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile.lifetime_totals".tr(),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem(Icons.person, "profile.total_appearances".tr(), "${totals.appearances}"),
              _buildTotalItem(Icons.sports_soccer, "profile.total_goals".tr(), "${totals.goals}"),
              _buildTotalItem(Icons.hiking, "profile.total_assists".tr(), "${totals.assists}"),
              _buildTotalItem(Icons.timer, "profile.minutes_played".tr(), "${totals.minutesPlayed}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).iconTheme.color),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrends(List<PlayerStat> stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Prepare spots
    final goalSpots = <FlSpot>[];
    final assistSpots = <FlSpot>[];
    
    double maxY = 0;
    
    for (int i = 0; i < stats.length; i++) {
      final s = stats[i];
      goalSpots.add(FlSpot(i.toDouble(), s.goals.toDouble()));
      assistSpots.add(FlSpot(i.toDouble(), s.assists.toDouble()));
      
      if (s.goals > maxY) maxY = s.goals.toDouble();
      if (s.assists > maxY) maxY = s.assists.toDouble();
    }
    
    // Add some buffer to maxY
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY < 10) maxY = 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile.performance_trends".tr(),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("profile.goals".tr(), Colors.blue),
              const SizedBox(width: 24),
              _buildLegendItem("profile.assists".tr(), Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < stats.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              stats[index].season,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (stats.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: goalSpots,
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: assistSpots,
                    isCurved: false,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCareerHistory(List<Map<String, dynamic>> history) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: history.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == history.length - 1;
          
          final clubName = item['club_name'] ?? 'profile.unknown_club'.tr();
          final startDate = item['start_date'] as String?;
          final endDate = item['end_date'] as String?;
          final isCurrent = item['is_current'] == true;
          
          String period = '';
          if (startDate != null) {
            final startYear = DateTime.tryParse(startDate)?.year.toString() ?? startDate;
            final endYear = isCurrent ? 'profile.present'.tr() : (endDate != null ? (DateTime.tryParse(endDate)?.year.toString() ?? endDate) : 'profile.unknown'.tr());
            period = '$startYear - $endYear';
          }
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          clubName,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoGallery(PlayerProfile profile) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: profile.photoUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoViewer(imageUrl: profile.photoUrls[index]),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: profile.photoUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.error, color: Colors.white24),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoGallery(PlayerProfile profile) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: profile.videos.length,
        itemBuilder: (context, index) {
          final video = profile.videos[index];
          final isProcessing = video.status == 'pending' || video.status == 'processing';
          final hasUrl = video.videoUrl != null;
          
          return GestureDetector(
            onTap: () {
              if (hasUrl) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleVideoPlayer(videoUrl: video.videoUrl!),
                  ),
                );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('profile.video_processing'.tr())),
                  );
              }
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  // Thumbnail
                  if (video.thumbnailUrl != null)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                            imageUrl: video.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(color: Colors.grey[900]),
                            errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                        ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[900],
                      ),
                    ),
                  
                  // Icon / Status
                  if (isProcessing)
                     Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const CircularProgressIndicator(color: Colors.white),
                         const SizedBox(height: 8),
                         Text('profile.processing'.tr(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                       ],
                     )
                  else
                     const Icon(Icons.play_circle_outline, color: Colors.white, size: 48),

                  // Title removed - video names are now hidden
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  Widget _buildAchievementsSection(List<String> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('profile.achievement_highlights'.tr()),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: achievements.map((a) => _buildAchievementCard(a)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String achievement) {
    // Determine icon based on text
    IconData icon = Icons.emoji_events;
    if (achievement.toLowerCase().contains('scorer')) icon = Icons.emoji_events;
    else if (achievement.toLowerCase().contains('assist')) icon = Icons.hiking; 
    else if (achievement.toLowerCase().contains('month')) icon = Icons.star;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              achievement,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(PlayerProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('profile.contact_information'.tr()),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildContactRow(Icons.email, 'auth.email'.tr(), profile.contactEmail ?? 'profile.not_provided'.tr()),
              Divider(color: Theme.of(context).dividerColor),
              _buildContactRow(Icons.phone, 'auth.phone'.tr(), profile.phoneNumber ?? 'profile.not_provided'.tr()),
              if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) ...[
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: profile.socialLinks!.entries.map((e) {
                    IconData icon = Icons.link;
                    if (e.key.toLowerCase().contains('instagram')) icon = Icons.camera_alt;
                    if (e.key.toLowerCase().contains('twitter') || e.key.toLowerCase().contains('x')) icon = Icons.alternate_email;
                    if (e.key.toLowerCase().contains('facebook')) icon = Icons.facebook;
                    
                    return Column(
                      children: [
                        Icon(icon, color: AppColors.primaryBlue),
                        const SizedBox(height: 4),
                        Text(
                          e.key,
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 10),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSkills(PlayerProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skills = [
      {'label': 'attributes.ball_control'.tr(), 'key': 'ball_control', 'icon': Icons.sports_soccer},
      {'label': 'attributes.dribbling'.tr(), 'key': 'dribbling', 'icon': Icons.gesture},
      {'label': 'attributes.passing'.tr(), 'key': 'passing', 'icon': Icons.compare_arrows},
      {'label': 'attributes.shooting'.tr(), 'key': 'shooting', 'icon': Icons.gps_fixed},
      {'label': 'attributes.defending'.tr(), 'key': 'defending', 'icon': Icons.shield},
      {'label': 'attributes.heading'.tr(), 'key': 'heading', 'icon': Icons.arrow_upward},
    ];

    double getSkillValue(String key) {
       if (profile.technicalData == null) return 0;
       
       // Check nested 'data' map first
       if (profile.technicalData!['data'] is Map) {
          final dataMap = profile.technicalData!['data'] as Map;
          for (var entry in dataMap.entries) {
             if (entry.key.toString().toLowerCase() == key.toLowerCase()) {
                return (entry.value as num?)?.toDouble() ?? 0;
             }
          }
       }
       
       // Check direct keys
       for (var entry in profile.technicalData!.entries) {
         if (entry.key.toLowerCase().replaceAll(' ', '_') == key.toLowerCase()) {
            return (entry.value as num?)?.toDouble() ?? 0;
         }
       }
       return 0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile.technical_skills".tr(),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              final value = getSkillValue(skill['key'] as String);
              return _buildSkillItem(
                skill['label'] as String,
                value,
                skill['icon'] as IconData,
                isDark
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillItem(String label, double value, IconData icon, bool isDark) {
     final displayValue = (value / 10).clamp(0, 10);
     
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Row(
           children: [
             Icon(icon, size: 16, color: AppColors.primaryBlue),
             const SizedBox(width: 8),
             Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w500, fontSize: 12)),
           ],
         ),
         const SizedBox(height: 8),
         Row(
           children: [
             Expanded(
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(4),
                 child: LinearProgressIndicator(
                   value: value / 100,
                   backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                   valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                   minHeight: 6,
                 ),
               ),
             ),
             const SizedBox(width: 8),
             Text(
               "${displayValue.toStringAsFixed(0)}/10",
               style: TextStyle(
                 color: Theme.of(context).textTheme.bodySmall?.color,
                 fontWeight: FontWeight.bold,
                 fontSize: 12,
               ),
             ),
           ],
         ),
       ],
     );
  }

  Widget _buildSkillsChart(PlayerProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attributes = [
      {'key': 'Speed', 'label': 'attributes.speed'.tr()},
      {'key': 'Acceleration', 'label': 'attributes.acceleration'.tr()},
      {'key': 'Strength', 'label': 'attributes.strength'.tr()},
      {'key': 'Stamina', 'label': 'attributes.stamina'.tr()},
      {'key': 'Agility', 'label': 'attributes.agility'.tr()},
      {'key': 'Balance', 'label': 'attributes.balance'.tr()}
    ];

    double getValue(String key) {
      if (profile.physicalData == null) return 0.0;
      
      // Check if attributes are in a nested 'data' map (as per API response)
      final dataMap = profile.physicalData!['data'];
      if (dataMap is Map) {
        for (var entry in dataMap.entries) {
          if (entry.key.toString().toLowerCase() == key.toLowerCase()) {
            return (entry.value as num?)?.toDouble() ?? 0.0;
          }
        }
      }
      
      // Fallback: check directly in physicalData
      for (var entry in profile.physicalData!.entries) {
        if (entry.key.toLowerCase() == key.toLowerCase()) {
          return (entry.value as num?)?.toDouble() ?? 0.0;
        }
      }
      return 0.0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile.skills_attributes".tr(),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primaryBlue.withOpacity(0.2),
                    borderColor: AppColors.primaryBlue,
                    entryRadius: 3,
                    dataEntries: attributes.map((attr) => RadarEntry(value: getValue(attr['key']!))).toList(),
                    borderWidth: 2,
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                titlePositionPercentageOffset: 0.1,
                titleTextStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color, 
                  fontSize: 12
                ),
                getTitle: (index, angle) {
                  if (index < attributes.length) {
                    return RadarChartTitle(text: attributes[index]['label']!);
                  }
                  return const RadarChartTitle(text: '');
                },
                tickCount: 4,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                tickBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.2), 
                  width: 1
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalChart(PlayerProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attributes = [
      {'key': 'Positioning', 'label': 'attributes.positioning'.tr()},
      {'key': 'Vision', 'label': 'attributes.vision'.tr()},
      {'key': 'Decision Making', 'label': 'attributes.decision_making'.tr()},
      {'key': 'Work Rate', 'label': 'attributes.work_rate'.tr()}
    ];

    double getValue(String key) {
      if (profile.tacticalData == null) return 0.0;
      
      // Normalize key for lookup (e.g. "Decision Making" -> "decision_making")
      final lookupKey = key.toLowerCase().replaceAll(' ', '_');
      
      // Check nested 'data' map first if it exists (handling potential API structure)
      if (profile.tacticalData!['data'] is Map) {
        final dataMap = profile.tacticalData!['data'] as Map;
        for (var entry in dataMap.entries) {
          if (entry.key.toString().toLowerCase() == lookupKey) {
            return (entry.value as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      // Check direct keys
      for (var entry in profile.tacticalData!.entries) {
        if (entry.key.toLowerCase() == lookupKey) {
          return (entry.value as num?)?.toDouble() ?? 0.0;
        }
      }
      return 0.0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile.tactical_attributes".tr(),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primaryBlue.withOpacity(0.2),
                    borderColor: AppColors.primaryBlue,
                    entryRadius: 3,
                    dataEntries: attributes.map((attr) => RadarEntry(value: getValue(attr['key']!))).toList(),
                    borderWidth: 2,
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                titlePositionPercentageOffset: 0.1,
                titleTextStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color, 
                  fontSize: 12
                ),
                getTitle: (index, angle) {
                  if (index < attributes.length) {
                    return RadarChartTitle(text: attributes[index]['label']!);
                  }
                  return const RadarChartTitle(text: '');
                },
                tickCount: 4,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                tickBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.2), 
                  width: 1
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactRequestDialog(BuildContext context, PlayerProfile profile) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('scout.contact_player'.tr(args: [profile.name]), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('scout.contact_message_hint'.tr(), style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'scout.enter_message'.tr(),
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _scoutService.sendContactRequest(
                  recipientId: profile.id,
                  message: messageController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('scout.contact_request_sent'.tr())),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text('scout.send'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class SimpleVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const SimpleVideoPlayer({super.key, required this.videoUrl});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
            _controller.play();
            _isPlaying = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    _buildControls(),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                  _isPlaying = false;
                } else {
                  _controller.play();
                  _isPlaying = true;
                }
              });
            },
          ),
          Expanded(
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoViewer extends StatelessWidget {
  final String imageUrl;

  const PhotoViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
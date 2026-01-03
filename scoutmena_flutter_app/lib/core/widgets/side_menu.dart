import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../themes/app_colors.dart';
import '../themes/theme_cubit.dart';
import '../../app/routes.dart';
import '../../features/scout/dashboard/presentation/pages/add_match_report_screen.dart';

class SideMenu extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? photoUrl;
  final VoidCallback? onLogout;
  final VoidCallback? onMatchReportAdded;

  const SideMenu({
    super.key,
    required this.userName,
    required this.userRole,
    this.photoUrl,
    this.onLogout,
    this.onMatchReportAdded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'dashboard.home'.tr(),
                  onTap: () => Navigator.pop(context), // Close drawer, already on dashboard
                ),
                if (userRole.toLowerCase() == 'scout')
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment_outlined,
                    title: 'Match Report',
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMatchReportScreen()),
                      );
                      if (result == true && onMatchReportAdded != null) {
                        onMatchReportAdded!();
                      }
                    },
                  ),
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'profile.profile'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile based on role
                    if (userRole.toLowerCase() == 'player') {
                      // Navigate to player profile
                    } else if (userRole.toLowerCase() == 'scout') {
                      // Navigate to scout profile
                    }
                    // For now just close drawer as profile is usually a tab
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'settings.notifications'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'settings.settings'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, state) {
                    final isDarkMode = state == ThemeMode.dark;
                    return _buildMenuItem(
                      context,
                      icon: isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      title: isDarkMode ? 'settings.theme_light'.tr() : 'settings.theme_dark'.tr(),
                      onTap: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'common.logout'.tr(),
            textColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () {
              Navigator.pop(context);
              if (onLogout != null) {
                onLogout!();
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.trim().isEmpty ? 'Scout' : userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userRole.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                      letterSpacing: 1,
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.iconTheme.color,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? theme.textTheme.bodyLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

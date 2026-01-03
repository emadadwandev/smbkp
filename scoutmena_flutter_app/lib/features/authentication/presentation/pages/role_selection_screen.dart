import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/routes.dart';
import '../../../../core/themes/app_colors.dart';

class RoleOption {
  final String id;
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final Color color;

  RoleOption({
    required this.id,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.color,
  });
}

class RoleSelectionScreen extends StatefulWidget {
  final String? phoneNumber;
  
  const RoleSelectionScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  final List<RoleOption> _roles = [
    RoleOption(
      id: 'player',
      icon: Icons.sports_soccer,
      titleKey: 'account_types.player',
      descriptionKey: 'auth.role_player_description',
      color: AppColors.primaryBlue,
    ),
    RoleOption(
      id: 'scout',
      icon: Icons.search,
      titleKey: 'account_types.scout',
      descriptionKey: 'auth.role_scout_description',
      color: AppColors.primaryGreen,
    ),
    RoleOption(
      id: 'coach',
      icon: Icons.sports,
      titleKey: 'account_types.coach',
      descriptionKey: 'auth.role_coach_description',
      color: AppColors.primaryBlue,
    ),
    RoleOption(
      id: 'academy',
      icon: Icons.school,
      titleKey: 'account_types.academy',
      descriptionKey: 'auth.role_academy_description',
      color: AppColors.primaryGreen,
    ),
  ];

  void _selectRole(String roleId) {
    setState(() {
      _selectedRole = roleId;
    });
  }

  void _continue() {
    if (_selectedRole == null) return;

    // Navigate to registration screen with selected role and phone number
    Navigator.of(context).pushNamed(
      AppRoutes.register,
      arguments: {
        'role': _selectedRole,
        'phone': widget.phoneNumber ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auth.select_account_type'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'auth.select_role'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your account type to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Role Cards
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  return _buildRoleCard(_roles[index]);
                },
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _continue : null,
                  child: Text(
                    'continue'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(RoleOption role) {
    final isSelected = _selectedRole == role.id;

    return GestureDetector(
      onTap: () => _selectRole(role.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? role.color
                : Theme.of(context).dividerColor,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: role.color.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: role.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                role.icon,
                size: 32,
                color: role.color,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              role.titleKey.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  role.descriptionKey.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Checkmark
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: role.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

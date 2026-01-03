import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';

/// Widget: Coach achievements
/// Displays coaching achievements and milestones (placeholder)
class CoachAchievementsWidget extends StatelessWidget {
  const CoachAchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final achievements = [
      {
        'title': 'UEFA A License',
        'date': '2020',
        'icon': Icons.card_membership,
      },
      {
        'title': 'League Championship',
        'date': '2021',
        'icon': Icons.emoji_events,
      },
      {
        'title': 'Youth Development Award',
        'date': '2022',
        'icon': Icons.star,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryGreen,
                child: Icon(
                  achievement['icon'] as IconData,
                  color: AppColors.primaryGreen,
                ),
              ),
              title: Text(
                achievement['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(achievement['date'] as String),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add achievement functionality coming soon!'),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

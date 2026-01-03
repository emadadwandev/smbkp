import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';

/// Widget: Coach teams
/// Displays current and past teams coached (placeholder)
class CoachTeamsWidget extends StatelessWidget {
  const CoachTeamsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final teams = [
      {
        'name': 'Al Ahly Youth Team',
        'role': 'Head Coach',
        'period': '2021 - Present',
        'isCurrent': true,
      },
      {
        'name': 'Zamalek U19',
        'role': 'Assistant Coach',
        'period': '2019 - 2021',
        'isCurrent': false,
      },
      {
        'name': 'Egypt National Youth Team',
        'role': 'Fitness Coach',
        'period': '2018 - 2019',
        'isCurrent': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                child: const Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      team['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (team['isCurrent'] as bool)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(team['role'] as String),
                  Text(
                    team['period'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add team functionality coming soon!'),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

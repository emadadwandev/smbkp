import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/services/player_stats_service.dart';
import '../../../../../injection.dart';
import 'save_stats_screen.dart';

class UpdateStatsScreen extends StatefulWidget {
  const UpdateStatsScreen({Key? key}) : super(key: key);

  @override
  State<UpdateStatsScreen> createState() => _UpdateStatsScreenState();
}

class _UpdateStatsScreenState extends State<UpdateStatsScreen> {
  final _playerStatsService = getIt<PlayerStatsService>();
  late Future<List<PlayerStatsResponse>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _playerStatsService.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard.update_stats'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: FutureBuilder<List<PlayerStatsResponse>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No stats found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SaveStatsScreen()),
                      );
                      if (result == true) {
                        _loadStats();
                      }
                    },
                    child: Text('Add Stats'),
                  ),
                ],
              ),
            );
          }

          final statsList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: statsList.length,
            itemBuilder: (context, index) {
              final stats = statsList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text('${stats.season} - ${'profile.levels.${stats.level}'.tr()}'),
                  subtitle: Text(
                    '${'profile.goals'.tr()}: ${stats.goals}, ${'profile.assists'.tr()}: ${stats.assists}, ${'profile.appearances'.tr()}: ${stats.appearances}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaveStatsScreen(stats: stats),
                      ),
                    );
                    if (result == true) {
                      _loadStats();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SaveStatsScreen()),
          );
          if (result == true) {
            _loadStats();
          }
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

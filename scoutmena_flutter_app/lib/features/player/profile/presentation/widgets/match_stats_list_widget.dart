import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/player_match_stat.dart';
import '../bloc/player_match_stats_bloc.dart';
import '../bloc/player_match_stats_event.dart';
import '../pages/add_edit_match_stat_screen.dart';

class MatchStatsListWidget extends StatelessWidget {
  final List<PlayerMatchStat> stats;

  const MatchStatsListWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No match stats added yet.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              'vs ${stat.opponent}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM d, yyyy').format(stat.matchDate)),
                const SizedBox(height: 4),
                Text('Result: ${stat.result} | Rating: ${stat.rating ?? "-"}'),
                Text(
                    'G: ${stat.goals} | A: ${stat.assists} | Min: ${stat.minutesPlayed}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<PlayerMatchStatsBloc>(),
                          child: AddEditMatchStatScreen(stat: stat),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Match Stat'),
                        content: const Text(
                            'Are you sure you want to delete this match stat?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<PlayerMatchStatsBloc>()
                                  .add(DeleteMatchStat(stat.id!));
                              Navigator.pop(context);
                            },
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

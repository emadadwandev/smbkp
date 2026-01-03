import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../injection.dart';
import '../bloc/player_match_stats_bloc.dart';
import '../bloc/player_match_stats_event.dart';
import '../bloc/player_match_stats_state.dart';
import '../widgets/match_stats_list_widget.dart';
import 'add_edit_match_stat_screen.dart';

class MatchReportsScreen extends StatelessWidget {
  const MatchReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PlayerMatchStatsBloc>()..add(LoadMatchStats()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Match Reports'),
          backgroundColor: AppColors.primaryBlue,
        ),
        body: BlocBuilder<PlayerMatchStatsBloc, PlayerMatchStatsState>(
          builder: (context, state) {
            if (state is MatchStatsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MatchStatsLoaded) {
              return MatchStatsListWidget(stats: state.stats);
            } else if (state is MatchStatsError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No stats loaded'));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<PlayerMatchStatsBloc>(),
                      child: const AddEditMatchStatScreen(),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/player_match_stat.dart';

abstract class PlayerMatchStatsState extends Equatable {
  const PlayerMatchStatsState();

  @override
  List<Object> get props => [];
}

class MatchStatsInitial extends PlayerMatchStatsState {}

class MatchStatsLoading extends PlayerMatchStatsState {}

class MatchStatsLoaded extends PlayerMatchStatsState {
  final List<PlayerMatchStat> stats;

  const MatchStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class MatchStatsError extends PlayerMatchStatsState {
  final String message;

  const MatchStatsError({required this.message});

  @override
  List<Object> get props => [message];
}

class MatchStatOperationSuccess extends PlayerMatchStatsState {
  final String message;

  const MatchStatOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

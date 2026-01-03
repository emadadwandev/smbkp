import 'package:equatable/equatable.dart';
import '../../domain/entities/player_match_stat.dart';

abstract class PlayerMatchStatsEvent extends Equatable {
  const PlayerMatchStatsEvent();

  @override
  List<Object> get props => [];
}

class LoadMatchStats extends PlayerMatchStatsEvent {}

class AddMatchStat extends PlayerMatchStatsEvent {
  final PlayerMatchStat stat;

  const AddMatchStat(this.stat);

  @override
  List<Object> get props => [stat];
}

class UpdateMatchStat extends PlayerMatchStatsEvent {
  final PlayerMatchStat stat;

  const UpdateMatchStat(this.stat);

  @override
  List<Object> get props => [stat];
}

class DeleteMatchStat extends PlayerMatchStatsEvent {
  final String id;

  const DeleteMatchStat(this.id);

  @override
  List<Object> get props => [id];
}

import 'package:equatable/equatable.dart';

class PlayerMatchStat extends Equatable {
  final String? id;
  final DateTime matchDate;
  final String opponent;
  final String result;
  final int goals;
  final int assists;
  final int saves;
  final int interceptions;
  final double? rating;
  final int minutesPlayed;
  final int yellowCards;
  final int redCards;
  final int fouls;

  const PlayerMatchStat({
    this.id,
    required this.matchDate,
    required this.opponent,
    required this.result,
    this.goals = 0,
    this.assists = 0,
    this.saves = 0,
    this.interceptions = 0,
    this.rating,
    this.minutesPlayed = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.fouls = 0,
  });

  @override
  List<Object?> get props => [
        id,
        matchDate,
        opponent,
        result,
        goals,
        assists,
        saves,
        interceptions,
        rating,
        minutesPlayed,
        yellowCards,
        redCards,
        fouls,
      ];
}

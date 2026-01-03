import '../../domain/entities/player_match_stat.dart';

class PlayerMatchStatModel extends PlayerMatchStat {
  const PlayerMatchStatModel({
    String? id,
    required DateTime matchDate,
    required String opponent,
    required String result,
    int goals = 0,
    int assists = 0,
    int saves = 0,
    int interceptions = 0,
    double? rating,
    int minutesPlayed = 0,
    int yellowCards = 0,
    int redCards = 0,
    int fouls = 0,
  }) : super(
          id: id,
          matchDate: matchDate,
          opponent: opponent,
          result: result,
          goals: goals,
          assists: assists,
          saves: saves,
          interceptions: interceptions,
          rating: rating,
          minutesPlayed: minutesPlayed,
          yellowCards: yellowCards,
          redCards: redCards,
          fouls: fouls,
        );

  factory PlayerMatchStatModel.fromJson(Map<String, dynamic> json) {
    return PlayerMatchStatModel(
      id: json['id'] as String?,
      matchDate: DateTime.parse(json['match_date'] as String),
      opponent: json['opponent'] as String,
      result: json['result'] as String,
      goals: json['goals'] as int? ?? 0,
      assists: json['assists'] as int? ?? 0,
      saves: json['saves'] as int? ?? 0,
      interceptions: json['interceptions'] as int? ?? 0,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      minutesPlayed: json['minutes_played'] as int? ?? 0,
      yellowCards: json['yellow_cards'] as int? ?? 0,
      redCards: json['red_cards'] as int? ?? 0,
      fouls: json['fouls'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'match_date': matchDate.toIso8601String(),
      'opponent': opponent,
      'result': result,
      'goals': goals,
      'assists': assists,
      'saves': saves,
      'interceptions': interceptions,
      if (rating != null) 'rating': rating,
      'minutes_played': minutesPlayed,
      'yellow_cards': yellowCards,
      'red_cards': redCards,
      'fouls': fouls,
    };
  }

  factory PlayerMatchStatModel.fromEntity(PlayerMatchStat entity) {
    return PlayerMatchStatModel(
      id: entity.id,
      matchDate: entity.matchDate,
      opponent: entity.opponent,
      result: entity.result,
      goals: entity.goals,
      assists: entity.assists,
      saves: entity.saves,
      interceptions: entity.interceptions,
      rating: entity.rating,
      minutesPlayed: entity.minutesPlayed,
      yellowCards: entity.yellowCards,
      redCards: entity.redCards,
      fouls: entity.fouls,
    );
  }
}

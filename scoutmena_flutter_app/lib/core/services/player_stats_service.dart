import 'package:injectable/injectable.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

@lazySingleton
class PlayerStatsService {
  final ApiClient _apiClient;

  PlayerStatsService(this._apiClient);

  /// Get player statistics
  /// Backend endpoint: GET /api/v1/player/profile/stats
  Future<List<PlayerStatsResponse>> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.playerProfileStats);
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => PlayerStatsResponse.fromJson(e)).toList();
      } else {
        // Handle case where it might return a single object or empty
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  /// Create player statistics
  /// Backend endpoint: POST /api/v1/player/profile/stats
  Future<PlayerStatsResponse> createStats({
    required String season,
    required String level,
    required int goals,
    required int assists,
    required int appearances,
    required int starts,
    required int minutesPlayed,
    int? yellowCards,
    int? redCards,
  }) async {
    try {
      final data = {
        'season': season,
        'level': level,
        'goals': goals,
        'assists': assists,
        'appearances': appearances,
        'starts': starts,
        'minutes_played': minutesPlayed,
        if (yellowCards != null) 'yellow_cards': yellowCards,
        if (redCards != null) 'red_cards': redCards,
      };

      final response = await _apiClient.post(
        ApiConstants.playerProfileStats,
        data: data,
      );

      return PlayerStatsResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create stats: $e');
    }
  }

  /// Update player statistics
  /// Backend endpoint: PUT /api/v1/player/profile/stats/{id}
  Future<PlayerStatsResponse> updateStats({
    required String id,
    required String season,
    required String level,
    required int goals,
    required int assists,
    required int appearances,
    required int starts,
    required int minutesPlayed,
    int? yellowCards,
    int? redCards,
  }) async {
    try {
      final data = {
        'season': season,
        'level': level,
        'goals': goals,
        'assists': assists,
        'appearances': appearances,
        'starts': starts,
        'minutes_played': minutesPlayed,
        if (yellowCards != null) 'yellow_cards': yellowCards,
        if (redCards != null) 'red_cards': redCards,
      };

      final response = await _apiClient.put(
        '${ApiConstants.playerProfileStats}/$id',
        data: data,
      );

      return PlayerStatsResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update stats: $e');
    }
  }
}

// Response Model
class PlayerStatsResponse {
  final String id;
  final String season;
  final String level;
  final int goals;
  final int assists;
  final int appearances;
  final int starts;
  final int minutesPlayed;
  final int? yellowCards;
  final int? redCards;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlayerStatsResponse({
    required this.id,
    required this.season,
    required this.level,
    required this.goals,
    required this.assists,
    required this.appearances,
    required this.starts,
    required this.minutesPlayed,
    this.yellowCards,
    this.redCards,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlayerStatsResponse.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return PlayerStatsResponse(
      id: json['id'].toString(),
      season: json['season'] as String,
      level: json['level'] as String,
      goals: parseInt(json['goals']),
      assists: parseInt(json['assists']),
      appearances: parseInt(json['appearances']),
      starts: parseInt(json['starts']),
      minutesPlayed: parseInt(json['minutes_played']),
      yellowCards: parseNullableInt(json['yellow_cards']),
      redCards: parseNullableInt(json['red_cards']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

import 'package:injectable/injectable.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

@lazySingleton
class ScoutService {
  final ApiClient _apiClient;

  ScoutService(this._apiClient);

  /// Search for players with filters
  /// Backend endpoint: GET /api/v1/scout/players/search
  Future<PlayerSearchResponse> searchPlayers({
    String? query,
    String? position,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? country,
    int? heightMin,
    int? heightMax,
    String? preferredFoot,
    String? currentClub,
    int? page,
    int? perPage,
    String? endpoint,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (position != null && position.isNotEmpty) queryParams['position'] = position;
      if (ageMin != null) queryParams['age_min'] = ageMin;
      if (ageMax != null) queryParams['age_max'] = ageMax;
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
      if (country != null && country.isNotEmpty) queryParams['country'] = country;
      if (heightMin != null) queryParams['height_min'] = heightMin;
      if (heightMax != null) queryParams['height_max'] = heightMax;
      if (preferredFoot != null && preferredFoot.isNotEmpty) queryParams['preferred_foot'] = preferredFoot;
      if (currentClub != null && currentClub.isNotEmpty) queryParams['current_club'] = currentClub;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _apiClient.get(
        endpoint ?? ApiConstants.scoutPlayersSearch,
        queryParameters: queryParams,
      );

      return PlayerSearchResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to search players: $e');
    }
  }

  /// Get saved searches
  /// Backend endpoint: GET /api/v1/scout/saved-searches
  Future<List<SavedSearch>> getSavedSearches() async {
    try {
      final response = await _apiClient.get(ApiConstants.scoutSavedSearches);
      final data = response.data['data'] as List;
      return data.map((item) => SavedSearch.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get saved searches: $e');
    }
  }

  /// Create a saved search
  /// Backend endpoint: POST /api/v1/scout/saved-searches
  Future<SavedSearch> createSavedSearch({
    required String name,
    required Map<String, dynamic> criteria,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.scoutSavedSearches,
        data: {
          'name': name,
          'criteria': criteria,
        },
      );

      return SavedSearch.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create saved search: $e');
    }
  }

  /// Delete a saved search
  /// Backend endpoint: DELETE /api/v1/scout/saved-searches/{id}
  Future<void> deleteSavedSearch(String searchId) async {
    try {
      await _apiClient.delete('${ApiConstants.scoutSavedSearches}/$searchId');
    } catch (e) {
      throw Exception('Failed to delete saved search: $e');
    }
  }

  /// Get player profile details
  /// Backend endpoint: GET /api/v1/scout/players/{id}
  Future<PlayerProfile> getPlayerProfile(String playerId) async {
    try {
      // Note: The endpoint might be different, assuming standard REST
      // If it's not in ApiConstants, I'll use a string literal for now or add it.
      // Based on search endpoint being /api/v1/scout/players/search, 
      // details is likely /api/v1/scout/players/{id}
      final response = await _apiClient.get('/profiles/$playerId');
      return PlayerProfile.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get player profile: $e');
    }
  }

  /// Bookmark a player
  Future<void> bookmarkPlayer(String playerId) async {
    try {
      await _apiClient.post('/scout/bookmarks', data: {'player_id': playerId});
    } catch (e) {
      throw Exception('Failed to bookmark player: $e');
    }
  }

  /// Unbookmark a player
  Future<void> unbookmarkPlayer(String playerId) async {
    try {
      await _apiClient.delete('/scout/bookmarks/$playerId');
    } catch (e) {
      throw Exception('Failed to unbookmark player: $e');
    }
  }

  /// Get bookmarked players
  Future<List<PlayerSearchResult>> getBookmarkedPlayers() async {
    try {
      final response = await _apiClient.get('/scout/bookmarks');
      final data = response.data['data'] as List;
      return data.map((item) => PlayerSearchResult.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get bookmarked players: $e');
    }
  }

  /// Get dashboard stats
  Future<ScoutDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/scout/dashboard/stats');
      return ScoutDashboardStats.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  /// Create a match report
  /// Backend endpoint: POST /api/v1/scout/match-reports
  Future<void> createMatchReport({
    required String tournamentName,
    required String location,
    required DateTime matchDate,
    required String teamA,
    required String teamB,
    required String result,
    String? mvp,
    List<Map<String, String>>? playersToWatch,
    String? notes,
  }) async {
    try {
      await _apiClient.post(
        '/scout/match-reports',
        data: {
          'tournament_name': tournamentName,
          'location': location,
          'match_date': matchDate.toIso8601String(),
          'team_a': teamA,
          'team_b': teamB,
          'result': result,
          'mvp': mvp,
          'players_to_watch': playersToWatch,
          'notes': notes,
        },
      );
    } catch (e) {
      throw Exception('Failed to create match report: $e');
    }
  }

  /// Get recent match reports
  /// Backend endpoint: GET /api/v1/scout/match-reports/recent
  Future<List<MatchReport>> getRecentMatchReports() async {
    try {
      final response = await _apiClient.get('/scout/match-reports/recent');
      final data = response.data['data'] as List;
      return data.map((item) => MatchReport.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get recent match reports: $e');
    }
  }

  /// Send a contact request to a player
  /// Backend endpoint: POST /api/v1/contact-requests
  Future<void> sendContactRequest({
    required String recipientId,
    String? message,
  }) async {
    try {
      await _apiClient.post(
        '/contact-requests',
        data: {
          'recipient_id': recipientId,
          'message': message,
        },
      );
    } catch (e) {
      throw Exception('Failed to send contact request: $e');
    }
  }
}

// Response Models
class ScoutDashboardStats {
  final int playersScouted;
  final int matchesWatched;
  final int newProfiles;

  ScoutDashboardStats({
    required this.playersScouted,
    required this.matchesWatched,
    required this.newProfiles,
  });

  factory ScoutDashboardStats.fromJson(Map<String, dynamic> json) {
    return ScoutDashboardStats(
      playersScouted: json['players_scouted'] as int? ?? 0,
      matchesWatched: json['matches_watched'] as int? ?? 0,
      newProfiles: json['new_profiles'] as int? ?? 0,
    );
  }
}

class PlayerProfile {
  final String id;
  final String name;
  final int age;
  final String primaryPosition;
  final List<String> secondaryPositions;
  final String nationality;
  final String? currentClub;
  final String? bio;
  final int? heightCm;
  final int? weightKg;
  final String? preferredFoot;
  final int completionScore;
  final List<PlayerStat> stats;
  final List<String> photoUrls;
  final List<PlayerVideo> videos;
  final String? profilePhotoUrl;
  final String? heroImageUrl;
  final bool isBookmarked;
  final String? gender;
  
  // New fields
  final String? city;
  final String? country;
  final Map<String, dynamic>? physicalData;
  final Map<String, dynamic>? technicalData;
  final Map<String, dynamic>? tacticalData;
  final Map<String, dynamic>? trainingData;
  final List<Map<String, dynamic>>? careerHistory;
  final List<String>? achievements;
  final String? contactEmail;
  final String? phoneNumber;
  final Map<String, String>? socialLinks;

  PlayerProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.primaryPosition,
    this.secondaryPositions = const [],
    required this.nationality,
    this.currentClub,
    this.bio,
    this.heightCm,
    this.weightKg,
    this.preferredFoot,
    required this.completionScore,
    this.stats = const [],
    this.photoUrls = const [],
    this.videos = const [],
    this.profilePhotoUrl,
    this.heroImageUrl,
    this.isBookmarked = false,
    this.gender,
    this.city,
    this.country,
    this.physicalData,
    this.technicalData,
    this.tacticalData,
    this.trainingData,
    this.careerHistory,
    this.achievements,
    this.contactEmail,
    this.phoneNumber,
    this.socialLinks,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final football = json['football'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;
    final physical = json['physical'] as Map<String, dynamic>?;
    final metrics = json['metrics'] as Map<String, dynamic>?;
    final technical = (json['technical'] ?? json['technical_data']) as Map<String, dynamic>?;
    final tactical = (json['tactical'] ?? json['tactical_data']) as Map<String, dynamic>?;
    final training = json['training'] as Map<String, dynamic>?;
    final contact = json['contact'] as Map<String, dynamic>?;
    
    // Parse photos
    List<String> photos = [];
    String? primaryPhoto = json['profile_photo_url'] as String?; // Check top-level field first
    String? heroImage = json['hero_image_url'] as String?; // Check top-level hero image field
    if (json['photos'] is List) {
      for (var p in (json['photos'] as List)) {
        if (p['urls'] != null) {
          final url = p['urls']['medium'] ?? p['urls']['original'];
          if (url != null) {
            photos.add(url);
            if (primaryPhoto == null && p['is_primary'] == true) primaryPhoto = url;
          }
        }
      }
    }
    if (primaryPhoto == null && photos.isNotEmpty) primaryPhoto = photos.first;

    // Parse videos
    List<PlayerVideo> playerVideos = [];
    if (json['videos'] is List) {
      for (var v in (json['videos'] as List)) {
        if (v is Map<String, dynamic>) {
           playerVideos.add(PlayerVideo.fromJson(v));
        }
      }
    }

    // Parse stats
    List<PlayerStat> playerStats = [];
    if (json['stats'] is List) {
      playerStats = (json['stats'] as List)
          .map((s) => PlayerStat.fromJson(s))
          .toList();
    }

    // Parse secondary positions
    List<String> secPos = [];
    if (football?['secondary_positions'] is List) {
      secPos = (football!['secondary_positions'] as List).map((e) => e.toString()).toList();
    }

    // Parse career history
    List<Map<String, dynamic>>? career;
    if (football?['previous_clubs'] is List) {
      career = (football!['previous_clubs'] as List).map((e) => e as Map<String, dynamic>).toList();
    } else if (json['career_history'] is List) {
      career = (json['career_history'] as List).map((e) => e as Map<String, dynamic>).toList();
    }

    return PlayerProfile(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      primaryPosition: football?['primary_position'] as String? ?? '',
      secondaryPositions: secPos,
      nationality: location?['nationality'] as String? ?? '',
      currentClub: football?['current_club'] as String?,
      bio: json['bio'] as String?,
      heightCm: physical?['height_cm'] as int?,
      weightKg: physical?['weight_kg'] as int?,
      preferredFoot: physical?['preferred_foot'] as String?,
      completionScore: metrics?['completion_score'] as int? ?? 0,
      stats: playerStats,
      photoUrls: photos,
      videos: playerVideos,
      profilePhotoUrl: primaryPhoto,
      heroImageUrl: heroImage,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      gender: json['gender'] as String? ?? physical?['gender'] as String?,
      city: location?['city'] as String?,
      country: location?['country'] as String?,
      physicalData: physical,
      technicalData: technical,
      tacticalData: tactical,
      trainingData: training,
      careerHistory: career,
      achievements: (json['achievements'] as List?)?.map((e) => e.toString()).toList(),
      contactEmail: contact?['email'] as String?,
      phoneNumber: contact?['phone'] as String?,
      socialLinks: (contact?['social_links'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}

class PlayerStat {
  final String season;
  final int appearances;
  final int goals;
  final int assists;
  final int minutesPlayed;

  PlayerStat({
    required this.season,
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.minutesPlayed,
  });

  factory PlayerStat.fromJson(Map<String, dynamic> json) {
    return PlayerStat(
      season: json['season'] as String? ?? 'Unknown',
      appearances: json['appearances'] as int? ?? 0,
      goals: json['goals'] as int? ?? 0,
      assists: json['assists'] as int? ?? 0,
      minutesPlayed: json['minutes_played'] as int? ?? 0,
    );
  }
}

class PlayerSearchResponse {
  final List<PlayerSearchResult> players;
  final int total;
  final int page;
  final int perPage;

  PlayerSearchResponse({
    required this.players,
    required this.total,
    required this.page,
    required this.perPage,
  });

  factory PlayerSearchResponse.fromJson(Map<String, dynamic> json) {
    // Handle standard Laravel pagination response where 'data' is the list
    if (json['data'] is List) {
      final playersData = json['data'] as List;
      final meta = json['meta'] as Map<String, dynamic>?;
      
      return PlayerSearchResponse(
        players: playersData.map((item) => PlayerSearchResult.fromJson(item)).toList(),
        total: meta?['total'] as int? ?? playersData.length,
        page: meta?['current_page'] as int? ?? 1,
        perPage: meta?['per_page'] as int? ?? 20,
      );
    }

    final data = json['data'] as Map<String, dynamic>;
    final playersData = data['players'] as List;
    
    return PlayerSearchResponse(
      players: playersData.map((item) => PlayerSearchResult.fromJson(item)).toList(),
      total: data['total'] as int,
      page: data['page'] as int,
      perPage: data['per_page'] as int,
    );
  }
}

class PlayerSearchResult {
  final String id;
  final String name;
  final int age;
  final String primaryPosition;
  final String nationality;
  final String? city;
  final String? country;
  final String? currentClub;
  final String? profilePhotoUrl;
  final int profileCompletionScore;
  final bool isBookmarked;
  final int? heightCm;
  final String? preferredFoot;
  final String? gender;

  PlayerSearchResult({
    required this.id,
    required this.name,
    required this.age,
    required this.primaryPosition,
    required this.nationality,
    this.city,
    this.country,
    this.currentClub,
    this.profilePhotoUrl,
    required this.profileCompletionScore,
    required this.isBookmarked,
    this.heightCm,
    this.preferredFoot,
    this.gender,
  });

  factory PlayerSearchResult.fromJson(Map<String, dynamic> json) {
    final football = json['football'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;
    final physical = json['physical'] as Map<String, dynamic>?;
    final metrics = json['metrics'] as Map<String, dynamic>?;

    // Extract photo URL
    String? photoUrl = json['profile_photo_url'] as String?;
    if (photoUrl == null && json['photos'] is List && (json['photos'] as List).isNotEmpty) {
      final photos = json['photos'] as List;
      try {
        // Try to find primary photo
        final primary = photos.firstWhere(
          (p) => p['is_primary'] == true,
          orElse: () => photos.first,
        );
        
        if (primary != null && primary['urls'] != null) {
          final urls = primary['urls'];
          photoUrl = urls['medium'] ?? urls['thumb'] ?? urls['original'];
        }
      } catch (_) {
        // Ignore errors parsing photos
      }
    }

    return PlayerSearchResult(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      primaryPosition: football?['primary_position'] as String? ?? '',
      nationality: location?['nationality'] as String? ?? '',
      city: location?['city'] as String?,
      country: location?['country'] as String?,
      currentClub: football?['current_club'] as String?,
      profilePhotoUrl: photoUrl,
      profileCompletionScore: metrics?['completion_score'] as int? ?? 0,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      heightCm: physical?['height_cm'] as int?,
      preferredFoot: physical?['preferred_foot'] as String?,
      gender: json['gender'] as String? ?? physical?['gender'] as String?,
    );
  }
}

class SavedSearch {
  final String id;
  final String name;
  final Map<String, dynamic> criteria;
  final DateTime createdAt;

  SavedSearch({
    required this.id,
    required this.name,
    required this.criteria,
    required this.createdAt,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'].toString(),
      name: json['name'] as String,
      criteria: json['criteria'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class MatchReport {
  final String id;
  final String tournamentName;
  final String location;
  final DateTime matchDate;
  final String teamA;
  final String teamB;
  final String result;
  final String? mvp;
  final List<Map<String, dynamic>>? playersToWatch;
  final String? notes;

  MatchReport({
    required this.id,
    required this.tournamentName,
    required this.location,
    required this.matchDate,
    required this.teamA,
    required this.teamB,
    required this.result,
    this.mvp,
    this.playersToWatch,
    this.notes,
  });

  factory MatchReport.fromJson(Map<String, dynamic> json) {
    return MatchReport(
      id: json['id'].toString(),
      tournamentName: json['tournament_name'] as String,
      location: json['location'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      teamA: json['team_a'] as String,
      teamB: json['team_b'] as String,
      result: json['result'] as String,
      mvp: json['mvp'] as String?,
      playersToWatch: json['players_to_watch'] != null
          ? List<Map<String, dynamic>>.from(json['players_to_watch'])
          : null,
      notes: json['notes'] as String?,
    );
  }
}

class PlayerVideo {
  final String id;
  final String? title;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? status;

  PlayerVideo({
    required this.id,
    this.title,
    this.thumbnailUrl,
    this.videoUrl,
    this.status,
  });

  factory PlayerVideo.fromJson(Map<String, dynamic> json) {
    String? vUrl;
    String? tUrl;

    if (json['urls'] is Map) {
      final urls = json['urls'];
      vUrl = urls['playback'] ?? urls['720p'] ?? urls['480p'] ?? urls['original'];
      tUrl = urls['thumbnail'];
    }
    
    // Fallback if url is directly in the object (legacy or different format)
    if (vUrl == null && json['url'] is String) {
        vUrl = json['url'];
    }

    return PlayerVideo(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      thumbnailUrl: tUrl,
      videoUrl: vUrl,
      status: json['processing_status'] as String?,
    );
  }
}

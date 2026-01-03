import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../../domain/entities/career_entry.dart';
import '../../domain/repositories/player_profile_repository.dart';
import '../models/player_profile_model.dart';

import '../../domain/entities/academy_entity.dart';
import '../models/academy_model.dart';

/// Implementation of PlayerProfileRepository
/// Handles API communication for player profile operations
@LazySingleton(as: PlayerProfileRepository)
class PlayerProfileRepositoryImpl implements PlayerProfileRepository {
  final ApiClient apiClient;

  PlayerProfileRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<AcademyEntity>>> getAcademies() async {
    try {
      final response = await apiClient.get('/academies');
      
      if (response.data['success'] == true) {
        final academiesData = response.data['data'] as List<dynamic>;
        final academies = academiesData
            .map((json) => AcademyModel.fromJson(json))
            .toList();
        return Right(academies);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to get academies',
        ));
      }
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerProfileEntity>> getProfile() async {
    try {
      final response = await apiClient.get('/player/profile');
      
      if (response.data['success'] == true) {
        final profileData = response.data['data'];
        final model = PlayerProfileModel.fromJson(profileData);
        return Right(model.toEntity());
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to get profile',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerProfileEntity>> createProfile({
    required String firstName,
    required String lastName,
    String? nationality,
    String? city,
    required String country,
    String? gender,
    int? heightCm,
    int? weightKg,
    String? preferredFoot,
    required String primaryPosition,
    List<String>? secondaryPositions,
    String? currentClub,
    String? academyId,
    String? academyName,
    int? jerseyNumber,
    DateTime? careerStartDate,
    String? bio,
    List<String>? achievements,
    String? agentName,
    String? agentEmail,
    required String contactEmail,
    String? phoneNumber,
    Map<String, String>? socialLinks,
    required String privacyLevel,
  }) async {
    try {
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        if (nationality != null) 'nationality': nationality,
        if (city != null) 'city': city,
        'country': country,
        if (gender != null) 'gender': gender,
        if (heightCm != null) 'height_cm': heightCm,
        if (weightKg != null) 'weight_kg': weightKg,
        if (preferredFoot != null) 'preferred_foot': preferredFoot,
        'primary_position': primaryPosition,
        if (secondaryPositions != null) 'secondary_positions': secondaryPositions,
        if (currentClub != null) 'current_club': currentClub,
        if (academyId != null) 'academy_id': academyId,
        if (academyName != null) 'academy_name': academyName,
        if (jerseyNumber != null) 'jersey_number': jerseyNumber,
        if (careerStartDate != null) 'career_start_date': careerStartDate.toIso8601String(),
        if (bio != null) 'bio': bio,
        if (achievements != null) 'achievements': achievements,
        if (agentName != null) 'agent_name': agentName,
        if (agentEmail != null) 'agent_email': agentEmail,
        'contact_email': contactEmail,
        if (phoneNumber != null) 'contact_phone': phoneNumber,
        if (socialLinks != null) 'social_links': socialLinks,
        'privacy_level': privacyLevel,
      };

      final response = await apiClient.post('/player/profile', data: data);
      
      if (response.data['success'] == true) {
        final profileData = response.data['data'];
        final model = PlayerProfileModel.fromJson(profileData);
        return Right(model.toEntity());
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to create profile',
        ));
      }
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerProfileEntity>> updateProfile({
    required String profileId,
    String? firstName,
    String? lastName,
    String? nationality,
    String? city,
    String? country,
    String? gender,
    int? heightCm,
    int? weightKg,
    String? preferredFoot,
    String? primaryPosition,
    List<String>? secondaryPositions,
    String? currentClub,
    String? academyId,
    String? academyName,
    List<CareerEntry>? careerHistory,
    int? jerseyNumber,
    DateTime? careerStartDate,
    String? bio,
    List<String>? achievements,
    Map<String, dynamic>? trainingData,
    Map<String, dynamic>? technicalData,
    Map<String, dynamic>? tacticalData,
    Map<String, dynamic>? physicalData,
    String? agentName,
    String? agentEmail,
    String? contactEmail,
    String? phoneNumber,
    Map<String, String>? socialLinks,
    String? privacyLevel,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (nationality != null) data['nationality'] = nationality;
      if (city != null) data['city'] = city;
      if (country != null) data['country'] = country;
      if (gender != null) data['gender'] = gender;
      if (heightCm != null) data['height_cm'] = heightCm;
      if (weightKg != null) data['weight_kg'] = weightKg;
      if (preferredFoot != null) data['preferred_foot'] = preferredFoot;
      if (primaryPosition != null) data['primary_position'] = primaryPosition;
      if (secondaryPositions != null) data['secondary_positions'] = secondaryPositions;
      if (currentClub != null) data['current_club'] = currentClub;
      if (academyId != null) data['academy_id'] = academyId;
      if (academyName != null) data['academy_name'] = academyName;
      if (careerHistory != null) data['previous_clubs'] = careerHistory.map((e) => e.toJson()).toList();
      if (jerseyNumber != null) data['jersey_number'] = jerseyNumber;
      if (careerStartDate != null) data['career_start_date'] = careerStartDate.toIso8601String();
      if (bio != null) data['bio'] = bio;
      if (achievements != null) data['achievements'] = achievements;
      if (trainingData != null) data['training_data'] = trainingData;
      if (technicalData != null) data['technical_data'] = technicalData;
      if (tacticalData != null) data['tactical_data'] = tacticalData;
      if (physicalData != null) data['physical_data'] = physicalData;
      if (agentName != null) data['agent_name'] = agentName;
      if (agentEmail != null) data['agent_email'] = agentEmail;
      if (contactEmail != null) data['contact_email'] = contactEmail;
      if (phoneNumber != null) data['contact_phone'] = phoneNumber;
      if (socialLinks != null) data['social_links'] = socialLinks;
      if (privacyLevel != null) data['privacy_level'] = privacyLevel;

      final response = await apiClient.put('/player/profile', data: data);
      
      if (response.data['success'] == true) {
        final profileData = response.data['data'];
        final model = PlayerProfileModel.fromJson(profileData);
        return Right(model.toEntity());
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to update profile',
        ));
      }
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
      });

      final response = await apiClient.upload('/player/profile/photo', formData);
      
      if (response.data['success'] == true || response.statusCode == 200 || response.statusCode == 201) {
        // Handle both response structures (with or without 'data' wrapper if needed)
        final data = response.data['data'] ?? response.data;
        final photoUrl = data['photo_url'] as String? ?? data['url'] as String?;
        
        if (photoUrl != null) {
          return Right(photoUrl);
        } else {
           // Fallback if we can't find the URL, but upload was successful. 
           // Ideally we should return the URL. If not found, maybe return empty string or fetch profile?
           // For now, let's try to find it in the resource structure
           if (data['urls'] != null && data['urls']['original'] != null) {
             return Right(data['urls']['original']);
           }
           return Left(ServerFailure('Photo URL not found in response'));
        }
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to upload photo',
        ));
      }
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePhoto() async {
    try {
      final response = await apiClient.delete('/player/profile/photo');
      
      if (response.data['success'] == true || response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to delete photo',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadGalleryPhoto({
    required File photo,
    bool isHero = false,
    String? caption,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
        if (caption != null) 'caption': caption,
      });

      // Use different endpoint for Hero Image
      final endpoint = isHero ? '/player/profile/hero-image' : '/player/profile/photos';

      final response = await apiClient.upload(endpoint, formData);
      
      if (response.data['success'] == true || response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        String? photoUrl = data['photo_url'] as String?;
        
        if (photoUrl == null && data['urls'] != null) {
           photoUrl = data['urls']['original'] as String?;
        }
        
        if (photoUrl != null) {
          return Right(photoUrl);
        }
        return Left(ServerFailure('Photo URL not found in response'));
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to upload photo',
        ));
      }
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHeroImage() async {
    try {
      final response = await apiClient.delete('/player/profile/hero-image');
      
      if (response.data['success'] == true || response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to delete hero image',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getGalleryPhotos() async {
    try {
      final response = await apiClient.get('/player/profile/photos');
      
      if (response.data['success'] == true || response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        final photos = data.map((e) {
          if (e is String) return e;
          if (e is Map && e['urls'] != null) return e['urls']['original'] as String;
          if (e is Map && e['url'] != null) return e['url'] as String;
          return '';
        }).where((e) => e.isNotEmpty).toList();
        return Right(photos);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to get gallery photos',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGalleryPhoto(String photoId) async {
    try {
      final response = await apiClient.delete('/player/profile/photos/$photoId');
      
      if (response.data['success'] == true || response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to delete photo',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVideo(String videoId) async {
    try {
      final response = await apiClient.delete('/player/profile/videos/$videoId');
      
      if (response.data['success'] == true || response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to delete video',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePrivacySettings({
    required String privacyLevel,
  }) async {
    try {
      final response = await apiClient.put(
        '/player/profile/privacy',
        data: {'privacy_level': privacyLevel},
      );
      
      if (response.data['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to update privacy',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics() async {
    try {
      final response = await apiClient.get('/player/profile/analytics');
      
      if (response.data['success'] == true) {
        return Right(response.data['data']);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to get analytics',
        ));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}

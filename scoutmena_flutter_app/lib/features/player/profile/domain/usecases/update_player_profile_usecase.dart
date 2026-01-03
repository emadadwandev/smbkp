import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_profile_entity.dart';
import '../entities/career_entry.dart';
import '../repositories/player_profile_repository.dart';

/// Use case for updating player profile
@injectable
class UpdatePlayerProfileUseCase {
  final PlayerProfileRepository repository;

  UpdatePlayerProfileUseCase(this.repository);

  Future<Either<Failure, PlayerProfileEntity>> call({
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
    // Validation (only validate provided fields)
    if (firstName != null && firstName.trim().isEmpty) {
      return Left(ValidationFailure('First name cannot be empty'));
    }
    if (lastName != null && lastName.trim().isEmpty) {
      return Left(ValidationFailure('Last name cannot be empty'));
    }
    if (country != null && country.trim().isEmpty) {
      return Left(ValidationFailure('Country cannot be empty'));
    }
    
    // Validate position if provided
    if (primaryPosition != null) {
      const validPositions = [
        'goalkeeper',
        'center_back',
        'right_back',
        'left_back',
        'defensive_midfielder',
        'central_midfielder',
        'attacking_midfielder',
        'right_winger',
        'left_winger',
        'striker',
        'second_striker'
      ];
      
      if (!validPositions.contains(primaryPosition)) {
        return Left(ValidationFailure('Invalid primary position'));
      }
    }
    
    // Validate preferred foot if provided
    if (preferredFoot != null) {
      const validFeet = ['left', 'right', 'both'];
      if (!validFeet.contains(preferredFoot)) {
        return Left(ValidationFailure('Invalid preferred foot'));
      }
    }
    
    // Validate privacy level if provided
    if (privacyLevel != null) {
      const validPrivacyLevels = ['public', 'scouts_only', 'private'];
      if (!validPrivacyLevels.contains(privacyLevel)) {
        return Left(ValidationFailure('Invalid privacy level'));
      }
    }

    // Validate gender if provided
    if (gender != null) {
      const validGenders = ['male', 'female'];
      if (!validGenders.contains(gender)) {
        return Left(ValidationFailure('Invalid gender'));
      }
    }
    
    // Validate bio length if provided
    if (bio != null && bio.length > 500) {
      return Left(ValidationFailure('Bio must be 500 characters or less'));
    }
    
    // Validate email format if provided
    if (contactEmail != null) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(contactEmail)) {
        return Left(ValidationFailure('Invalid email format'));
      }
    }
    
    if (agentEmail != null && agentEmail.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(agentEmail)) {
        return Left(ValidationFailure('Invalid agent email format'));
      }
    }
    
    // Validate height and weight ranges if provided
    if (heightCm != null && (heightCm < 100 || heightCm > 250)) {
      return Left(ValidationFailure('Height must be between 100-250 cm'));
    }
    
    if (weightKg != null && (weightKg < 30 || weightKg > 200)) {
      return Left(ValidationFailure('Weight must be between 30-200 kg'));
    }
    
    // Validate jersey number if provided
    if (jerseyNumber != null && (jerseyNumber < 1 || jerseyNumber > 99)) {
      return Left(ValidationFailure('Jersey number must be between 1-99'));
    }
    
    return await repository.updateProfile(
      profileId: profileId,
      firstName: firstName,
      lastName: lastName,
      nationality: nationality,
      city: city,
      country: country,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      preferredFoot: preferredFoot,
      primaryPosition: primaryPosition,
      secondaryPositions: secondaryPositions,
      currentClub: currentClub,
      academyId: academyId,
      academyName: academyName,
      careerHistory: careerHistory,
      jerseyNumber: jerseyNumber,
      careerStartDate: careerStartDate,
      bio: bio,
      achievements: achievements,
      trainingData: trainingData,
      technicalData: technicalData,
      tacticalData: tacticalData,
      physicalData: physicalData,
      agentName: agentName,
      agentEmail: agentEmail,
      contactEmail: contactEmail,
      phoneNumber: phoneNumber,
      socialLinks: socialLinks,
      privacyLevel: privacyLevel,
    );
  }
}

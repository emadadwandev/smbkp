import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_profile_entity.dart';
import '../repositories/player_profile_repository.dart';

/// Use case for creating a player profile
@injectable
class CreatePlayerProfileUseCase {
  final PlayerProfileRepository repository;

  CreatePlayerProfileUseCase(this.repository);

  Future<Either<Failure, PlayerProfileEntity>> call({
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
    // Validation
    if (firstName.trim().isEmpty) {
      return Left(ValidationFailure('First name is required'));
    }
    if (lastName.trim().isEmpty) {
      return Left(ValidationFailure('Last name is required'));
    }
    if (country.trim().isEmpty) {
      return Left(ValidationFailure('Country is required'));
    }
    
    // Validate primary position
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
    
    // Validate secondary positions (max 3)
    if (secondaryPositions != null && secondaryPositions.length > 3) {
      return Left(ValidationFailure('Maximum 3 secondary positions allowed'));
    }
    
    // Validate secondary positions are valid and different from primary
    if (secondaryPositions != null) {
      for (final position in secondaryPositions) {
        if (!validPositions.contains(position)) {
          return Left(ValidationFailure('Invalid secondary position: $position'));
        }
        if (position == primaryPosition) {
          return Left(ValidationFailure('Secondary position cannot be same as primary'));
        }
      }
    }
    
    // Validate preferred foot
    if (preferredFoot != null) {
      const validFeet = ['left', 'right', 'both'];
      if (!validFeet.contains(preferredFoot)) {
        return Left(ValidationFailure('Invalid preferred foot'));
      }
    }
    
    // Validate privacy level
    const validPrivacyLevels = ['public', 'scouts_only', 'private'];
    if (!validPrivacyLevels.contains(privacyLevel)) {
      return Left(ValidationFailure('Invalid privacy level'));
    }
    
    // Validate bio length (max 500 characters)
    if (bio != null && bio.length > 500) {
      return Left(ValidationFailure('Bio must be 500 characters or less'));
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(contactEmail)) {
      return Left(ValidationFailure('Invalid email format'));
    }
    
    if (agentEmail != null && agentEmail.isNotEmpty && !emailRegex.hasMatch(agentEmail)) {
      return Left(ValidationFailure('Invalid agent email format'));
    }
    
    // Validate height and weight ranges
    if (heightCm != null && (heightCm < 100 || heightCm > 250)) {
      return Left(ValidationFailure('Height must be between 100-250 cm'));
    }
    
    if (weightKg != null && (weightKg < 30 || weightKg > 200)) {
      return Left(ValidationFailure('Weight must be between 30-200 kg'));
    }
    
    // Validate jersey number
    if (jerseyNumber != null && (jerseyNumber < 1 || jerseyNumber > 99)) {
      return Left(ValidationFailure('Jersey number must be between 1-99'));
    }
    
    return await repository.createProfile(
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
      jerseyNumber: jerseyNumber,
      careerStartDate: careerStartDate,
      bio: bio,
      achievements: achievements,
      agentName: agentName,
      agentEmail: agentEmail,
      contactEmail: contactEmail,
      phoneNumber: phoneNumber,
      socialLinks: socialLinks,
      privacyLevel: privacyLevel,
    );
  }
}

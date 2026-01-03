import 'package:injectable/injectable.dart';
import '../entities/coach_profile_entity.dart';
import '../repositories/coach_profile_repository.dart';

/// Use case: Get coach profile
/// Retrieves the current coach's profile from the repository
@injectable
class GetCoachProfile {
  final CoachProfileRepository repository;

  GetCoachProfile(this.repository);

  /// Execute the use case
  /// Returns coach profile entity or null if not found
  Future<CoachProfileEntity?> call() async {
    try {
      return await repository.getProfile();
    } catch (e) {
      throw Exception('Failed to get coach profile: $e');
    }
  }
}

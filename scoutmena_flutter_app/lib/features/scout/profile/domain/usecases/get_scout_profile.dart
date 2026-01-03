import 'package:injectable/injectable.dart';
import '../entities/scout_profile_entity.dart';
import '../repositories/scout_profile_repository.dart';

/// Use case: Get scout profile
/// Retrieves the current scout's profile from the repository
@injectable
class GetScoutProfile {
  final ScoutProfileRepository repository;

  GetScoutProfile(this.repository);

  /// Execute the use case
  /// Returns scout profile entity or null if not found
  Future<ScoutProfileEntity?> call() async {
    try {
      return await repository.getProfile();
    } catch (e) {
      // Log error and rethrow
      throw Exception('Failed to get scout profile: $e');
    }
  }
}

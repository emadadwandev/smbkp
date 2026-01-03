import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_profile_entity.dart';
import '../repositories/player_profile_repository.dart';

/// Use case for getting player profile
@injectable
class GetPlayerProfileUseCase {
  final PlayerProfileRepository repository;

  GetPlayerProfileUseCase(this.repository);

  Future<Either<Failure, PlayerProfileEntity>> call() async {
    return await repository.getProfile();
  }
}

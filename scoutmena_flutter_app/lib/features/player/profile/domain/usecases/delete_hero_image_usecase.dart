import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class DeleteHeroImageUseCase {
  final PlayerProfileRepository repository;

  DeleteHeroImageUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.deleteHeroImage();
  }
}

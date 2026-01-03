import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class DeleteProfilePhotoUseCase {
  final PlayerProfileRepository repository;

  DeleteProfilePhotoUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.deleteProfilePhoto();
  }
}

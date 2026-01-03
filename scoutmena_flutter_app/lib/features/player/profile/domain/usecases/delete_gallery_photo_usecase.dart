import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class DeleteGalleryPhotoUseCase {
  final PlayerProfileRepository repository;

  DeleteGalleryPhotoUseCase(this.repository);

  Future<Either<Failure, void>> call(String photoId) async {
    return await repository.deleteGalleryPhoto(photoId);
  }
}

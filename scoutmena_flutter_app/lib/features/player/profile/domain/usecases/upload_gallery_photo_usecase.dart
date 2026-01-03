import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/player_profile_repository.dart';

/// Use case for uploading gallery photo
@injectable
class UploadGalleryPhotoUseCase {
  final PlayerProfileRepository repository;

  UploadGalleryPhotoUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File photo,
    bool isHero = false,
    String? caption,
  }) async {
    // Validation
    if (!await photo.exists()) {
      return Left(ValidationFailure('Photo file does not exist'));
    }
    
    // Check file size (max 5MB)
    final fileSize = await photo.length();
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    
    if (fileSize > maxSize) {
      return Left(ValidationFailure('Photo size must be less than 5MB'));
    }
    
    // Check file extension
    final extension = photo.path.split('.').last.toLowerCase();
    const validExtensions = ['jpg', 'jpeg', 'png'];
    
    if (!validExtensions.contains(extension)) {
      return Left(ValidationFailure('Invalid file format. Use JPG, JPEG, or PNG'));
    }
    
    // Validate caption length
    if (caption != null && caption.length > 200) {
      return Left(ValidationFailure('Caption must be 200 characters or less'));
    }
    
    return await repository.uploadGalleryPhoto(
      photo: photo,
      isHero: isHero,
      caption: caption,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class DeleteVideoUseCase {
  final PlayerProfileRepository repository;

  DeleteVideoUseCase(this.repository);

  Future<Either<Failure, void>> call(String videoId) async {
    return await repository.deleteVideo(videoId);
  }
}

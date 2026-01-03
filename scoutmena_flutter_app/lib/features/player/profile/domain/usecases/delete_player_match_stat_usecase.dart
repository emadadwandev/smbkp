import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/player_match_repository.dart';

@injectable
class DeletePlayerMatchStatUseCase {
  final PlayerMatchRepository repository;

  DeletePlayerMatchStatUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteMatchStat(id);
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_match_stat.dart';
import '../repositories/player_match_repository.dart';

@injectable
class UpdatePlayerMatchStatUseCase {
  final PlayerMatchRepository repository;

  UpdatePlayerMatchStatUseCase(this.repository);

  Future<Either<Failure, PlayerMatchStat>> call(PlayerMatchStat stat) async {
    return await repository.updateMatchStat(stat);
  }
}

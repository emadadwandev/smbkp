import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_match_stat.dart';
import '../repositories/player_match_repository.dart';

@injectable
class AddPlayerMatchStatUseCase {
  final PlayerMatchRepository repository;

  AddPlayerMatchStatUseCase(this.repository);

  Future<Either<Failure, PlayerMatchStat>> call(PlayerMatchStat stat) async {
    return await repository.addMatchStat(stat);
  }
}

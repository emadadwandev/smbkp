import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_match_stat.dart';
import '../repositories/player_match_repository.dart';

@injectable
class GetPlayerMatchStatsUseCase {
  final PlayerMatchRepository repository;

  GetPlayerMatchStatsUseCase(this.repository);

  Future<Either<Failure, List<PlayerMatchStat>>> call() async {
    return await repository.getMatchStats();
  }
}

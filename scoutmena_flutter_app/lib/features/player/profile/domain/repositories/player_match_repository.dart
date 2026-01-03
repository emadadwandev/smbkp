import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_match_stat.dart';

abstract class PlayerMatchRepository {
  Future<Either<Failure, List<PlayerMatchStat>>> getMatchStats();
  
  Future<Either<Failure, PlayerMatchStat>> addMatchStat(PlayerMatchStat stat);
  
  Future<Either<Failure, PlayerMatchStat>> updateMatchStat(PlayerMatchStat stat);
  
  Future<Either<Failure, void>> deleteMatchStat(String id);
}

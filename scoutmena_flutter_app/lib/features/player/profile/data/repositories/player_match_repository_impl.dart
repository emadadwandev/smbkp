import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/player_match_stat.dart';
import '../../domain/repositories/player_match_repository.dart';
import '../models/player_match_stat_model.dart';

@LazySingleton(as: PlayerMatchRepository)
class PlayerMatchRepositoryImpl implements PlayerMatchRepository {
  final ApiClient apiClient;

  PlayerMatchRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<PlayerMatchStat>>> getMatchStats() async {
    try {
      final response = await apiClient.get('/player/profile/matches');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final stats = data.map((e) => PlayerMatchStatModel.fromJson(e)).toList();
        return Right(stats);
      } else {
        return Left(ServerFailure(response.data['message'] ?? 'Failed to get match stats'));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerMatchStat>> addMatchStat(PlayerMatchStat stat) async {
    try {
      final model = PlayerMatchStatModel.fromEntity(stat);
      final response = await apiClient.post('/player/profile/matches', data: model.toJson());
      
      if (response.data['success'] == true) {
        final newStat = PlayerMatchStatModel.fromJson(response.data['data']);
        return Right(newStat);
      } else {
        return Left(ServerFailure(response.data['message'] ?? 'Failed to add match stat'));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerMatchStat>> updateMatchStat(PlayerMatchStat stat) async {
    try {
      final model = PlayerMatchStatModel.fromEntity(stat);
      final response = await apiClient.put('/player/profile/matches/${stat.id}', data: model.toJson());
      
      if (response.data['success'] == true) {
        final updatedStat = PlayerMatchStatModel.fromJson(response.data['data']);
        return Right(updatedStat);
      } else {
        return Left(ServerFailure(response.data['message'] ?? 'Failed to update match stat'));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMatchStat(String id) async {
    try {
      final response = await apiClient.delete('/player/profile/matches/$id');
      
      if (response.data['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.data['message'] ?? 'Failed to delete match stat'));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/player_profile_repository.dart';

@injectable
class GetPlayerAnalyticsUseCase {
  final PlayerProfileRepository repository;

  GetPlayerAnalyticsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getAnalytics();
  }
}

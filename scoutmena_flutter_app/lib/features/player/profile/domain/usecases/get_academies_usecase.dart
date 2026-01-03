import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../entities/academy_entity.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class GetAcademiesUseCase {
  final PlayerProfileRepository repository;

  GetAcademiesUseCase(this.repository);

  Future<Either<Failure, List<AcademyEntity>>> call() async {
    return await repository.getAcademies();
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
    required String email,
    required String password,
  }) async {
    return await repository.loginWithEmail(
      email: email,
      password: password,
    );
  }
}

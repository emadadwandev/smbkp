import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class SignInWithFirebaseUseCase {
  final AuthRepository repository;

  SignInWithFirebaseUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
    required String firebaseIdToken,
  }) async {
    if (firebaseIdToken.isEmpty) {
      return const Left(ValidationFailure('Firebase ID token is required'));
    }

    return await repository.signInWithFirebase(
      firebaseIdToken: firebaseIdToken,
    );
  }
}

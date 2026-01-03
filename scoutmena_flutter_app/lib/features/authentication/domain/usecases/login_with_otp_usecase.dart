import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginWithOtpUseCase {
  final AuthRepository repository;

  LoginWithOtpUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
    required String phoneNumber,
    required String otpCode,
    required String accountType,
  }) async {
    // Validate inputs
    if (phoneNumber.isEmpty) {
      return const Left(ValidationFailure('Phone number is required'));
    }

    if (otpCode.isEmpty) {
      return const Left(ValidationFailure('OTP code is required'));
    }

    if (otpCode.length != 6) {
      return const Left(ValidationFailure('OTP code must be 6 digits'));
    }

    return await repository.loginWithOtp(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      accountType: accountType,
    );
  }
}

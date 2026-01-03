import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String phoneNumber,
    required String otpCode,
    required String verificationId,
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

    if (verificationId.isEmpty) {
      return const Left(ValidationFailure('Verification ID is required'));
    }

    return await repository.verifyOtp(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      verificationId: verificationId,
    );
  }
}

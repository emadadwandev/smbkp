import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String phoneNumber,
    String method = 'sms',
  }) async {
    // Validate phone number
    if (phoneNumber.isEmpty) {
      return const Left(ValidationFailure('Phone number is required'));
    }

    if (!_isValidPhoneNumber(phoneNumber)) {
      return const Left(ValidationFailure('Invalid phone number format'));
    }

    return await repository.sendOtp(
      phoneNumber: phoneNumber,
      method: method,
    );
  }

  bool _isValidPhoneNumber(String phone) {
    // Basic E.164 format validation
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(phone);
  }
}

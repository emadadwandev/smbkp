import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuthResult extends Equatable {
  final UserEntity user;
  final String? token;
  final String? firebaseToken;
  final bool requiresParentalConsent;
  final String? parentalConsentId;
  final String? parentEmail;

  const AuthResult({
    required this.user,
    this.token,
    this.firebaseToken,
    required this.requiresParentalConsent,
    this.parentalConsentId,
    this.parentEmail,
  });

  @override
  List<Object?> get props => [
        user,
        token,
        firebaseToken,
        requiresParentalConsent,
        parentalConsentId,
        parentEmail,
      ];
}

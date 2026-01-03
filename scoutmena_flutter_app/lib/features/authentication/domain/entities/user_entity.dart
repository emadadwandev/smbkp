import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String accountType; // player, scout, coach, academy
  final bool isMinor;
  final bool requiresParentalConsent;
  final String? dateOfBirth;
  final String? country;
  final bool isActive;
  final bool isVerified; // for scouts/coaches
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.accountType,
    required this.isMinor,
    required this.requiresParentalConsent,
    this.dateOfBirth,
    this.country,
    required this.isActive,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        accountType,
        isMinor,
        requiresParentalConsent,
        dateOfBirth,
        country,
        isActive,
        isVerified,
        createdAt,
        updatedAt,
      ];
}

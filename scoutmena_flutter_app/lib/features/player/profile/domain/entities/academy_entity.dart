import 'package:equatable/equatable.dart';

class AcademyEntity extends Equatable {
  final String id;
  final String name;

  const AcademyEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

import '../../domain/entities/academy_entity.dart';

class AcademyModel extends AcademyEntity {
  const AcademyModel({
    required String id,
    required String name,
  }) : super(id: id, name: name);

  factory AcademyModel.fromJson(Map<String, dynamic> json) {
    return AcademyModel(
      id: json['id'].toString(),
      name: json['academy_name'] as String,
    );
  }
}

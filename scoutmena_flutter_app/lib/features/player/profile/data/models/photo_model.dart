import '../../domain/entities/photo_entity.dart';

class PhotoModel extends PhotoEntity {
  const PhotoModel({
    required String id,
    required String url,
    bool isMain = false,
    bool isHero = false,
  }) : super(
          id: id,
          url: url,
          isMain: isMain,
          isHero: isHero,
        );

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>?;
    final url = urls?['medium'] as String? ?? urls?['original'] as String? ?? '';
    
    return PhotoModel(
      id: json['id'].toString(),
      url: url,
      isMain: json['is_primary'] == true,
      isHero: json['is_hero'] == true, // Assuming is_hero flag exists or inferred
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urls': {'original': url},
      'is_primary': isMain,
      'is_hero': isHero,
    };
  }
}

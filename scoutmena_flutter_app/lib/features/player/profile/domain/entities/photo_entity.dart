import 'package:equatable/equatable.dart';

class PhotoEntity extends Equatable {
  final String id;
  final String url;
  final bool isMain;
  final bool isHero;

  const PhotoEntity({
    required this.id,
    required this.url,
    this.isMain = false,
    this.isHero = false,
  });

  @override
  List<Object?> get props => [id, url, isMain, isHero];
}

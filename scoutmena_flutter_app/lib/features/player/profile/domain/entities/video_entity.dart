import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final String id;
  final String? title;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? status;

  const VideoEntity({
    required this.id,
    this.title,
    this.thumbnailUrl,
    this.videoUrl,
    this.status,
  });

  @override
  List<Object?> get props => [id, title, thumbnailUrl, videoUrl, status];
}

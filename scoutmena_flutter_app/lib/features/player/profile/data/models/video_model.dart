import '../../domain/entities/video_entity.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
    required String id,
    String? title,
    String? thumbnailUrl,
    String? videoUrl,
    String? status,
  }) : super(
          id: id,
          title: title,
          thumbnailUrl: thumbnailUrl,
          videoUrl: videoUrl,
          status: status,
        );

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    String? vUrl;
    String? tUrl;

    if (json['urls'] is Map) {
      final urls = json['urls'];
      vUrl = urls['playback'] ?? urls['720p'] ?? urls['480p'] ?? urls['original'];
      tUrl = urls['thumbnail'];
    }
    
    // Fallback if url is directly in the object
    if (vUrl == null && json['url'] is String) {
        vUrl = json['url'];
    }

    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      thumbnailUrl: tUrl,
      videoUrl: vUrl,
      status: json['processing_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'processing_status': status,
      'urls': {
        'playback': videoUrl,
        'thumbnail': thumbnailUrl,
      },
    };
  }
}

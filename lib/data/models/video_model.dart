class VideoModel {
  final String id;
  final String title;
  final String coverUrl;
  final String videoUrl;
  final String category;
  final String authorAvatar;
  final String authorName;

  VideoModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.videoUrl,
    required this.category,
    required this.authorAvatar,
    required this.authorName,
  });
}

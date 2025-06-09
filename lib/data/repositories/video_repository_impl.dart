import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Video>> getVideos({String category = '推荐'}) async {
    final models = await remoteDataSource.fetchVideos(category: category);
    return models.map((m) => Video(
      id: m.id,
      title: m.title,
      coverUrl: m.coverUrl,
      videoUrl: m.videoUrl,
      category: m.category,
      authorAvatar: m.authorAvatar,
      authorName: m.authorName,
    )).toList();
  }
}

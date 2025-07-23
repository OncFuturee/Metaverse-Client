import '../entities/video.dart';
import '../repositories/video_repository.dart';

class VideoUsecase {
  final VideoRepository repository;

  VideoUsecase(this.repository);

  Future<List<Video>> getVideosWithCategory({String category = '推荐'}) {
    return repository.getVideos(category: category);
  }
}

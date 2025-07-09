import '../entities/video.dart';
import '../repositories/video_repository.dart';

class GetVideos {
  final VideoRepository repository;

  GetVideos(this.repository);

  Future<List<Video>> call({String category = '推荐'}) {
    return repository.getVideos(category: category);
  }
}

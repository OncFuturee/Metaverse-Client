import '../entities/video.dart';

abstract class VideoRepository {
  Future<List<Video>> getVideos({String category});
}

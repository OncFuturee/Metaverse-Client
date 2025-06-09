import '../models/video_model.dart';

class VideoRemoteDataSource {
  Future<List<VideoModel>> fetchVideos({String category = '推荐'}) async {
    await Future.delayed(const Duration(milliseconds: 800)); // 模拟网络延迟
    return List.generate(10, (i) => VideoModel(
      id: '$category-$i',
      title: '$category 视频标题 $i',
      coverUrl: 'https://picsum.photos/seed/$category$i/400/225',
      videoUrl: 'https://www.example.com/video$i.mp4',
      category: category,
      authorAvatar: 'https://i.pravatar.cc/150?img=${i+1}',
      authorName: '作者 $i',
    ));
  }
}

import '../models/video_model.dart';

class VideoRemoteDataSource {
  Future<List<VideoModel>> fetchVideos({String category = '推荐'}) async {
    await Future.delayed(const Duration(milliseconds: 400)); // 模拟网络延迟
    return List.generate(10, (i) => VideoModel(
      id: '$category-$i',
      title: '$category 视频标题 $i',
      coverUrl: 'https://picsum.photos/seed/$category$i/300/225',
      videoUrl: 'https://www.example.com/video$i.mp4',
      category: category,
      authorAvatar: 'https://picsum.photos/seed/$category$i/200/200',
      authorName: '作者 $i',
    ));
  }
}

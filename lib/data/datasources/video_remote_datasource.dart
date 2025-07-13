import 'dart:math';

import '../models/video_model.dart';

class VideoRemoteDataSource {
  Future<List<VideoModel>> fetchVideos({String category = '推荐'}) async {
    await Future.delayed(const Duration(milliseconds: 400)); // 模拟网络延迟
    return List.generate(10, (i) => VideoModel(
      id: '$category-$i',
      title: '$category 视频标题 $i',
      coverUrl: 'https://picsum.photos/300/225?random=${Random().nextInt(1000)}',
      videoUrl: 'https://www.example.com/video${Random().nextInt(1000)}.mp4',
      category: category,
      authorAvatar: 'https://picsum.photos/200/200?random=${Random().nextInt(1000)}',
      authorName: '作者 $i',
    ));
  }
}

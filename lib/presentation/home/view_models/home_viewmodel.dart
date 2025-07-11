import 'package:flutter/material.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/usecases/get_videos.dart';
import '../../../injection.dart';

class HomeViewModel extends ChangeNotifier {
  final GetVideos _getVideos = GetVideos(getIt());

  List<Video> videos = [];
  bool loading = false;
  String currentCategory = '推荐';

  final List<String> categories = ['推荐', '热门', '关注', '娱乐', '科技', '生活'];

  HomeViewModel() {
    fetchVideos();
  }

  Future<void> fetchVideos({String? category}) async {
    loading = true;
    notifyListeners();
    currentCategory = category ?? currentCategory;
    videos = await _getVideos(category: currentCategory);
    loading = false;
    notifyListeners();
  }
}

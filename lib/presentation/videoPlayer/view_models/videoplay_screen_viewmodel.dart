import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Though not directly used for JSON parsing, good to keep for general web operations.

class VideoPlayScreenViewModel extends ChangeNotifier {
  String? _videoUrl; // Use nullable type for initially empty or failed state
  String? _errorMessage;
  bool _isLoading = false;

  String? get videoUrl => _videoUrl;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchVideoUrl(String viewKey) async {
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    _videoUrl = null; // Clear previous video URL
    notifyListeners(); // Notify listeners that loading has started

    final url = Uri.parse(
      'https://cn.pornhub.com/view_video.php?viewkey=$viewKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final htmlContent = response.body;

        debugPrint(htmlContent);

        // 正则表达式匹配包含 "1080P" 字符的 videoUrl
        // 注意：这里我们匹配的是整个包含 videoUrl 的 JSON 片段
        // 然后再从这个片段中提取 videoUrl。
        // 这是为了更精确地匹配包含 "1080P" 的目标 JSON 对象。 查找主页视频的正则：<ul class="[^>]*?videos[^>]*?>[\s\S]*?</ul>
        final regExp = RegExp(
          r'"videoUrl":"(https:\\/\\/.*\\/1080P.*.mp4\\/master.m3u8\?.*)","quality":"1080"}',
        );
        final match = regExp.firstMatch(htmlContent);

        if (match != null && match.groupCount >= 1) {
          String videoUrlWithEscapes = match.group(1)!;
          // 移除 videoUrl 中的反斜杠
          _videoUrl = videoUrlWithEscapes.replaceAll(r'\/', '/');
          print('提取到的 1080P videoUrl: $_videoUrl');
        } else {
          _errorMessage = '未找到匹配的 1080P videoUrl。';
          print(_errorMessage);
        }
      } else {
        _errorMessage = '请求失败，状态码: ${response.statusCode}';
        print(_errorMessage);
      }
    } catch (e) {
      _errorMessage = '发生错误: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading has finished (or an error occurred)
    }
  }
}

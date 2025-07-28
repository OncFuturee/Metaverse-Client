import 'dart:math';
import 'package:http/http.dart' as http; // 导入 http 包，用于网络请求
import 'package:flutter/foundation.dart'; // 导入 foundation 包用于 debugPrint，在调试模式下打印日志

import '../models/video_model.dart'; // 导入 VideoModel 类

class VideoRemoteDataSource {
  final String baseUrl = 'https://cn.abc.com'; // 基础URL，用于视频数据源
  /// 模拟从远程数据源获取视频列表
  /// [category] 参数用于指定视频分类，默认为 '推荐'
  Future<List<VideoModel>> fetchVideos({String category = '推荐'}) async {

    // 调用 fetchAndMatchWebData 方法获取并匹配网页数据
    List<VideoModel> fetchedVideos = await fetchAndMatchWebData(baseUrl);

    // 如果从网页抓取到数据，则返回抓取到的数据
    if (fetchedVideos.isNotEmpty) {
      return fetchedVideos;
    } else {
      // 如果没有从网页抓取到数据，则生成模拟的视频数据列表作为备用
      debugPrint('未从网页获取到数据，正在生成模拟数据...');
      return List.generate(
        10,
        (i) => VideoModel(
          id: '$category-$i', // 视频ID，由分类和索引组成
          title: '$category 视频标题 $i', // 视频标题
          coverUrl:
              'https://picsum.photos/300/225?random=${Random().nextInt(1000)}', // 视频封面图URL
          videoUrl:
              'https://www.example.com/video${Random().nextInt(1000)}.mp4', // 视频播放URL
          category: category, // 视频分类
          authorAvatar:
              'https://picsum.photos/200/200?random=${Random().nextInt(1000)}', // 作者头像URL
          authorName: '作者 $i', // 作者名称
        ),
      );
    }
  }

  /// 新增方法：获取并匹配网页数据
  /// 该方法会根据提供的URL获取网页内容，并进行两次正则表达式匹配
  /// 第一次匹配：提取所有视频列表项
  /// 第二次匹配：从每个视频列表项中提取视频链接、标题、封面图
  /// 额外匹配作者名称，如果未找到则使用默认值。
  /// 返回一个 VideoModel 列表
  Future<List<VideoModel>> fetchAndMatchWebData(String url) async {
    List<VideoModel> videoList = []; // 用于存储解析到的视频数据
    try {
      // 发起HTTP GET请求获取网页内容
      final response = await http.get(Uri.parse(url));

      // 检查HTTP响应状态码
      if (response.statusCode == 200) {
        // 获取网页的HTML内容
        final htmlContent = response.body;

        // 定义第一次匹配的正则表达式：用于匹配所有 class 包含 "pcVideoListItem" 的 <li> 标签及其内容
        final RegExp firstRegExp = RegExp(
          r'<li class="[^>]*?pcVideoListItem[^>]*?>[\s\S]*?</li>',
        );
        // 执行第一次匹配，获取所有匹配项
        final Iterable<Match> firstMatches = firstRegExp.allMatches(
          htmlContent,
        );

        debugPrint('--- 网页数据第一次匹配结果 ---');
        int firstMatchCount = 0;
        for (final Match m in firstMatches) {
          firstMatchCount++;
          final String listItemHtml = m.group(0)!; // 获取当前视频列表项的HTML内容

          // 定义第二次匹配的正则表达式（不包含作者名称）：
          // 第一个括号：匹配 href 中包含 "/view_video.php?viewkey=" 的 URL (视频链接)
          // 第二个括号：匹配 title 属性的值 (视频标题)
          // 第三个括号：匹配 img 标签的 src 属性的值 (视频封面图URL)
          final RegExp secondRegExp = RegExp(
            r'<a[^>]*?href="([^>]*?/view_video.php\?viewkey=[^"]*?)"[^>]*?title="([^"]*?)"[^>]*?class="[^"]*?img[^"]*?"[^>]*?>[\s\S]*?<img[^>]*?src="([^>]*?)"',
            caseSensitive: false, // 不区分大小写匹配
          );

          // 对第一次匹配到的数据进行第二次匹配
          final Match? secondMatch = secondRegExp.firstMatch(listItemHtml);

          // 定义作者名称的独立正则表达式
          final RegExp authorRegExp = RegExp(
            r'<a[^>]*?href="/model/([^"]*?)"',
            caseSensitive: false,
          );
          final Match? authorMatch = authorRegExp.firstMatch(listItemHtml);
          // 提取作者名称，如果未找到则使用默认值
          final String authorName = authorMatch?.group(1) ?? '未知作者';

          if (secondMatch != null) {
            // 提取视频的相对URL
            final String? relativeVideoUrl = secondMatch.group(1);
            // 拼接完整的视频URL
            final String videoUrl =
                "$baseUrl${relativeVideoUrl ?? ''}";

            // 提取视频标题
            final String? videoTitle = secondMatch.group(2);
            // 提取视频封面图URL
            final String? coverImageUrl = secondMatch.group(3);

            if (relativeVideoUrl != null &&
                videoTitle != null &&
                coverImageUrl != null) {
              // 创建 VideoModel 对象并添加到列表中
              videoList.add(
                VideoModel(
                  id: videoTitle, // 可以使用标题作为ID，或者生成一个唯一的ID
                  title: videoTitle,
                  coverUrl: coverImageUrl,
                  videoUrl: videoUrl,
                  category: '抓取', // 可以设置一个默认分类或者根据内容推断
                  authorAvatar:
                      'https://picsum.photos/200/200?random=${Random().nextInt(1000)}', // 随机生成作者头像
                  authorName: authorName, // 使用独立匹配到的作者名称
                ),
              );
            }

            debugPrint('  二次匹配 - 视频URL: $videoUrl');
            debugPrint('  二次匹配 - 视频标题: $videoTitle');
            debugPrint('  二次匹配 - 封面URL: $coverImageUrl');
            debugPrint('  二次匹配 - 作者名称: $authorName'); // 打印作者名称
          } else {
            debugPrint('  第一次匹配到的数据未找到视频主要信息（视频URL、标题、封面）。');
            debugPrint('  作者名称（独立匹配）：$authorName'); // 即使主要信息缺失，作者名称也尝试打印
          }
        }
        debugPrint('第一次匹配到的条数: $firstMatchCount');
        debugPrint('--- 匹配结果结束 ---');
      } else {
        // 如果请求失败，打印错误状态码
        debugPrint('请求失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      // 捕获并打印获取网页数据时发生的任何错误
      debugPrint('获取网页数据时发生错误: $e');
    }
    return videoList; // 返回解析到的视频列表
  }
}

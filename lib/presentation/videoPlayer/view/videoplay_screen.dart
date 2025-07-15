import 'dart:math';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// 你可能需要在你的 pubspec.yaml 中添加这些依赖：
// dependencies:
//   flutter:
//     sdk: flutter
//   media_kit: ^1.1.10
//   media_kit_video: ^1.2.4
//   media_kit_libs_video: ^1.0.4 # 针对桌面平台和Web，如果你不需要可以不加
//   cupertino_icons: ^1.0.6

// 在你的 main.dart 或应用程序启动文件中的适当位置调用此方法：
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   MediaKit.ensureInitialized(); // 必须初始化 media_kit
//   runApp(const MyApp());
// }
@RoutePage()
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player = Player(
      configuration: const PlayerConfiguration(
      bufferSize: 64 * 1024 * 1024, // 尝试更大的缓冲区，例如 64MB
      protocolWhitelist: [ // 确保包含所有可能需要的协议
        'file', 'http', 'https', 'tcp', 'tls', 'crypto', 'hls', 'applehttp', 'udp', 'rtp', 'data', 'httpproxy'
      ],
    ),
  );
  late final VideoController controller = VideoController(player);

  // 示例视频URL，请替换为你的实际视频URL
  String videoUrl =
      'https://kv-h.phncdn.com/hls/videos/202212/31/422401111/1080P_8000K_422401111.mp4/master.m3u8?hdnea=st=1752603901~exp=1752607501~hdl=-1~hmac=917bc774f572cd1fb075485945c589575bc06c87';

  @override
  void initState() {
    super.initState();
    player.open(Media(videoUrl));
    player.setVolume(100.0); // 默认音量
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 背景色，让视频播放器区域更突出
      body: SafeArea(
        child: Column(
          children: [
            // 顶部：视频播放器和控制
            AspectRatio(
              aspectRatio: 16 / 9, // 常见的视频比例
              child: Stack(
                children: [
                  Video(controller: controller),
                  _buildVideoControlsOverlay(),
                  _buildTopRightMenu(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 中部：视频作者信息、标题、播放量等
                    _buildVideoInfoSection(),
                    const Divider(color: Colors.grey),
                    // 下部：标签分类和推荐视频
                    _buildTagsAndRecommendedVideos(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建视频控制层
  Widget _buildVideoControlsOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          // 在这里可以添加点击视频区域显示/隐藏控制条的逻辑
        },
        child: Container(
          color: Colors.transparent, // 确保手势可以穿透
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StreamBuilder<Duration>(
                stream: player.stream.position,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  return StreamBuilder<bool>(
                    stream: player.stream.playing,
                    builder: (context, playingSnapshot) {
                      final isPlaying = playingSnapshot.data ?? false;
                      final duration = player.state.duration;
                      return Column(
                        children: [
                          // 进度条
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2.0,
                              thumbShape:
                                  const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                              overlayShape:
                                  const RoundSliderOverlayShape(overlayRadius: 12.0),
                            ),
                            child: Slider(
                              min: 0.0,
                              max: duration.inMilliseconds.toDouble(),
                              value: position.inMilliseconds
                                  .clamp(0, duration.inMilliseconds)
                                  .toDouble(),
                              onChanged: (value) {
                                player.seek(Duration(milliseconds: value.toInt()));
                              },
                              activeColor: Colors.red,
                              inactiveColor: Colors.white54,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 播放/暂停按钮
                                IconButton(
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    player.playOrPause();
                                  },
                                ),
                                // 时间显示
                                Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建右上角菜单
  Widget _buildTopRightMenu() {
    return Positioned(
      top: 8,
      right: 8,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onSelected: (value) {
          // 处理菜单选择逻辑
          debugPrint('菜单选择: $value');
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'share',
            child: Text('分享'),
          ),
          const PopupMenuItem<String>(
            value: 'report',
            child: Text('举报'),
          ),
          const PopupMenuItem<String>(
            value: 'settings',
            child: Text('设置'),
          ),
        ],
      ),
    );
  }

  /// 构建视频作者信息、标题等部分
  Widget _buildVideoInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作者信息
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage:
                    NetworkImage('https://picsum.photos/300/225?random=${Random().nextInt(1000)}'), // 替换为作者头像
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '视频作者昵称',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    '粉丝 12.3万 | 视频 56',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // 关注按钮逻辑
                  debugPrint('关注作者');
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('关注'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 视频标题
          const Text(
            '这里是视频的精彩标题，可能很长很吸引人！',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 8),
          // 播放量、弹幕数、发布时间
          Row(
            children: const [
              Text('播放 123.4万',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(width: 16),
              Text('弹幕 5.6万',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(width: 16),
              Text('2025-07-15 发布',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          // 互动按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInteractionButton(Icons.thumb_up_alt_outlined, '1.2万'),
              _buildInteractionButton(Icons.thumb_down_alt_outlined, '不喜欢'),
              _buildInteractionButton(Icons.comment_outlined, '2345'),
              _buildInteractionButton(Icons.share, '分享'),
              _buildInteractionButton(Icons.star_border, '收藏'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建互动按钮
  Widget _buildInteractionButton(IconData icon, String text) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.grey, size: 28),
          onPressed: () {
            debugPrint('$text 按钮点击');
          },
        ),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  /// 构建标签分类和推荐视频部分
  Widget _buildTagsAndRecommendedVideos() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签分类
          Row(
            children: [
              _buildTagButton('竖', true), // 示例：当前选中竖屏
              _buildTagButton('横'),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTagButton('JAZZ'),
                      _buildTagButton('街舞'),
                      _buildTagButton('教程'),
                      _buildTagButton('搞笑'),
                      _buildTagButton('音乐'),
                      _buildTagButton('日常'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '推荐视频',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 10),
          // 推荐视频列表 (这里使用一个简单的ListView作为占位符)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // 禁用内部滚动
            itemCount: 5, // 示例：显示5个推荐视频
            itemBuilder: (context, index) {
              return _buildRecommendedVideoItem(index);
            },
          ),
        ],
      ),
    );
  }

  /// 构建标签按钮
  Widget _buildTagButton(String tag, [bool isSelected = false]) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(tag),
        selected: isSelected,
        selectedColor: Colors.blue.shade700,
        backgroundColor: Colors.grey.shade800,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade300,
        ),
        onSelected: (selected) {
          // 处理标签选择逻辑
          debugPrint('标签点击: $tag, 选中: $selected');
        },
      ),
    );
  }

  /// 构建单个推荐视频项
  Widget _buildRecommendedVideoItem(int index) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 80,
              color: Colors.blueGrey, // 视频缩略图占位符
              child: Center(
                child: Text(
                  '视频 ${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '推荐视频标题 ${index + 1}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '作者名 • 12小时前 • 5.6万次播放',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 格式化时长为 MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
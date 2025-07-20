import 'dart:async'; // 导入 Timer
import 'dart:math';
import 'package:metaverse_client/presentation/videoPlayer/view/widgets/custom_tap_detector.dart';
import 'package:metaverse_client/routes/app_router.dart';

import 'package:auto_route/auto_route.dart'; // Import AutoRouter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

// 导入你的 ViewModel
import '../view_models/videoplay_screen_viewmodel.dart'; // 假设你的 ViewModel 文件在此路径

@RoutePage()
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl; // 视频的初始 URL 或用于获取视频的 key
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final Player _player; // Player 的私有实例
  late final VideoController _videoController; // VideoController 的私有实例

  // 控制条可见性
  bool _showControls = true;
  Timer? _controlsHideTimer;

  // 控制条动画的持续时间
  final Duration _controlsAnimationDuration = const Duration(milliseconds: 30); // Increased duration for smoother fade

  // 视频的宽高，用于判断全屏方向
  double? _videoWidth;
  double? _videoHeight;

  @override
  void initState() {
    super.initState();
    _initializePlayerAndController();
    _fetchInitialVideoUrl();
    _startControlsHideTimer(); // 初始化后立即启动计时器

    // 监听视频尺寸变化
    _player.stream.width.listen((width) {
      if (width != null) {
        setState(() {
          _videoWidth = width.toDouble();
        });
      }
    });
    _player.stream.height.listen((height) {
      if (height != null) {
        setState(() {
          _videoHeight = height.toDouble();
        });
      }
    });
  }

  /// 初始化 MediaKit 播放器和视频控制器。
  void _initializePlayerAndController() {
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 64 * 1024 * 1024, // 尝试更大的缓冲区，例如 64MB
        protocolWhitelist: [
          // 确保包含所有可能需要的协议
          'file', 'http', 'https', 'tcp', 'tls',
          'crypto', 'hls', 'applehttp', 'udp',
          'rtp', 'data', 'httpproxy',
        ],
      ),
    );
    _videoController = VideoController(_player);

    // 监听播放器错误
    _player.stream.error.listen((error) {
      debugPrint('MediaKit Player Error: $error');
      // 可以在此处更新 ViewModel 以反映错误状态
    });
  }

  /// 从 ViewModel 获取初始视频 URL。
  void _fetchInitialVideoUrl() {
    // WidgetsBinding.instance.addPostFrameCallback 确保上下文完全可用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<VideoPlayScreenViewModel>(
        context,
        listen: false, // 我们只需要调用方法，不需要立即重建 UI
      );
      viewModel.fetchVideoUrl(widget.videoUrl); // 传入 viewKey
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听 ViewModel 的 videoUrl 变化并相应地更新播放器
    final viewModel = Provider.of<VideoPlayScreenViewModel>(context);
    if (viewModel.videoUrl != null &&
        ((_player.state.playlist.medias.isEmpty
                ? null
                : _player.state.playlist.medias[0].uri) !=
            viewModel.videoUrl)) {
      debugPrint('ViewModel 提供的 videoUrl 已更新: ${viewModel.videoUrl}');
      _player.open(Media(viewModel.videoUrl!), play: false);
      _player.setVolume(100.0); // 默认音量
    }
  }

  /// 启动计时器以在延迟后自动隐藏视频控制条。
  void _startControlsHideTimer() {
    _controlsHideTimer?.cancel(); // 取消任何现有的计时器
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (_showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  /// 切换视频控制条的可见性。
  void _toggleControlsVisibility() {
    debugPrint('切换控制条可见性: 当前状态 $_showControls');
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsHideTimer(); // 显示时重新启动计时器
      } else {
        _controlsHideTimer?.cancel(); // 隐藏时取消计时器
      }
    });
  }

  /// 切换视频播放/暂停状态。
  void _togglePlayPause() {
    _player.playOrPause();
    setState(() {
      _startControlsHideTimer();
    });
  }

  /// 切换全屏模式
  void _toggleFullScreen() {
    debugPrint('全屏按钮被点击！');
    if (_videoWidth != null && _videoHeight != null) {
      final aspectRatio = _videoWidth! / _videoHeight!;
      DeviceOrientation preferredOrientation;

      if (aspectRatio > 1.0) {
        // 宽屏视频，倾向于横屏
        preferredOrientation = DeviceOrientation.landscapeRight;
        debugPrint('检测到宽屏视频，将进入横向全屏');
      } else {
        // 竖屏或方形视频，倾向于竖屏
        preferredOrientation = DeviceOrientation.portraitUp;
        debugPrint('检测到竖屏或方形视频，将进入纵向全屏');
      }

      // 隐藏当前页面的控制条，以免在切换时闪现
      setState(() {
        _showControls = false;
        _controlsHideTimer?.cancel();
      });

      // 导航到全屏播放界面
      AutoRouter.of(context).push(
        VideoPlayerFullRoute(
          player: _player,
          videoUrl:
              _player.state.playlist.medias.isNotEmpty
                  ? _player.state.playlist.medias[0].uri
                  : '',
          preferredOrientation: preferredOrientation,
        ),
      );
    } else {
      debugPrint('视频尺寸信息不可用，无法判断全屏方向。');
      // 如果无法获取视频尺寸，默认进入横屏
      AutoRouter.of(context).push(
        VideoPlayerFullRoute(
          player: _player,
          videoUrl:
              _player.state.playlist.medias.isNotEmpty
                  ? _player.state.playlist.medias[0].uri
                  : '',
          preferredOrientation: DeviceOrientation.landscapeRight, // 默认横屏
        ),
      );
    }
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    _player.dispose(); // 在这里 dispose player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 播放器区域的背景色
      body: SafeArea(
        child: Column(
          children: [
            // 顶部部分：视频播放器区域
            _buildVideoPlayerArea(),
            const Divider(color: Color.fromARGB(100, 158, 158, 158), height: 1,),
            // 作者信息部分
            _buildAuthorInfoSection(),
            const Divider(color: Color.fromARGB(100, 158, 158, 158), height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 视频详情部分（标题、统计数据、互动按钮）
                    _buildVideoDetailsSection(),
                    const Divider(color: Color.fromARGB(100, 158, 158, 158)),
                    // 推荐视频部分
                    _buildRecommendedVideosSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主视频播放器区域，包括视频表面及其控制条。
  Widget _buildVideoPlayerArea() {
    return AspectRatio(
      aspectRatio: 16 / 9, // 常见的视频比例
      child: ClipRect(
        // 添加 ClipRect 来裁切超出边界的内容
        child: Stack(
          children: [
            Consumer<VideoPlayScreenViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (viewModel.errorMessage != null) {
                  return Center(
                    child: Text(
                      '加载视频失败: ${viewModel.errorMessage}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (viewModel.videoUrl != null) {
                  // 视频 URL 已成功加载，显示视频播放器
                  return CustomTapDetector(
                    onSingleTap: _toggleControlsVisibility, // 单击切换控制条
                    onDoubleTap: _togglePlayPause, // 双击播放/暂停
                    doubleTapInterval: Duration(milliseconds: 200), // 可自定义双击间隔
                    child: Video(
                      controller: _videoController,
                      controls:
                          (state) => _buildVideoPlayerControls(
                            player: _player,
                            showControls: _showControls,
                            onSliderChangeStart:
                                () => _controlsHideTimer?.cancel(),
                            onSliderChanged: (_) => _startControlsHideTimer(),
                            onPlayPauseTapped: () {
                              _player.playOrPause();
                              _startControlsHideTimer();
                            },
                            onFullScreenTapped: _toggleFullScreen, // 传入全屏回调
                          ),
                    ),
                  );
                } else {
                  // 初始状态或未加载完成
                  return const Center(
                    child: Text(
                      '正在获取视频URL...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }
              },
            ),
            // 右上角菜单，独立于主视频控制条
            _buildTopRightMenu(),
          ],
        ),
      ),
    );
  }

  /// 构建视频播放器的控制条。
  Widget _buildVideoPlayerControls({
    required Player player,
    required bool showControls,
    required VoidCallback onSliderChangeStart,
    required ValueChanged<double> onSliderChanged,
    required VoidCallback onPlayPauseTapped,
    required VoidCallback onFullScreenTapped,
  }) {
    return IgnorePointer(
      ignoring: !_showControls, // 控制条隐藏时忽略点击事件
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0, // 透明度动画
        duration: _controlsAnimationDuration, // 使用设置的动画时长
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
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6.0,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12.0,
                              ),
                              activeTrackColor: Colors.red,
                              inactiveTrackColor: Colors.white54,
                              thumbColor: Colors.red,
                              overlayColor: Colors.red.withOpacity(0.2),
                            ),
                            child: Slider(
                              min: 0.0,
                              max: duration.inMilliseconds.toDouble(),
                              value:
                                  position.inMilliseconds
                                      .clamp(0, duration.inMilliseconds)
                                      .toDouble(),
                              onChanged: (value) {
                                player.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                                onSliderChanged(value); // 通知父组件重新启动计时器
                              },
                              onChangeStart: (value) {
                                onSliderChangeStart(); // 通知父组件取消计时器
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                  onPressed: onPlayPauseTapped, // 使用回调
                                ),
                                // 时间显示
                                Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(), // 将时间推到左侧，全屏按钮推到右侧
                                // 全屏按钮
                                IconButton(
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: onFullScreenTapped, // 调用全屏回调
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

  /// 将时长格式化为 MM:SS 格式。
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// 构建右上角的菜单按钮（例如，分享、举报、设置）。
  Widget _buildTopRightMenu() {
    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: _controlsAnimationDuration, // 使用设置的动画时长
        child: IgnorePointer(
          ignoring: !_showControls, // 隐藏时忽略点击事件
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              debugPrint('菜单选择: $value');
              _startControlsHideTimer(); // 菜单操作后重新启动计时器
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
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
        ),
      ),
    );
  }

  /// 构建显示作者个人资料和关注按钮的部分。
  Widget _buildAuthorInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://picsum.photos/300/225?random=666}',
            ), // 替换为作者头像
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '视频作者昵称',
                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white,
                ),
              ),
              Text(
                '粉丝 12.3万 | 视频 56',style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('关注作者');
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('关注'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(0, 34), // 将 36 调节到所需高度
            ),
          ),
        ],
      ),
    );
  }

  /// 构建包含视频标题、统计数据和互动按钮的部分。
  Widget _buildVideoDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频标题
          const Text(
            '这里是视频的精彩标题，可能很长很吸引人！',
            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // 播放量、弹幕数、发布时间
          const Row(
            children: [
              Text(
                '播放 123.4万',style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(width: 16),
              Text(
                '弹幕 5.6万',style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(width: 16),
              Text(
                '2025-07-15 发布',style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
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

  /// 辅助方法，用于构建单个互动按钮。
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

  /// 构建推荐视频部分。
  Widget _buildRecommendedVideosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '推荐视频',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

  /// 构建单个推荐视频项。
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
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
}
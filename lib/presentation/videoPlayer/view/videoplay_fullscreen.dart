// lib/screens/videoplay_fullscreen.dart
import 'dart:async';
import 'package:auto_route/auto_route.dart'; // 导入 AutoRouter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于 SystemChrome
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

@RoutePage()
class VideoPlayerFullScreen extends StatefulWidget {
  final Player player; // 传入已有的播放器实例
  final String videoUrl; // 传入当前视频的 URL
  final DeviceOrientation preferredOrientation; // 偏好的全屏方向

  const VideoPlayerFullScreen({
    super.key,
    required this.player,
    required this.videoUrl,
    required this.preferredOrientation,
  });

  @override
  State<VideoPlayerFullScreen> createState() => _VideoPlayerFullScreenState();
}

class _VideoPlayerFullScreenState extends State<VideoPlayerFullScreen> {
  late final Player _player;
  late final VideoController _videoController;

  bool _showControls = true;
  Timer? _controlsHideTimer;

  @override
  void initState() {
    super.initState();
    _player = widget.player; // 使用传入的播放器实例
    _videoController = VideoController(_player);

    _startControlsHideTimer(); // 启动计时器以自动隐藏控制条

    // 设置偏好方向并隐藏系统UI
    SystemChrome.setPreferredOrientations([widget.preferredOrientation]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsHideTimer(); // 重新启动计时器
      } else {
        _controlsHideTimer?.cancel(); // 隐藏时取消计时器
      }
    });
  }

  /// 切换视频播放/暂停状态。
  void _togglePlayPause() {
    _player.playOrPause();
    // 双击后，如果控制条是隐藏的，则显示它们并重新启动计时器
    if (!_showControls) {
      setState(() {
        _showControls = true;
        _startControlsHideTimer();
      });
    }
  }

  /// 退出全屏模式，并恢复屏幕方向和系统UI。
  void _resetOrientationAndUI() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    // 不要在这里释放播放器，因为它来自上一个屏幕。
    // 它应该在原始的 VideoPlayerScreen 中释放。

    // 在dispose时也调用一次，以防万一。
    _resetOrientationAndUI();
    super.dispose();
  }

  // 将时长格式化为 MM:SS 或 HH:MM:SS 格式。
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // 允许导航栏返回手势和按钮正常工作
      onPopInvoked: (didPop) {
        // 当返回事件被触发时调用，无论是否真的弹出。
        // didPop 为 true 表示路由已经被或即将被弹出。
        if (didPop) {
          _resetOrientationAndUI();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControlsVisibility,
          onDoubleTap: _togglePlayPause,
          child: Stack(
            children: [
              Center(
                child: Video(
                  controller: _videoController,
                  controls: (state) => Container(),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 30),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            leading: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // 点击返回按钮时，也触发返回事件，PopScope 会捕获并处理
                                AutoRouter.of(context).pop();
                              },
                            ),
                            title: const Text(
                              '视频全屏播放',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            // 在这里添加退出全屏按钮
                            actions: [
                              IconButton(
                                icon: const Icon(
                                  Icons.fullscreen_exit, // 退出全屏图标
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  AutoRouter.of(context).pop(); // 点击后退出全屏
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                StreamBuilder<Duration>(
                                  stream: _player.stream.position,
                                  builder: (context, positionSnapshot) {
                                    final position =
                                        positionSnapshot.data ?? Duration.zero;
                                    final duration = _player.state.duration;
                                    return SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2.0,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6.0,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 12.0,
                                            ),
                                        activeTrackColor: Colors.red,
                                        inactiveTrackColor: Colors.white54,
                                        thumbColor: Colors.red,
                                        overlayColor: Colors.red.withOpacity(
                                          0.2,
                                        ),
                                      ),
                                      child: Slider(
                                        min: 0.0,
                                        max: duration.inMilliseconds.toDouble(),
                                        value: position.inMilliseconds
                                            .toDouble()
                                            .clamp(
                                              0,
                                              duration.inMilliseconds
                                                  .toDouble(),
                                            ),
                                        onChanged: (value) {
                                          _player.seek(
                                            Duration(
                                              milliseconds: value.toInt(),
                                            ),
                                          );
                                          _startControlsHideTimer();
                                        },
                                        onChangeStart:
                                            (_) => _controlsHideTimer?.cancel(),
                                      ),
                                    );
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: StreamBuilder<bool>(
                                        stream: _player.stream.playing,
                                        builder: (context, snapshot) {
                                          final isPlaying =
                                              snapshot.data ?? false;
                                          return Icon(
                                            isPlaying
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_filled,
                                            color: Colors.white,
                                            size: 36,
                                          );
                                        },
                                      ),
                                      onPressed: () {
                                        _player.playOrPause();
                                        _startControlsHideTimer();
                                      },
                                    ),
                                    StreamBuilder<Duration>(
                                      stream: _player.stream.position,
                                      builder: (context, positionSnapshot) {
                                        final position =
                                            positionSnapshot.data ??
                                            Duration.zero;
                                        final duration = _player.state.duration;
                                        return Text(
                                          '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

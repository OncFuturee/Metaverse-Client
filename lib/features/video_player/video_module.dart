import 'package:flutter/material.dart';
import 'package:metaverse_client/core/registry/feature_registry.dart';

class VideoModule implements FeatureModule {
  @override
  String get name => 'video_player';

  @override
  void init() {
    // 在这里注册视频播放器相关的服务和依赖
    // 比如注册视频播放器服务、事件总线等
    // FeatureRegistry.registerService(VideoPlayerService());
  }

  @override
  List<Route> get routes => [
    // 在这里定义视频播放器相关的路由
    // MaterialPageRoute(builder: (context) => VideoPlayerPage()),
  ];

  @override
  void dispose() {
    // 可选：在模块销毁时执行清理操作
    // 比如取消订阅事件、释放资源等
  }
}
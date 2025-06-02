import 'package:flutter/foundation.dart';
import 'package:metaverse_client/app/app_config.dart';
import 'package:metaverse_client/platform/android/file_service_android.dart';
import 'package:metaverse_client/platform/ios/file_service_ios.dart';
import 'package:metaverse_client/platform/linux/file_service_linux.dart';
import 'package:metaverse_client/platform/windows/file_service_windows.dart';
import '../event_bus/app_event_bus.dart';
import '../utils/network_info.dart';
import './service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metaverse_client/platform/base/file_service.dart';
import 'package:metaverse_client/platform/web/file_service_web.dart';
import 'package:metaverse_client/core/registry/factory_registry.dart';

final sl = ServiceLocator.i;

Future<void> initCore() async {
  // 1. 核心服务
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerSingleton<AppEventBus>(AppEventBus());

  // 2. 外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // 3. 平台服务
  if (kIsWeb) {
    FactoryRegistry.registerFactory<FileService>('web',() => WebFileServiceImpl(),);
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    FactoryRegistry.registerFactory<FileService>('android',() => AndroidFileServiceImpl(),);
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    FactoryRegistry.registerFactory<FileService>('ios',() => IosFileServiceImpl(),);
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    FactoryRegistry.registerFactory<FileService>('windows',() => WindowsFileServiceImpl(),);
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    FactoryRegistry.registerFactory<FileService>('linux',() => LinuxFileServiceImpl(),);
  }

  // 4. 初始化工厂注册表
  initFactories();

  // 5. 初始化事件总线
  initEventBus();

  // 6. 其他基础配置
  await configureAppSettings();
}

// 初始化工厂注册表
void initFactories() {
  // 注册视频播放器工厂
  // FactoryRegistry.registerFactory<VideoPlayer>(
  //   'default',
  //   () => DefaultVideoPlayer(),
  // );
  // FactoryRegistry.registerFactory<VideoPlayer>('hls', () => HLSVideoPlayer());

  // // 注册滤镜工厂
  // FactoryRegistry.registerFactory<VideoFilter>('blur', () => BlurFilter());
  // FactoryRegistry.registerFactory<VideoFilter>('neon', () => NeonFilter());
}

// 初始化事件总线监听
void initEventBus() {
  // 注册全局事件监听
  sl<AppEventBus>().on<NetworkChangedEvent>().listen((event) {
    sl<NetworkInfo>().handleNetworkChange(event.isConnected);
  });
}

// 配置应用设置
Future<void> configureAppSettings() async {
  final appConfig = await AppConfig.fromEnvironment();
  sl.registerSingleton<AppConfig>(appConfig);
}

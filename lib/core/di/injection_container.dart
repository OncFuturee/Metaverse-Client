import 'package:get_it/get_it.dart';
import '../event_bus/app_event_bus.dart';
import '../utils/logger.dart';
import '../utils/network_info.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // 核心服务注册
  getIt.registerSingleton<AppEventBus>(AppEventBus());
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // 注册平台服务
  await _registerPlatformServices();
  
  // 注册功能模块
  await _registerFeatureModules();
}

Future<void> _registerPlatformServices() async {
  // TODO: 根据平台注册相应的服务实现
}

Future<void> _registerFeatureModules() async {
  // TODO: 注册各个功能模块
}

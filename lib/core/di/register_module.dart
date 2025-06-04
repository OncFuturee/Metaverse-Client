
import 'package:metaverse_client/core/di/service_locator.dart';
import 'package:metaverse_client/features/pages/home/home_module.dart';

/// 注册所有功能模块
void registerModule() {
  // 在这里注册所有功能模块
  // 例如：
  // FeatureRegistry.registerModule(UserModule());
  // FeatureRegistry.registerModule(ProductModule());
  
  // 注意：确保在注册模块之前，核心服务已经初始化完成。
  ServiceLocator.registerSingleton(HomeModule());
  
}
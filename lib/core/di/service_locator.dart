import 'package:get_it/get_it.dart';
/// 包装类 抽象出服务定位器的常用操作
/// 方便在项目中统一使用
/// 例如注册单例、懒加载单例等
/// 以及获取服务实例等
/// 如果后续需要替换 GetIt 为其他依赖注入库，只需修改这个包装类，而不必改动整个项目。
class ServiceLocator {
  static final GetIt i = GetIt.instance;
  
  static T get<T extends Object>() => i.get<T>();
  
  static bool isRegistered<T extends Object>() => i.isRegistered<T>();
  
  static void registerSingleton<T extends Object>(T instance) {
    if (!isRegistered<T>()) {
      i.registerSingleton<T>(instance);
    }
  }
  
  static void registerLazySingleton<T extends Object>(
    T Function() factoryFunc,
  ) {
    if (!isRegistered<T>()) {
      i.registerLazySingleton<T>(factoryFunc);
    }
  }
}

import 'package:get_it/get_it.dart';

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

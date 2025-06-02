
class FactoryRegistry {
  /// 存储工厂函数的映射表
  static final Map<Type, Map<String, dynamic>> _factories = {};

  /// 注册工厂函数
  static void registerFactory<T>(String key, T Function() factory) {
    _factories.putIfAbsent(T, () => {});
    _factories[T]![key] = factory;
  }

  /// 根据键获取工厂实例
  static T create<T>(String key) {
    final factoryMap = _factories[T];
    if (factoryMap == null || !factoryMap.containsKey(key)) {
      throw ArgumentError('No factory registered for type $T with key "$key"');
    }
    return factoryMap[key]() as T;
  }

  /// 获取所有注册的键
  static List<String> getKeys<T>() {
    return _factories[T]?.keys.toList() ?? [];
  }

  /// 检查是否已注册特定键
  static bool isRegistered<T>(String key) {
    final factoryMap = _factories[T];
    return factoryMap != null && factoryMap.containsKey(key);
  }
}

import 'dart:async';

/// 缓存服务接口，定义了统一的缓存操作API
abstract class CacheService {
  /// 初始化缓存服务
  Future<void> initialize();
  
  /// 保存字符串值
  Future<void> saveString(String key, String value);
  
  /// 获取字符串值
  Future<String?> getString(String key);
  
  /// 保存布尔值
  Future<void> saveBool(String key, bool value);
  
  /// 获取布尔值
  Future<bool?> getBool(String key);
  
  /// 保存整数值
  Future<void> saveInt(String key, int value);
  
  /// 获取整数值
  Future<int?> getInt(String key);
  
  /// 保存双精度浮点值
  Future<void> saveDouble(String key, double value);
  
  /// 获取双精度浮点值
  Future<double?> getDouble(String key);
  
  /// 保存对象
  Future<void> saveObject(String key, Object? object);
  
  /// 获取对象
  Future<Object?> getObject(String key);
  
  /// 检查缓存中是否存在指定键
  Future<bool> containsKey(String key);
  
  /// 删除指定键的缓存
  Future<void> delete(String key);
  
  /// 清除所有缓存
  Future<void> clear();
  
  /// 关闭缓存服务
  Future<void> close();
}

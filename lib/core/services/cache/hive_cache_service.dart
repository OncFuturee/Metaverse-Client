import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:metaverse_client/core/services/cache/cache_service.dart';

/// 基于Hive的缓存服务实现
class HiveCacheService implements CacheService {
  static const String _kDefaultBoxName = 'app_cache';

  HiveCacheService() {
    initialize();
  }
  
  Box? _box;
  
  @override
  Future<void> initialize() async {
    try {
      // 初始化Hive存储路径
      if (!Hive.isBoxOpen(_kDefaultBoxName)) {
        // 在Web平台上不需要设置存储路径
        if (!kIsWeb) { 
          final appDocumentDir = await getApplicationDocumentsDirectory();
          Hive.init(appDocumentDir.path);
        }
        
        // 打开默认的缓存箱
        _box = await Hive.openBox(_kDefaultBoxName);
      }
    } catch (e) {
      if (kDebugMode) {
        print('缓存初始化失败: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<void> saveString(String key, String value) async {
    await _box?.put(key, value);
  }
  
  @override
  Future<String?> getString(String key) async {
    return _box?.get(key) as String?;
  }
  
  @override
  Future<void> saveBool(String key, bool value) async {
    await _box?.put(key, value);
  }
  
  @override
  Future<bool?> getBool(String key) async {
    return _box?.get(key) as bool?;
  }
  
  @override
  Future<void> saveInt(String key, int value) async {
    await _box?.put(key, value);
  }
  
  @override
  Future<int?> getInt(String key) async {
    return _box?.get(key) as int?;
  }
  
  @override
  Future<void> saveDouble(String key, double value) async {
    await _box?.put(key, value);
  }
  
  @override
  Future<double?> getDouble(String key) async {
    return _box?.get(key) as double?;
  }
  
  @override
  Future<void> saveObject(String key, Object? object) async {
    if (object == null) {
      await _box?.delete(key);
      return;
    }
    
    // 将对象转换为JSON字符串存储
    if (object is Map || object is List) {
      await _box?.put(key, jsonEncode(object));
    } else if (object is String) {
      await _box?.put(key, object);
    } else {
      throw ArgumentError('Unsupported object type: ${object.runtimeType}');
    }
  }
  
  @override
  Future<Object?> getObject(String key) async {
    final value = _box?.get(key);
    if (value == null) return null;
    
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return value;
      }
    }
    
    return value;
  }
  
  @override
  Future<bool> containsKey(String key) async {
    return _box?.containsKey(key) ?? false;
  }
  
  @override
  Future<void> delete(String key) async {
    await _box?.delete(key);
  }
  
  @override
  Future<void> clear() async {
    await _box?.clear();
  }
  
  @override
  Future<void> close() async {
    await _box?.close();
  }
}

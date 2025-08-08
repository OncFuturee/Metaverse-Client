import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // 1. 私有构造函数，防止直接实例化
  AppConfig._privateConstructor();

  // 2. 静态实例，实现单例模式
  static final AppConfig _instance = AppConfig._privateConstructor();

  // 3. 全局访问点
  static AppConfig get instance => _instance;

  // 4. 存储调试参数的Map
  Map<String, dynamic> _params = {"userId":"test","videoUrl":"https://cn.abc.com"};

  // 5. 获取参数的方法
  Map<String, dynamic> get params => _params;

  // 6. 异步加载数据的方法
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('debug_params') ?? json.encode({"userId":"test","videoUrl":"https://cn.abc.com"});
    try {
      _params = json.decode(jsonData) as Map<String, dynamic>;
      if (_params.isEmpty) {
        _params = {"userId":"test","videoUrl":"https://cn.abc.com"};
      }
    } catch (e) {
      _params = {};
      debugPrint('错误解码调试参数: $e');
    }
  }
}

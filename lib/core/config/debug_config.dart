import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DebugConfig {
  // 1. 私有构造函数，防止直接实例化
  DebugConfig._privateConstructor();

  // 2. 静态实例，实现单例模式
  static final DebugConfig _instance = DebugConfig._privateConstructor();

  // 3. 全局访问点
  static DebugConfig get instance => _instance;

  // 4. 存储调试参数的Map
  Map<String, dynamic> _params = {"userId":"test"};

  // 5. 获取参数的方法
  Map<String, dynamic> get params => _params;

  // 6. 异步加载数据的方法
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('debug_params') ?? json.encode({"userId":"test"});
    try {
      _params = json.decode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      _params = {};
      print('Error decoding debug parameters: $e');
    }
  }
}

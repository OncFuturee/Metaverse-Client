import 'package:flutter/material.dart';

abstract class FeatureModule{
  /// 模块名称，用于标识
  String get name;

  /// 初始化模块，注册服务和依赖
  void init();

  /// 模块的UI构建方法
  Widget build(BuildContext context) {
    // 返回一个默认的Widget，实际使用时可以根据需要返回具体的 Widget
    return Text('Module: $name');
  }

  /// 模块提供的路由配置
  Map<String, Widget Function(BuildContext)> get routes;

  /// 可选：模块销毁时的清理操作
  void dispose() {}
}

class FeatureRegistry {
  static final List<FeatureModule> _modules = [];

  static void registerModule(FeatureModule module) {
    _modules.add(module);
    module.init(); // 初始化模块
  }

  static Map<String, Widget Function(BuildContext)> getAllRoutes() {
    return _modules.fold<Map<String, Widget Function(BuildContext)>>(
          {},
          (Map<String, Widget Function(BuildContext)> acc, module) {
            acc.addAll(module.routes);
            return acc;
          },
        );
  }

  static void disposeAll() {
    // 销毁所有模块
    for (var module in _modules) {
      module.dispose();
    }
  }
}

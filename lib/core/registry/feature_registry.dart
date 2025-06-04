import 'package:flutter/material.dart';

abstract class FeatureModule {
  /// 模块名称，用于标识
  String get name;

  /// 初始化模块，注册服务和依赖
  void init();

  /// 模块提供的路由配置
  List<Route> get routes;

  /// 可选：模块销毁时的清理操作
  void dispose() {}
}

class FeatureRegistry {
  static final List<FeatureModule> _modules = [];

  static void registerModule(FeatureModule module) {
    _modules.add(module);
    module.init(); // 初始化模块
  }

  static List<Route> getAllRoutes() {
    return _modules.expand((module) => module.routes).toList();
  }

  static void disposeAll() {
    // 销毁所有模块
    for (var module in _modules) {
      module.dispose();
    }
  }
}

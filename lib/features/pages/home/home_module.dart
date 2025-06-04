import 'package:flutter/material.dart';
import 'package:metaverse_client/core/registry/feature_registry.dart';

class HomeModule implements FeatureModule {
  @override
  String get name => 'home';

  @override
  void init() {
    // 在这里注册首页相关的服务和依赖
    // 比如注册首页服务、事件总线等
    // FeatureRegistry.registerService(HomeService());
  }

  @override
  List<Route> get routes => [
    // 在这里定义首页相关的路由
    // MaterialPageRoute(builder: (context) => HomePage()),
  ];

  @override
  void dispose() {
    // 可选：在模块销毁时执行清理操作
    // 比如取消订阅事件、释放资源等
  }
}
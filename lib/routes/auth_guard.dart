import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class AuthGuard extends AutoRouteGuard {
  final bool isAuthenticated; // 假设这是你的认证状态

  AuthGuard(this.isAuthenticated);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (isAuthenticated) {
      // 如果已认证，允许导航
      resolver.next(true);
    } else {
      // 如果未认证，重定向到登录页（或显示提示）
      // router.replaceAll([LoginRoute()]); // 假设有一个 LoginRoute
      // 或者只是不进行导航并显示一个 SnackBar
      ScaffoldMessenger.of(router.navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('请先登录才能访问此页面！')),
      );
      resolver.next(false); // 阻止导航
    }
  }
}
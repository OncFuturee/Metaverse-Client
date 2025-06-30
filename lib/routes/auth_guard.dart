import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/viewmodels/userinfo_viewmodel.dart';

import 'package:metaverse_client/routes/app_router.dart';
import 'package:provider/provider.dart';

/// AuthGuard 用于保护需要认证的路由
/// 如果用户未认证，则重定向到登录页面或显示提示
class AuthGuard extends AutoRouteGuard {
  bool isAuthenticated; // 假设这是你的认证状态

  AuthGuard(this.isAuthenticated);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final userInfo = Provider.of<UserinfoViewmodel>(router.navigatorKey.currentContext!,listen: false);
    isAuthenticated = userInfo.isLoggedIn;
    if (isAuthenticated) {
      // 如果已认证，允许导航
      resolver.next(true);
    } else {
      // 如果未认证，重定向到登录页
      router.push(LoginRoute()); // 导航到登录页面
      // 或者只是不进行导航并显示一个 SnackBar
      ScaffoldMessenger.of(router.navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('请先登录才能访问此页面！')),
      );
      resolver.next(false); // 阻止导航
    }
  }
}
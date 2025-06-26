// lib/router/app_router.dart
import 'package:auto_route/auto_route.dart';
import 'package:metaverse_client/presentation/screen/search_screen.dart';
import 'package:metaverse_client/routes/auth_guard.dart';

// 导入你的页面
import 'package:metaverse_client/presentation/screen/main_screen.dart';
import 'package:metaverse_client/presentation/pages/profile_page.dart';

part 'app_router.gr.dart'; // 这将被自动生成

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  final AuthGuard authGuard;

  AppRouter({required this.authGuard}); // 构造函数接收守卫实例

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: MainRoute.page, path: '/'),
        AutoRoute(page: SearchRoute.page, path: '/search', guards: [authGuard]), // 使用守卫保护搜索页面
        // AutoRoute(page: ProfileRoute.page, path: '/profile'),
        // AutoRoute(page: SettingsRoute.page, path: '/settings'),
        // AutoRoute(page: PostDetailRoute.page, path: '/posts/:id'), // 带有参数的路由
      ];
}

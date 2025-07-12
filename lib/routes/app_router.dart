// lib/router/app_router.dart
import 'package:auto_route/auto_route.dart';
import 'package:metaverse_client/routes/auth_guard.dart';

// 导入你的页面
import 'package:metaverse_client/presentation/home/view/home_screen.dart';
import 'package:metaverse_client/presentation/auth/login/view/login_screen.dart';
import 'package:metaverse_client/presentation/auth/login/view/register_screen.dart';
import 'package:metaverse_client/presentation/search/view/search_screen.dart';
import 'package:metaverse_client/presentation/home/view/history_screen.dart';
import 'package:metaverse_client/presentation/home/view/favorites_screen.dart';
import 'package:metaverse_client/presentation/home/view/downloads_screen.dart';
import 'package:metaverse_client/presentation/home/view/settings_screen.dart';
import 'package:metaverse_client/presentation/home/view/userinfo_screen.dart';
import 'package:metaverse_client/presentation/home/view/about_screen.dart';

part 'app_router.gr.dart'; // 这将被自动生成

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  final AuthGuard authGuard;

  AppRouter({required this.authGuard}); // 构造函数接收守卫实例

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: MainRoute.page, path: '/'),
        AutoRoute(page: SearchRoute.page, path: '/search', guards: [authGuard]), // 使用守卫保护搜索页面
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: HistoryRoute.page, path: '/history', guards: [authGuard]),
        AutoRoute(page: FavoritesRoute.page, path: '/favorites', guards: [authGuard]),
        AutoRoute(page: DownloadsRoute.page, path: '/downloads', guards: [authGuard]),
        AutoRoute(page: SettingsRoute.page, path: '/settings', guards: [authGuard]),
        AutoRoute(page: UserInfoRoute.page, path: '/user-info/:id', guards: [authGuard]), // 带有参数的路由
        AutoRoute(page: AboutRoute.page, path: '/about'),
        AutoRoute(page: RegisterRoute.page, path: '/register'),
      ];
}

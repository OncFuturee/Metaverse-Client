import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/viewmodels/userinfo_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:metaverse_client/routes/app_router.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserinfoViewmodel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 用户信息区域 ---
            _buildUserInfoSection(context, userInfo),
            const Divider(height: 1, thickness: 8, color: Colors.black12), // 分隔线

            // --- 功能入口列表 ---
            _buildFeatureTile(
              context,
              icon: Icons.history,
              title: '观看历史',
              onTap: () {
                // 示例：跳转到观看历史页面，这里假设不需要登录
                AutoRouter.of(context).push(const HistoryRoute());
              },
            ),
            _buildFeatureTile(
              context,
              icon: Icons.collections_bookmark,
              title: '我的收藏',
              onTap: () {
                _checkLoginAndNavigate(context, userInfo, const FavoritesRoute());
              },
            ),
            _buildFeatureTile(
              context,
              icon: Icons.download,
              title: '我的下载',
              onTap: () {
                _checkLoginAndNavigate(context, userInfo, const DownloadsRoute());
              },
            ),
            const Divider(height: 1, thickness: 8, color: Colors.black12),

            _buildFeatureTile(
              context,
              icon: Icons.settings,
              title: '设置',
              onTap: () {
                AutoRouter.of(context).push(const SettingsRoute());
              },
            ),
            _buildFeatureTile(
              context,
              icon: Icons.info_outline,
              title: '关于我们',
              onTap: () {
                AutoRouter.of(context).push(const AboutRoute());
              },
            ),
            const Divider(height: 1, thickness: 8, color: Colors.black12),

            // --- 退出登录按钮 (仅当已登录时显示) ---
            if (userInfo.isLoggedIn)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    userInfo.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已退出登录')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '退出登录',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 构建用户信息区域
  Widget _buildUserInfoSection(BuildContext context, UserinfoViewmodel userInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage: userInfo.isLoggedIn
                ? const NetworkImage('https://via.placeholder.com/150') // 替换为用户头像URL
                : null,
            child: !userInfo.isLoggedIn
                ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (userInfo.isLoggedIn) {
                  AutoRouter.of(context).push(const UserInfoRoute()); // 跳转到用户信息页面
                } else {
                  AutoRouter.of(context).push(const LoginRoute()); // 跳转到登录页面
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userInfo.isLoggedIn ? '用户名：John Doe' : '点击登录/注册',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userInfo.isLoggedIn ? 'ID: 123456789' : '登录后体验更多功能',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  // 构建功能列表项
  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueGrey[700]),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 72), // 列表项之间的分隔线
      ],
    );
  }

  // 检查登录状态并跳转
  void _checkLoginAndNavigate(
      BuildContext context, UserinfoViewmodel userInfo, PageRouteInfo route) {
    if (userInfo.isLoggedIn) {
      AutoRouter.of(context).push(route);
    } else {
      AutoRouter.of(context).push(const LoginRoute());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
    }
  }
}

// --- 假设的路由页面，请根据你的实际项目创建 ---
// 在你的 app_router.dart 文件中配置这些路由

@RoutePage()
class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人信息')),
      body: const Center(
        child: Text('这里是个人信息页面', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('观看历史')),
      body: const Center(
        child: Text('这里是观看历史页面', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: const Center(
        child: Text('这里是我的收藏页面', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

@RoutePage()
class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的下载')),
      body: const Center(
        child: Text('这里是我的下载页面', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const Center(
        child: Text('这里是设置页面', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们')),
      body: const Center(
        child: Text('这里是关于我们页面', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// 需要在 pubspec.yaml 中添加 provider 依赖
// dependencies:
//   flutter:
//     sdk: flutter
//   auto_route: ^7.0.0 # 替换为你的auto_router版本
//   auto_route_generator: ^7.0.0 # 替换为你的auto_router版本
//   build_runner: ^2.0.0 # 替换为你的build_runner版本
//   provider: ^6.0.0 # 替换为你的provider版本
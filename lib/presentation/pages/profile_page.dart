import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/viewmodels/userinfo_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:metaverse_client/routes/app_router.dart';

/// 用户个人资料页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserinfoViewmodel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 用户信息区域 ---
            _buildUserInfoSection(context, userInfo),
            const Divider(height: 8, thickness: 4, color: Colors.black12), // 分隔线

            // --- 功能入口列表 ---
            _buildFeatureTile(
              context,
              icon: Icons.history,
              title: '观看历史',
              onTap: () {
                // 跳转到观看历史页面
                AutoRouter.of(context).push(const HistoryRoute());
              },
            ),
            _buildFeatureTile(
              context,
              icon: Icons.collections_bookmark,
              title: '我的收藏',
              onTap: () {
                AutoRouter.of(context).push(const FavoritesRoute());
              },
            ),
            _buildFeatureTile(
              context,
              icon: Icons.download,
              title: '我的下载',
              onTap: () {
                AutoRouter.of(context).push(const DownloadsRoute());
              },
            ),
            const Divider(height: 8, thickness: 4, color: Colors.black12),

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
            const Divider(height: 8, thickness: 4, color: Colors.black12),

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
}

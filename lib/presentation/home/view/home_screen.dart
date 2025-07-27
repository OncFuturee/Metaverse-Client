import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:metaverse_client/core/config/debug_config.dart';
import 'package:metaverse_client/core/services/call/call_notification_manager.dart';
import 'package:metaverse_client/core/services/websocket/websocket_service.dart';

import 'package:metaverse_client/presentation/home/view/pages/home_page.dart';
import 'package:metaverse_client/presentation/home/view/pages/messages_page.dart';
import 'package:metaverse_client/presentation/home/view/pages/profile_drawer_page.dart';
import 'package:metaverse_client/presentation/home/view/pages/profile_page.dart';
import 'package:metaverse_client/routes/app_router.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainPageState();
}

class _MainPageState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('动态页占位')),
    const Center(child: Text('投稿页占位')),
    MessagesPage(), // 消息页
    const ProfilePage(), // 个人中心页
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void openProfileDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // 确保在应用启动时设置根导航器的key
    // 这对于在来电通知等场景中使用Overlay非常重要
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 设置根导航器的key
      AppRouter.rootNavigatorKey = AutoRouter.of(context).navigatorKey;
    });
    return Scaffold(
      key: _scaffoldKey,
      drawer: ProfileDrawerPage(onClose: () => Navigator.of(context).pop()),
      drawerEnableOpenDragGesture: true,
      body: Stack(
        children: [
          // 当前页面
          IndexedStack(
            index: _currentIndex,
            children: _pages.map((page) {
              // 首页需要传递 openProfileDrawer 回调
              if (page is HomePage) {
                return HomePage(onAvatarTap: openProfileDrawer);
              }
              return page;
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            label: '首页',
            activeIcon: Icon(Icons.home_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web_stories_outlined), 
            label: '图文',
            activeIcon: Icon(Icons.web_stories_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined), 
            label: '投稿',
            activeIcon: Icon(Icons.add_box_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined), 
            label: '消息',
            activeIcon: Icon(Icons.forum_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            label: '我的',
            activeIcon: Icon(Icons.person_rounded),
          ),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

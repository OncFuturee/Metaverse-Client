import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import 'package:metaverse_client/presentation/pages/home_page.dart';
import 'package:metaverse_client/presentation/pages/profile_drawer_page.dart';
import 'package:metaverse_client/presentation/pages/profile_page.dart';

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
    const Center(child: Text('消息页占位')),
    const ProfilePage(), // 个人中心页
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void openProfileDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.dynamic_feed), label: '动态'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: '投稿'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

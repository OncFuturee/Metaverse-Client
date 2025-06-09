import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_drawer_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('动态页占位')),
    const Center(child: Text('投稿页占位')),
    const Center(child: Text('消息页占位')),
    const Center(child: Text('我的页占位')),
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

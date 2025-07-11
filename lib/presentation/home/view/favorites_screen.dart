import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
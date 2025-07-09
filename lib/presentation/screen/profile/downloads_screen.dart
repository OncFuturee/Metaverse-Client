import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
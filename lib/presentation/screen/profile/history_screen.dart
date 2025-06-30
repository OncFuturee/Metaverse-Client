import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
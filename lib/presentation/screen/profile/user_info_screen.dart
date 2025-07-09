import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
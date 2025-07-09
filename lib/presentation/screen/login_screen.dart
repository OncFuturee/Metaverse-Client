import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/viewmodels/userinfo_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserinfoViewmodel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('这是一个登录页面', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                userInfo.login();
                AutoRouter.of(context).pop(); // 登录成功后返回上一页
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('登录成功！')),
                );
              },
              child: const Text('模拟登录'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'app_theme.dart';

class MetaverseApp extends StatelessWidget {
  const MetaverseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metaverse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // TODO: 添加路由配置
    );
  }
}

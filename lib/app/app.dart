import 'package:flutter/material.dart';
import 'package:metaverse_client/core/registry/feature_registry.dart';
import 'app_theme.dart';

class MetaverseApp extends StatelessWidget {
  const MetaverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metaverse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 根据系统设置自动切换主题
      home: ,
      // 路由
      routes: FeatureRegistry.getAllRoutes(),
    );
  }
}

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCore(); // 初始化核心服务和依赖
  runApp(const MetaverseApp());
}

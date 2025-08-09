import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:metaverse_client/core/config/debug_config.dart';
import 'package:metaverse_client/core/services/call/call_notification_manager.dart';
import 'package:metaverse_client/core/services/websocket/websocket_manager.dart';
import 'package:metaverse_client/core/services/websocket/websocket_service.dart';
import 'package:metaverse_client/presentation/videoPlayer/view_models/videoplay_screen_viewmodel.dart';
import 'package:provider/provider.dart';

import 'injection.dart';
import 'package:metaverse_client/routes/app_router.dart';
import 'package:metaverse_client/routes/auth_guard.dart';

import 'presentation/home/view_models/home_viewmodel.dart';
import 'package:metaverse_client/presentation/home/view_models/category_viewmodel.dart';
import 'package:metaverse_client/presentation/home/view_models/userinfo_viewmodel.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保Flutter引擎已初始化
  await DebugConfig.instance.load();// 加载调试参数
  MediaKit.ensureInitialized(); // 初始化 media_kit
  await configureDependencies(); // 配置依赖注入

  /// 为了防止过早创建WebSocket连接而引发web_entrypoint.dart文件找不到的问题，
  /// 我们在这里延迟初始化WebSocket服务和来电管理器。
  // 这将确保在应用程序启动时不会立即连接WebSocket。
  WidgetsBinding.instance.addPostFrameCallback((_) {
    WebSocketService().connect('wss://genchrunner.cn:8023/ws'); // 初始化 WebSocket 服务
    WebSocketService().addStatusListener((status) {
      if (status == WebSocketStatus.connected) {
        // 连接成功后发送身份验证消息
        WebSocketService().sendMessage('auth', {'userId': DebugConfig.instance.params['userId']});
      }
    });
    CallNotificationManager();// 初始化来电管理器
  });
  

  // 注册全局生命周期观察者
  final lifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(lifecycleObserver);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel( 
          categoryUsecases: getIt(),
          storageKey: 'categories',
        )),
        ChangeNotifierProvider(create: (_) => UserinfoViewmodel()),
        ChangeNotifierProvider(create: (_) => VideoPlayScreenViewModel()),
      ],
      child: MetaverseApp(),
    ),
  );
}

// 全局生命周期观察者
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 应用即将终止时触发
    if (state == AppLifecycleState.detached) {
      // 调用所有需要释放的资源
      CallNotificationManager().dispose();
      WebSocketService().dispose();
      // 其他全局资源释放
    }
  }
}

class MetaverseApp extends StatelessWidget {
  MetaverseApp({super.key});

  final _appRouter = AppRouter(authGuard: AuthGuard(false));

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Metaverse 客户端',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _appRouter.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}

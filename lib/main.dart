import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'injection.dart';
import 'package:metaverse_client/routes/app_router.dart';
import 'package:metaverse_client/routes/auth_guard.dart';

import 'presentation/viewmodels/home_viewmodel.dart';
import 'package:metaverse_client/presentation/viewmodels/category_viewmodel.dart';
import 'package:metaverse_client/presentation/viewmodels/userinfo_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保Flutter引擎已初始化
  await configureDependencies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel( 
          categoryUsecases: getIt(),
          storageKey: 'categories',
        )),
        ChangeNotifierProvider(create: (_) => UserinfoViewmodel()),
      ],
      child: MetaverseApp(),
    ),
  );
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
    // return MaterialApp(
    //   title: 'metaverse_client',
    //   theme: ThemeData(primarySwatch: Colors.blue),
    //   home: const MainPage(),
    //   debugShowCheckedModeBanner: false,
    // );
  }
}

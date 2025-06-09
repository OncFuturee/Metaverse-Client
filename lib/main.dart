import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'injection.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: const MetaverseApp(),
    ),
  );
}

class MetaverseApp extends StatelessWidget {
  const MetaverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'metaverse_client',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

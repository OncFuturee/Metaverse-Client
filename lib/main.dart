import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MetaverseApp());
}

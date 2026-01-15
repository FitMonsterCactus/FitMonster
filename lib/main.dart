import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitmonster/core/theme/app_theme.dart';
import 'package:fitmonster/core/constants/app_constants.dart';
import 'package:fitmonster/features/home/presentation/pages/home_page.dart';

void main() async {
  // Инициализация Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();
  
  runApp(const FitMonsterApp());
}

class FitMonsterApp extends StatelessWidget {
  const FitMonsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

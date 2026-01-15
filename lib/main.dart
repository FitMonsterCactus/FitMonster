import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitmonster/core/theme/app_theme.dart';
import 'package:fitmonster/core/constants/app_constants.dart';
import 'package:fitmonster/features/home/presentation/pages/home_page.dart';
import 'package:fitmonster/features/exercises/data/exercises_database.dart';
import 'package:fitmonster/features/exercises/presentation/pages/exercise_camera_page.dart';

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
    const startCamera = bool.fromEnvironment('START_CAMERA', defaultValue: false);

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: startCamera ? const _DebugAutoStartCamera() : const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _DebugAutoStartCamera extends StatelessWidget {
  const _DebugAutoStartCamera();

  @override
  Widget build(BuildContext context) {
    final exercise = ExercisesDatabase.getAllExercises().first;
    return ExerciseCameraPage(
      exercise: exercise,
      autostart: true,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fitmonster/features/exercises/presentation/pages/exercises_page.dart';
import 'package:fitmonster/features/diet/presentation/pages/diet_page.dart';
import 'package:fitmonster/features/profile/presentation/pages/profile_page.dart';

/// Главная страница с навигацией
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Используем IndexedStack для сохранения состояния вкладок
  final List<Widget> _pages = const [
    ExercisesPage(),
    DietPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Упражнения',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Диета',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

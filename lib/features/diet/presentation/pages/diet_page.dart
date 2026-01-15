import 'package:flutter/material.dart';
import 'package:fitmonster/core/widgets/empty_state.dart';
import 'package:fitmonster/features/diet/presentation/pages/profile_setup_page.dart';
import 'package:fitmonster/features/diet/presentation/pages/food_log_page.dart';
import 'package:fitmonster/features/diet/domain/services/calorie_calculator.dart';
import 'package:fitmonster/features/diet/domain/services/diet_service.dart';

/// Страница диеты и трекера питания
class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  bool _hasProfile = false;
  Macros? _targetMacros;
  int _profileVersion = 0; // Для принудительного пересоздания виджета
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProfile(isInitial: true);
  }

  Future<void> _loadProfile({bool isInitial = false}) async {
    try {
      final profile = await DietService.getUserProfile();
      
      if (profile != null) {
        final macros = CalorieCalculator.calculateMacros(profile);
        final oldMacros = _targetMacros;
        
        setState(() {
          _hasProfile = true;
          _targetMacros = macros;
          
          // Увеличиваем версию только если профиль изменился (не при первой загрузке)
          if (!isInitial && _isInitialized && oldMacros != null) {
            if (oldMacros.calories != macros.calories ||
                oldMacros.protein != macros.protein ||
                oldMacros.fat != macros.fat ||
                oldMacros.carbs != macros.carbs) {
              _profileVersion++;
            }
          }
          _isInitialized = true;
        });
      } else {
        setState(() {
          _hasProfile = false;
          _targetMacros = null;
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Если Hive не инициализирован (например, в тестах), просто показываем пустое состояние
      setState(() {
        _hasProfile = false;
        _targetMacros = null;
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasProfile && _targetMacros != null) {
      return FoodLogPage(
        key: ValueKey(_profileVersion), // Пересоздаем виджет при изменении профиля
        date: DateTime.now(),
        targetMacros: _targetMacros!,
        onProfileUpdated: _loadProfile,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Диета'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настроить профиль',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSetupPage(),
                ),
              );
              _loadProfile();
            },
          ),
        ],
      ),
      body: EmptyState(
        icon: Icons.restaurant,
        title: 'Журнал питания пуст',
        message: 'Сначала настройте профиль для расчета калорий',
        actionText: 'Настроить профиль',
        onAction: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileSetupPage(),
            ),
          );
          _loadProfile();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileSetupPage(),
            ),
          );
          _loadProfile();
        },
        icon: const Icon(Icons.calculate),
        label: const Text('Рассчитать калории'),
      ),
    );
  }
}

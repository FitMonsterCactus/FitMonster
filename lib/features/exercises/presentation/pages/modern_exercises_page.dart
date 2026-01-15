import 'package:flutter/material.dart';
import 'package:fitmonster/core/theme/app_theme.dart';
import 'package:fitmonster/features/exercises/data/exercises_database.dart';
import 'package:fitmonster/features/exercises/domain/models/exercise.dart';
import 'package:fitmonster/features/exercises/presentation/pages/exercise_camera_page.dart';

/// Современная страница упражнений с красивым дизайном
/// Готова для конвертации через DhiWise
class ModernExercisesPage extends StatefulWidget {
  const ModernExercisesPage({super.key});

  @override
  State<ModernExercisesPage> createState() => _ModernExercisesPageState();
}

class _ModernExercisesPageState extends State<ModernExercisesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedCategory = 'Все';
  final List<String> _categories = [
    'Все',
    'Кардио',
    'Силовые',
    'Растяжка',
    'Функциональные',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        
        // Categories
        SliverToBoxAdapter(
          child: _buildCategories(),
        ),
        
        // Search Bar
        SliverToBoxAdapter(
          child: _buildSearchBar(),
        ),
        
        // Quick Start Section
        SliverToBoxAdapter(
          child: _buildQuickStart(),
        ),
        
        // Exercises Grid
        SliverToBoxAdapter(
          child: _buildExercisesGrid(),
        ),
        
        // Bottom Spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Фильтры
                },
                icon: const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Упражнения',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите упражнение для тренировки',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected 
                        ? const Color(0xFF667eea) 
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Поиск упражнений...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Быстрый старт',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStartCard(
                  title: 'Случайное упражнение',
                  emoji: '🎲',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  onTap: () {
                    _startRandomExercise();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStartCard(
                  title: 'Последнее упражнение',
                  emoji: '⏮️',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  onTap: () {
                    _startLastExercise();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard({
    required String title,
    required String emoji,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Увеличиваем высоту
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // Уменьшаем отступы
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              Flexible( // Добавляем Flexible для текста
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13, // Уменьшаем размер шрифта
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1, // Уменьшаем межстрочный интервал
                  ),
                  maxLines: 2, // Ограничиваем количество строк
                  overflow: TextOverflow.ellipsis, // Добавляем многоточие при переполнении
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesGrid() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Все упражнения',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Exercise>>(
            future: Future.value(ExercisesDatabase.getAllExercises()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final exercises = snapshot.data ?? [];
              final filteredExercises = _selectedCategory == 'Все'
                  ? exercises
                  : exercises.where((e) => _getCategoryForExercise(e.id) == _selectedCategory).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  return _buildExerciseCard(exercise, index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int index) {
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
      [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
      [const Color(0xFF45B7D1), const Color(0xFF96C93D)],
      [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
    ];
    
    final colorPair = colors[index % colors.length];
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseCameraPage(exercise: exercise),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colorPair,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorPair[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji вместо иконки
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    _getEmojiForExercise(exercise.id),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Title
              Text(
                exercise.nameRu,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getCategoryForExercise(exercise.id),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Difficulty
              Row(
                children: [
                  ...List.generate(3, (i) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: i < _getDifficultyForExercise(exercise.id)
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    _getDifficultyText(_getDifficultyForExercise(exercise.id)),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmojiForExercise(String exerciseId) {
    switch (exerciseId) {
      case 'squats':
        return '🏋️'; // Приседания
      case 'pushups':
        return '💪'; // Отжимания
      case 'plank':
        return '🧘'; // Планка
      case 'lunges':
        return '🚶'; // Выпады
      case 'jumping_jacks':
        return '🤸'; // Прыжки
      case 'burpees':
        return '🔥'; // Бурпи
      case 'mountain_climbers':
        return '🏔️'; // Альпинист
      case 'high_knees':
        return '🏃'; // Высокие колени
      case 'crunches':
        return '💯'; // Скручивания
      case 'leg_raises':
        return '🦵'; // Подъем ног
      case 'sit_ups':
        return '⬆️'; // Подъемы туловища
      case 'bicycle_crunches':
        return '🚴'; // Велосипед
      case 'russian_twists':
        return '🌪️'; // Русские скручивания
      case 'wall_sit':
        return '🧱'; // Приседания у стены
      case 'tricep_dips':
        return '💺'; // Отжимания на трицепс
      case 'superman':
        return '🦸'; // Супермен
      case 'dead_bug':
        return '🐛'; // Мертвый жук
      case 'glute_bridges':
        return '🌉'; // Ягодичный мостик
      case 'side_plank':
        return '📐'; // Боковая планка
      case 'bear_crawl':
        return '🐻'; // Медвежья походка
      default:
        return '💪'; // По умолчанию
    }
  }

  IconData _getIconForExercise(String exerciseId) {
    switch (exerciseId) {
      case 'squats':
        return Icons.fitness_center;
      case 'pushups':
        return Icons.sports_gymnastics;
      case 'plank':
        return Icons.timer;
      case 'lunges':
        return Icons.directions_walk;
      case 'jumping_jacks':
        return Icons.sports_handball;
      case 'burpees':
        return Icons.sports_martial_arts;
      case 'mountain_climbers':
        return Icons.terrain;
      case 'high_knees':
        return Icons.directions_run;
      case 'crunches':
        return Icons.sports_kabaddi;
      case 'leg_raises':
        return Icons.trending_up;
      default:
        return Icons.fitness_center;
    }
  }

  String _getCategoryForExercise(String exerciseId) {
    switch (exerciseId) {
      case 'squats':
      case 'pushups':
      case 'lunges':
        return 'Силовые';
      case 'jumping_jacks':
      case 'burpees':
      case 'mountain_climbers':
      case 'high_knees':
        return 'Кардио';
      case 'plank':
      case 'crunches':
      case 'leg_raises':
        return 'Функциональные';
      default:
        return 'Силовые';
    }
  }

  int _getDifficultyForExercise(String exerciseId) {
    switch (exerciseId) {
      case 'squats':
      case 'pushups':
      case 'plank':
        return 1; // Легкий
      case 'lunges':
      case 'jumping_jacks':
      case 'crunches':
      case 'leg_raises':
        return 2; // Средний
      case 'burpees':
      case 'mountain_climbers':
      case 'high_knees':
        return 3; // Сложный
      default:
        return 1;
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Легкий';
      case 2:
        return 'Средний';
      case 3:
        return 'Сложный';
      default:
        return 'Легкий';
    }
  }

  void _startRandomExercise() {
    final exercises = ExercisesDatabase.getAllExercises();
    if (exercises.isNotEmpty) {
      final randomExercise = exercises[DateTime.now().millisecond % exercises.length];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseCameraPage(exercise: randomExercise),
          ),
        );
      }
    }
  }

  void _startLastExercise() {
    // Здесь можно добавить логику для получения последнего упражнения
    // Пока что запускаем первое упражнение
    final exercises = ExercisesDatabase.getAllExercises();
    if (exercises.isNotEmpty) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseCameraPage(exercise: exercises.first),
          ),
        );
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:fitmonster/features/exercises/domain/models/exercise.dart';
import 'package:fitmonster/features/exercises/data/exercises_database.dart';
import 'package:fitmonster/features/exercises/presentation/pages/exercise_camera_page.dart';
import 'package:fitmonster/features/exercises/presentation/pages/demo_camera_page.dart';
import 'package:fitmonster/features/exercises/presentation/pages/pose_test_page.dart';
import 'package:fitmonster/features/exercises/presentation/widgets/muscle_diagram.dart';
import 'package:fitmonster/core/theme/app_theme.dart';

/// Страница упражнений
class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final _searchController = TextEditingController();
  List<Exercise> _exercises = [];
  ExerciseCategory? _selectedCategory;
  ExerciseDifficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExercises() {
    setState(() {
      _exercises = ExercisesDatabase.getAllExercises();
    });
  }

  void _filterExercises() {
    List<Exercise> filtered = ExercisesDatabase.getAllExercises();

    // Фильтр по категории
    if (_selectedCategory != null) {
      filtered = filtered
          .where((e) => e.category == _selectedCategory)
          .toList();
    }

    // Фильтр по сложности
    if (_selectedDifficulty != null) {
      filtered = filtered
          .where((e) => e.difficulty == _selectedDifficulty)
          .toList();
    }

    // Поиск
    final query = _searchController.text;
    if (query.isNotEmpty) {
      filtered = ExercisesDatabase.searchExercises(query)
          .where((e) => filtered.contains(e))
          .toList();
    }

    setState(() {
      _exercises = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Упражнения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PoseTestPage()),
              );
            },
            tooltip: 'Тест скелета',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск упражнений...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (_) => _filterExercises(),
            ),
          ),

          // Фильтры
          if (_selectedCategory != null || _selectedDifficulty != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_selectedCategory!.nameRu),
                      avatar: Text(_selectedCategory!.emoji),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                        _filterExercises();
                      },
                    ),
                  if (_selectedDifficulty != null)
                    Chip(
                      label: Text(_selectedDifficulty!.nameRu),
                      avatar: Text(_selectedDifficulty!.emoji),
                      onDeleted: () {
                        setState(() {
                          _selectedDifficulty = null;
                        });
                        _filterExercises();
                      },
                    ),
                ],
              ),
            ),

          // Список упражнений
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Упражнения не найдены',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return _ExerciseCard(
                        exercise: exercise,
                        onTap: () => _showExerciseDetails(exercise),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фильтры'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Категория',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ExerciseCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category.nameRu),
                  avatar: Text(category.emoji),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                    _filterExercises();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Сложность',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ExerciseDifficulty.values.map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                return FilterChip(
                  label: Text(difficulty.nameRu),
                  avatar: Text(difficulty.emoji),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? difficulty : null;
                    });
                    _filterExercises();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedDifficulty = null;
              });
              _filterExercises();
              Navigator.pop(context);
            },
            child: const Text('Сбросить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showMuscleDiagram(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Работающие мышцы',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                exercise.nameRu,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: MuscleDiagram(
                  activeMuscles: exercise.muscleGroups,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Нажмите на мышцу для подробностей',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Заголовок
              Row(
                children: [
                  Text(
                    exercise.category.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.nameRu,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Row(
                          children: [
                            Text(exercise.difficulty.emoji),
                            const SizedBox(width: 4),
                            Text(
                              exercise.difficulty.nameRu,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.local_fire_department, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${exercise.caloriesPerMinute} ккал/мин',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Описание
              Text(
                exercise.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Мышечные группы
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Работающие мышцы',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _showMuscleDiagram(context, exercise),
                    icon: const Icon(Icons.accessibility_new, size: 20),
                    label: const Text('Показать на теле'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: exercise.muscleGroups
                    .map((muscle) => Chip(
                          label: Text(muscle),
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Инструкции
              Text(
                'Как выполнять',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...exercise.instructions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(entry.value),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Частые ошибки
              Text(
                'Частые ошибки',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...exercise.commonMistakes.map((mistake) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(mistake),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),

              // Кнопки
              Row(
                children: [
                  // Кнопка демо-режима
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DemoCameraPage(
                              exerciseName: exercise.nameRu,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.smart_toy),
                      label: const Text('ДЕМО'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Основная кнопка
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseCameraPage(
                              exercise: exercise,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('С камерой'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
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
}

/// Карточка упражнения
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    exercise.category.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nameRu,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(exercise.difficulty.emoji),
                        const SizedBox(width: 4),
                        Text(
                          exercise.difficulty.nameRu,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.caloriesPerMinute} ккал/мин',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.muscleGroups.join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Стрелка
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

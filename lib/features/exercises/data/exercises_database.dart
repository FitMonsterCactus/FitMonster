import 'package:fitmonster/features/exercises/domain/models/exercise.dart';

/// База данных упражнений
class ExercisesDatabase {
  static final List<Exercise> _exercises = [
    // 1. Приседания
    Exercise(
      id: 'squats',
      nameRu: 'Приседания',
      nameEn: 'Squats',
      description:
          'Базовое упражнение для ног и ягодиц. Укрепляет квадрицепсы, бицепсы бедра и ягодичные мышцы.',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.beginner,
      muscleGroups: ['Ноги', 'Ягодицы', 'Кор'],
      caloriesPerMinute: 8,
      instructions: [
        'Встаньте прямо, ноги на ширине плеч',
        'Руки вытяните перед собой или скрестите на груди',
        'Опуститесь вниз, сгибая колени и отводя таз назад',
        'Опускайтесь до параллели бедер с полом',
        'Вернитесь в исходное положение, отталкиваясь пятками',
      ],
      commonMistakes: [
        'Колени выходят за носки',
        'Спина округляется',
        'Пятки отрываются от пола',
        'Недостаточная глубина приседа',
      ],
    ),

    // 2. Отжимания
    Exercise(
      id: 'pushups',
      nameRu: 'Отжимания',
      nameEn: 'Push-ups',
      description:
          'Классическое упражнение для верхней части тела. Развивает грудные мышцы, трицепсы и плечи.',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.intermediate,
      muscleGroups: ['Грудь', 'Трицепсы', 'Плечи', 'Кор'],
      caloriesPerMinute: 7,
      instructions: [
        'Примите упор лежа, руки на ширине плеч',
        'Тело должно образовывать прямую линию',
        'Опуститесь вниз, сгибая локти',
        'Грудь почти касается пола',
        'Вернитесь в исходное положение, выпрямляя руки',
      ],
      commonMistakes: [
        'Провисание поясницы',
        'Поднятие таза вверх',
        'Локти слишком широко разведены',
        'Неполная амплитуда движения',
      ],
    ),

    // 3. Планка
    Exercise(
      id: 'plank',
      nameRu: 'Планка',
      nameEn: 'Plank',
      description:
          'Статическое упражнение для укрепления кора. Развивает выносливость мышц пресса и спины.',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.beginner,
      muscleGroups: ['Кор', 'Пресс', 'Спина', 'Плечи'],
      caloriesPerMinute: 5,
      instructions: [
        'Примите упор на предплечья и носки',
        'Локти под плечами',
        'Тело образует прямую линию от головы до пяток',
        'Напрягите пресс и ягодицы',
        'Держите позицию, дышите ровно',
      ],
      commonMistakes: [
        'Провисание поясницы',
        'Поднятие таза вверх',
        'Задержка дыхания',
        'Опущенная голова',
      ],
    ),

    // 4. Подъем ног лежа
    Exercise(
      id: 'leg_raises',
      nameRu: 'Подъем ног лежа',
      nameEn: 'Leg Raises',
      description:
          'Упражнение для нижней части пресса. Укрепляет прямую мышцу живота и сгибатели бедра.',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.intermediate,
      muscleGroups: ['Пресс', 'Сгибатели бедра'],
      caloriesPerMinute: 6,
      instructions: [
        'Лягте на спину, руки вдоль тела или под ягодицами',
        'Ноги прямые, вместе',
        'Поднимите ноги вверх до угла 90 градусов',
        'Медленно опустите ноги, не касаясь пола',
        'Повторите движение',
      ],
      commonMistakes: [
        'Отрыв поясницы от пола',
        'Слишком быстрое выполнение',
        'Сгибание ног в коленях',
        'Опускание ног на пол',
      ],
    ),

    // 5. Скручивания
    Exercise(
      id: 'crunches',
      nameRu: 'Скручивания',
      nameEn: 'Crunches',
      description:
          'Базовое упражнение для пресса. Изолированно прорабатывает прямую мышцу живота.',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.beginner,
      muscleGroups: ['Пресс'],
      caloriesPerMinute: 5,
      instructions: [
        'Лягте на спину, ноги согнуты, стопы на полу',
        'Руки за головой или скрещены на груди',
        'Поднимите плечи и верхнюю часть спины',
        'Напрягите пресс в верхней точке',
        'Медленно вернитесь в исходное положение',
      ],
      commonMistakes: [
        'Тянуть голову руками',
        'Отрыв поясницы от пола',
        'Слишком высокий подъем',
        'Рывковые движения',
      ],
    ),

    // 6. Выпады
    Exercise(
      id: 'lunges',
      nameRu: 'Выпады',
      nameEn: 'Lunges',
      description:
          'Упражнение для ног и ягодиц. Развивает баланс и координацию, укрепляет квадрицепсы.',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.intermediate,
      muscleGroups: ['Ноги', 'Ягодицы', 'Баланс'],
      caloriesPerMinute: 7,
      instructions: [
        'Встаньте прямо, ноги вместе',
        'Сделайте шаг вперед одной ногой',
        'Опуститесь вниз, сгибая оба колена до 90 градусов',
        'Переднее колено над пяткой, заднее почти касается пола',
        'Вернитесь в исходное положение и повторите с другой ногой',
      ],
      commonMistakes: [
        'Переднее колено выходит за носок',
        'Наклон корпуса вперед',
        'Слишком узкий шаг',
        'Потеря баланса',
      ],
    ),

    // 7. Бурпи
    Exercise(
      id: 'burpees',
      nameRu: 'Бурпи',
      nameEn: 'Burpees',
      description:
          'Комплексное кардио-упражнение. Задействует все тело, отлично сжигает калории.',
      category: ExerciseCategory.cardio,
      difficulty: ExerciseDifficulty.advanced,
      muscleGroups: ['Все тело', 'Кардио'],
      caloriesPerMinute: 12,
      instructions: [
        'Встаньте прямо',
        'Присядьте и поставьте руки на пол',
        'Прыжком примите упор лежа',
        'Сделайте отжимание (опционально)',
        'Прыжком подтяните ноги к рукам',
        'Выпрыгните вверх с поднятыми руками',
      ],
      commonMistakes: [
        'Провисание в планке',
        'Неполная амплитуда',
        'Слишком быстрое выполнение',
        'Задержка дыхания',
      ],
    ),

    // 8. Прыжки со скакалкой
    Exercise(
      id: 'jump_rope',
      nameRu: 'Прыжки со скакалкой',
      nameEn: 'Jump Rope',
      description:
          'Кардио-упражнение для выносливости. Улучшает координацию и сжигает много калорий.',
      category: ExerciseCategory.cardio,
      difficulty: ExerciseDifficulty.beginner,
      muscleGroups: ['Икры', 'Кардио', 'Координация'],
      caloriesPerMinute: 13,
      instructions: [
        'Возьмите скакалку, руки по бокам',
        'Вращайте скакалку запястьями',
        'Прыгайте на носках, колени слегка согнуты',
        'Приземляйтесь мягко',
        'Держите ритм и дышите ровно',
      ],
      commonMistakes: [
        'Прыжки на всей стопе',
        'Слишком высокие прыжки',
        'Вращение всей рукой',
        'Неровный ритм',
      ],
    ),

    // 9. Собака мордой вниз
    Exercise(
      id: 'downward_dog',
      nameRu: 'Собака мордой вниз',
      nameEn: 'Downward Dog',
      description:
          'Йога-поза для растяжки и укрепления. Растягивает заднюю поверхность тела.',
      category: ExerciseCategory.flexibility,
      difficulty: ExerciseDifficulty.beginner,
      muscleGroups: ['Спина', 'Ноги', 'Плечи', 'Растяжка'],
      caloriesPerMinute: 3,
      instructions: [
        'Встаньте на четвереньки',
        'Поднимите таз вверх, выпрямляя ноги',
        'Тело образует треугольник',
        'Пятки тянутся к полу',
        'Голова между руками, взгляд на ноги',
        'Дышите глубоко и ровно',
      ],
      commonMistakes: [
        'Округление спины',
        'Согнутые колени',
        'Плечи у ушей',
        'Задержка дыхания',
      ],
    ),

    // 10. Бег на месте
    Exercise(
      id: 'running_in_place',
      nameRu: 'Бег на месте',
      nameEn: 'Running in Place',
      description:
          'Простое кардио-упражнение. Разогревает тело и улучшает выносливость.',
      category: ExerciseCategory.cardio,
      difficulty: ExerciseDifficulty.beginner,
      muscleGroups: ['Ноги', 'Кардио'],
      caloriesPerMinute: 10,
      instructions: [
        'Встаньте прямо',
        'Начните бег на месте, поднимая колени',
        'Руки работают в такт ногам',
        'Приземляйтесь на носки',
        'Держите темп и дышите ритмично',
      ],
      commonMistakes: [
        'Слишком низкий подъем коленей',
        'Приземление на пятки',
        'Неподвижные руки',
        'Задержка дыхания',
      ],
    ),
  ];

  /// Получить все упражнения
  static List<Exercise> getAllExercises() {
    return List.unmodifiable(_exercises);
  }

  /// Получить упражнение по ID
  static Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получить упражнения по категории
  static List<Exercise> getExercisesByCategory(ExerciseCategory category) {
    return _exercises
        .where((exercise) => exercise.category == category)
        .toList();
  }

  /// Получить упражнения по сложности
  static List<Exercise> getExercisesByDifficulty(
      ExerciseDifficulty difficulty) {
    return _exercises
        .where((exercise) => exercise.difficulty == difficulty)
        .toList();
  }

  /// Поиск упражнений
  static List<Exercise> searchExercises(String query) {
    if (query.isEmpty) return getAllExercises();

    final lowerQuery = query.toLowerCase();
    return _exercises.where((exercise) {
      return exercise.nameRu.toLowerCase().contains(lowerQuery) ||
          exercise.nameEn.toLowerCase().contains(lowerQuery) ||
          exercise.description.toLowerCase().contains(lowerQuery) ||
          exercise.muscleGroups
              .any((muscle) => muscle.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Получить рекомендованные упражнения для начинающих
  static List<Exercise> getBeginnerExercises() {
    return getExercisesByDifficulty(ExerciseDifficulty.beginner);
  }
}

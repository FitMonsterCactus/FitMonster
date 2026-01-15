import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Painter для отрисовки скелета на теле человека
/// Улучшенная версия на основе MediaPipe Pose Landmarker из Camerawork
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
  });

  // Соединения скелета (как в Camerawork/MainActivity.kt)
  static const List<List<int>> _connections = [
    // Торс
    [11, 12], // Плечи
    [11, 23], // Левое плечо - левое бедро
    [12, 24], // Правое плечо - правое бедро
    [23, 24], // Бедра
    
    // Левая рука
    [11, 13], // Плечо - локоть
    [13, 15], // Локоть - запястье
    [15, 17], // Запястье - большой палец
    [15, 19], // Запястье - указательный палец
    [15, 21], // Запястье - мизинец
    [17, 19], // Большой - указательный
    
    // Правая рука
    [12, 14], // Плечо - локоть
    [14, 16], // Локоть - запястье
    [16, 18], // Запястье - большой палец
    [16, 20], // Запястье - указательный палец
    [16, 22], // Запястье - мизинец
    [18, 20], // Большой - указательный
    
    // Левая нога
    [23, 25], // Бедро - колено
    [25, 27], // Колено - лодыжка
    [27, 29], // Лодыжка - пятка
    [29, 31], // Пятка - носок
    [27, 31], // Лодыжка - носок
    
    // Правая нога
    [24, 26], // Бедро - колено
    [26, 28], // Колено - лодыжка
    [28, 30], // Лодыжка - пятка
    [30, 32], // Пятка - носок
    [28, 32], // Лодыжка - носок
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Настройка кистей (как в Camerawork)
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.green; // Зеленые линии как в Camerawork

    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red; // Красные точки как в Camerawork

    for (final pose in poses) {
      final landmarks = pose.landmarks.values.toList();
      
      // Рисуем соединения (линии скелета)
      for (final connection in _connections) {
        if (connection[0] < landmarks.length && connection[1] < landmarks.length) {
          final start = landmarks[connection[0]];
          final end = landmarks[connection[1]];
          
          // Проверяем видимость обеих точек (порог 0.5 как в Camerawork)
          if (start.likelihood > 0.5 && end.likelihood > 0.5) {
            final startPoint = _translatePoint(start.x, start.y, size);
            final endPoint = _translatePoint(end.x, end.y, size);
            
            canvas.drawLine(startPoint, endPoint, linePaint);
          }
        }
      }
      
      // Рисуем точки суставов поверх линий
      for (final landmark in landmarks) {
        if (landmark.likelihood > 0.5) {
          final point = _translatePoint(landmark.x, landmark.y, size);
          canvas.drawCircle(point, 10, pointPaint); // Радиус 10 как в Camerawork
        }
      }
    }
  }

  Offset _translatePoint(double x, double y, Size size) {
    // Для фронтальной камеры координаты нужно масштабировать и отзеркалить
    // ML Kit возвращает координаты в пикселях изображения
    
    if (imageSize.width == 0 || imageSize.height == 0) {
      return Offset(x, y);
    }
    
    // Масштабируем координаты из размера изображения в размер виджета
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    
    // Применяем масштабирование
    final scaledX = x * scaleX;
    final scaledY = y * scaleY;
    
    // Отзеркаливаем X координату для соответствия отзеркаленной камере
    // (1f - landmark.x()) * size.width как в Camerawork
    final mirroredX = size.width - scaledX;

    return Offset(mirroredX, scaledY);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}

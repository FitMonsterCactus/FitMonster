import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:fitmonster/features/exercises/domain/models/exercise.dart';
import 'package:fitmonster/features/exercises/presentation/widgets/pose_painter.dart';
import 'package:fitmonster/features/exercises/domain/services/workout_service.dart';
import 'package:fitmonster/features/exercises/domain/models/workout_session.dart';
import 'package:fitmonster/features/exercises/presentation/widgets/workout_results_dialog.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

class ExerciseCameraPage extends StatefulWidget {
  final Exercise exercise;
  final bool autostart;

  const ExerciseCameraPage({
    super.key,
    required this.exercise,
    this.autostart = false,
  });

  @override
  State<ExerciseCameraPage> createState() => _ExerciseCameraPageState();
}

class _ExerciseCameraPageState extends State<ExerciseCameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRecording = false;
  int _repCount = 0;
  double _formScore = 0.0;
  String _feedback = 'Встаньте в кадр';
  Timer? _feedbackTimer;
  
  // Параметры входного изображения для корректной отрисовки позы
  InputImageRotation _inputImageRotation = InputImageRotation.rotation0deg;
  Size _inputImageSize = Size.zero;
  
  // Дополнительные поля для улучшенного UI
  DateTime? _workoutStartTime;
  Duration _workoutDuration = Duration.zero;
  Timer? _durationTimer;
  
  // Интеграция с сервисом тренировок
  final WorkoutService _workoutService = WorkoutService();
  WorkoutSession? _currentSession;
  
  // ML Kit
  PoseDetector? _poseDetector;
  List<Pose> _poses = [];
  
  // FPS мониторинг
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _currentFps = 0.0;
  
  // Состояние для подсчета повторений
  bool _isInDownPosition = false;
  DateTime? _lastRepTime;
  
  DateTime _lastPoseLog = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _initializePoseDetector();
    _initializeCamera();
  }

  void _initializePoseDetector() {
    // Инициализация ML Kit Pose Detection
    // Используем настройки аналогичные MediaPipe из Camerawork
    try {
      final options = PoseDetectorOptions(
        mode: PoseDetectionMode.stream, // LIVE_STREAM режим как в MediaPipe
        model: PoseDetectionModel.accurate, // Точная модель (pose_landmarker_lite.task)
      );
      _poseDetector = PoseDetector(options: options);
      print('✅ ML Kit PoseDetector initialized (stream mode, accurate model)');
    } catch (e) {
      print('❌ Error initializing ML Kit: $e');
      if (mounted) {
        setState(() {
          _feedback = 'Ошибка инициализации ML анализа';
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _feedback = 'Камера не найдена';
        });
        return;
      }

      // Используем фронтальную камеру (DEFAULT_FRONT_CAMERA как в Camerawork)
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // 640x480 как в Camerawork (setTargetResolution(Size(640, 480)))
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // YUV420 формат
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      
      print('✅ Camera initialized: ${frontCamera.lensDirection}, resolution: medium (640x480)');

      if (mounted && widget.autostart) {
        // Даем UI дорисоваться и запускаем поток кадров
        Future.microtask(() {
          if (!mounted || _isRecording) return;
          _startExercise();
        });
      }
    } catch (e) {
      print('❌ Camera initialization error: $e');
      setState(() {
        _feedback = 'Ошибка инициализации камеры: $e';
      });
    }
  }

  void _startExercise() async {
    try {
      // Создаем новую сессию тренировки (работает и без авторизации)
      try {
        _currentSession = await _workoutService.startWorkout(
          exercise: widget.exercise,
          targetReps: 15, // Целевое количество повторений
        );
      } catch (e) {
        // Если не удалось создать сессию (например, пользователь не авторизован),
        // продолжаем без сохранения
        print('Тренировка без сохранения: $e');
      }
      
      setState(() {
        _isRecording = true;
        _repCount = 0;
        _formScore = 0.0;
        _feedback = 'Начинайте упражнение!';
        _workoutStartTime = DateTime.now();
        _workoutDuration = Duration.zero;
        _isInDownPosition = false; // Сбрасываем состояние подсчета
        _lastRepTime = null;
      });
      
      // Запускаем таймер для отслеживания времени тренировки
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isRecording) return;
        
        setState(() {
          _workoutDuration = DateTime.now().difference(_workoutStartTime!);
        });
      });
      
      // Запускаем обработку кадров
      _startImageStream();
      
      print('✅ Exercise started: ${widget.exercise.nameRu}');
    } catch (e) {
      print('❌ Error starting exercise: $e');
      setState(() {
        _feedback = 'Ошибка запуска тренировки: $e';
      });
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    print('📷 Starting camera image stream');
    
    bool _isProcessing = false;
    
    _cameraController!.startImageStream((CameraImage image) {
      if (!_isRecording || _isProcessing) return;
      
      // Обрабатываем только если предыдущий кадр уже обработан (как в Camerawork)
      _isProcessing = true;
      _processImage(image).then((_) {
        _isProcessing = false;
      }).catchError((e) {
        _isProcessing = false;
        print('❌ Error in image processing: $e');
      });
      _frameCount++;
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (_poseDetector == null) {
      print('❌ PoseDetector is null');
      return;
    }

    try {
      _updateFpsCounter();
      
      final inputImage = _createInputImageFromCameraImage(image);
      if (inputImage == null) {
        print('❌ Failed to create InputImage');
        return;
      }
      
      // Обрабатываем изображение с ML Kit
      final poses = await _poseDetector!.processImage(inputImage);
      final now = DateTime.now();
      if (now.difference(_lastPoseLog).inMilliseconds >= 1000) {
        final landmarksCount = poses.isNotEmpty ? poses.first.landmarks.length : 0;
        print(
          '🧍 poses=${poses.length} landmarks=$landmarksCount rotation=$_inputImageRotation size=$_inputImageSize fps=${_currentFps.toStringAsFixed(1)}',
        );
        _lastPoseLog = now;
      }
      
      if (mounted) {
        setState(() {
          _poses = poses;
          
          if (poses.isEmpty) {
            _feedback = 'Встаньте в кадр полностью';
          } else {
            final pose = poses.first;
            final confidence = _calculatePoseConfidence(pose);
            
            print('🔍 Pose confidence: $confidence%');
            
            if (confidence < 50) {
              _feedback = 'Улучшите освещение и встаньте ближе';
            } else {
              _feedback = 'Отличная техника! (${_currentFps.toStringAsFixed(0)} FPS)';
              _analyzeExercise(poses);
            }
          }
        });
      }
    } catch (e) {
      print('❌ Error processing image: $e');
    }
  }

  InputImage? _createInputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    try {
      final rotation = _getInputImageRotation();
      final size = Size(image.width.toDouble(), image.height.toDouble());

      // Сохраняем для отрисовки оверлея
      if (_inputImageSize != size || _inputImageRotation != rotation) {
        _inputImageSize = size;
        _inputImageRotation = rotation;
      }

      final formatGroup = image.format.group;

      // Самый частый кейс на Android/эмуляторе: YUV420 -> NV21
      if (formatGroup == ImageFormatGroup.yuv420) {
        final bytes = _yuv420ToNv21(image);
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: size,
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      }

      // Часто на iOS: BGRA8888
      if (formatGroup == ImageFormatGroup.bgra8888) {
        final plane = image.planes.first;
        return InputImage.fromBytes(
          bytes: plane.bytes,
          metadata: InputImageMetadata(
            size: size,
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      }

      print('❌ Unsupported image format group: $formatGroup');
      return null;
    } catch (e) {
      print('❌ Error creating InputImage: $e');
      return null;
    }
  }

  InputImageRotation _getInputImageRotation() {
    final sensorOrientation = _cameraController?.description.sensorOrientation ?? 0;
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 1;

    final uRowStride = uPlane.bytesPerRow;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;

    final vRowStride = vPlane.bytesPerRow;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;

    final out = Uint8List(width * height + (width * height ~/ 2));

    // Y
    int outIndex = 0;
    for (int y = 0; y < height; y++) {
      int yRow = yRowStride * y;
      for (int x = 0; x < width; x++) {
        out[outIndex++] = yBytes[yRow + x * yPixelStride];
      }
    }

    // VU (NV21)
    for (int y = 0; y < height ~/ 2; y++) {
      for (int x = 0; x < width ~/ 2; x++) {
        final uIndex = (uRowStride * y) + x * uPixelStride;
        final vIndex = (vRowStride * y) + x * vPixelStride;
        // NV21 = V then U
        out[outIndex++] = vBytes[vIndex];
        out[outIndex++] = uBytes[uIndex];
      }
    }

    return out;
  }

  double _calculatePoseConfidence(Pose pose) {
    if (pose.landmarks.isEmpty) return 0.0;
    
    double totalConfidence = 0;
    int landmarkCount = 0;
    
    for (final landmark in pose.landmarks.values) {
      totalConfidence += landmark.likelihood;
      landmarkCount++;
    }
    
    return landmarkCount > 0 ? (totalConfidence / landmarkCount) * 100 : 0.0;
  }
  
  void _analyzeExercise(List<Pose> poses) {
    if (poses.isEmpty) return;
    
    final pose = poses.first;
    
    // Подсчитываем уверенность детекции
    double totalConfidence = 0;
    int landmarkCount = 0;
    
    for (final landmark in pose.landmarks.values) {
      totalConfidence += landmark.likelihood;
      landmarkCount++;
    }
    
    if (landmarkCount > 0) {
      double averageConfidence = totalConfidence / landmarkCount;
      _formScore = (averageConfidence * 100).clamp(0, 100);
      
      // Улучшенная логика подсчета повторений
      _countReps(pose);
    }
  }

  void _countReps(Pose pose) {
    // Защита от слишком частого подсчета (минимум 500ms между повторениями)
    if (_lastRepTime != null && 
        DateTime.now().difference(_lastRepTime!).inMilliseconds < 500) {
      return;
    }
    
    // Получаем ключевые точки для анализа
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    
    // Проверяем наличие всех необходимых точек
    if (leftShoulder == null || rightShoulder == null || 
        leftHip == null || rightHip == null ||
        leftKnee == null || rightKnee == null) {
      return;
    }
    
    // Проверяем уверенность детекции
    if (leftShoulder.likelihood < 0.5 || rightShoulder.likelihood < 0.5 ||
        leftHip.likelihood < 0.5 || rightHip.likelihood < 0.5 ||
        leftKnee.likelihood < 0.5 || rightKnee.likelihood < 0.5) {
      return;
    }
    
    // Вычисляем угол в коленях (для приседаний)
    final leftKneeAngle = _calculateAngle(
      leftHip.x, leftHip.y,
      leftKnee.x, leftKnee.y,
      leftShoulder.x, leftShoulder.y,
    );
    
    final rightKneeAngle = _calculateAngle(
      rightHip.x, rightHip.y,
      rightKnee.x, rightKnee.y,
      rightShoulder.x, rightShoulder.y,
    );
    
    final averageKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;
    
    // Определяем положение (присед или стоя)
    // Угол < 140° = присед, > 160° = стоя
    final isDown = averageKneeAngle < 140;
    final isUp = averageKneeAngle > 160;
    
    // Подсчитываем повторение при переходе из нижнего положения в верхнее
    if (_isInDownPosition && isUp) {
      setState(() {
        _repCount++;
        _lastRepTime = DateTime.now();
        _feedback = 'Повторение $_repCount! Отлично!';
      });
      
      // Сохраняем повторение в сессию
      if (_currentSession != null) {
        _workoutService.addRep(
          _currentSession!,
          formScore: _formScore,
          isCorrect: _formScore > 60,
        ).then((session) {
          _currentSession = session;
        }).catchError((e) {
          print('❌ Error saving rep: $e');
        });
      }
      
      _isInDownPosition = false;
    } else if (isDown && !_isInDownPosition) {
      _isInDownPosition = true;
    }
  }

  double _calculateAngle(double x1, double y1, double x2, double y2, double x3, double y3) {
    // Вычисляем угол между тремя точками
    final dx1 = x1 - x2;
    final dy1 = y1 - y2;
    final dx2 = x3 - x2;
    final dy2 = y3 - y2;
    
    final dot = dx1 * dx2 + dy1 * dy2;
    final mag1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
    final mag2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
    
    if (mag1 == 0 || mag2 == 0) return 0;
    
    final cosAngle = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return math.acos(cosAngle) * 180 / math.pi;
  }

  void _stopExercise() async {
    _feedbackTimer?.cancel();
    _durationTimer?.cancel();
    
    // Завершаем сессию тренировки
    if (_currentSession != null) {
      try {
        final completedSession = await _workoutService.completeWorkout(_currentSession!);
        
        setState(() {
          _isRecording = false;
          _feedback = 'Тренировка сохранена! Повторений: $_repCount';
        });
        
        // Останавливаем поток изображений
        await _cameraController?.stopImageStream();
        
        // Показываем диалог с результатами
        if (mounted) {
          final shouldRestart = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => WorkoutResultsDialog(
              session: completedSession,
              repsCompleted: _repCount,
              averageFormScore: _formScore,
              workoutDuration: _workoutDuration,
            ),
          );
          
          if (shouldRestart == true) {
            // Перезапускаем тренировку
            _startExercise();
          }
        }
      } catch (e) {
        setState(() {
          _isRecording = false;
          _feedback = 'Тренировка завершена! (ошибка сохранения)';
        });
        await _cameraController?.stopImageStream();
      }
    } else {
      setState(() {
        _isRecording = false;
        _feedback = 'Тренировка завершена!';
      });
      await _cameraController?.stopImageStream();
    }
  }

  void _updateFpsCounter() {
    final now = DateTime.now();
    final timeDiff = now.difference(_lastFpsUpdate).inMilliseconds;
    
    if (timeDiff >= 1000) { // Обновляем FPS каждую секунду
      _currentFps = _frameCount * 1000.0 / timeDiff;
      _frameCount = 0;
      _lastFpsUpdate = now;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector?.close();
    _feedbackTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.nameRu),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
            onPressed: _isRecording ? _stopExercise : _startExercise,
          ),
        ],
      ),
      body: _isInitialized
          ? _buildMainInterface()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildMainInterface() {
    return Column(
      children: [
        // Камера
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRecording ? Colors.red : Colors.grey,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                children: [
                  // Превью камеры
                  if (_cameraController != null && _cameraController!.value.isInitialized)
                    Positioned.fill(
                      child: Builder(
                        builder: (context) {
                          final preview = FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController!.value.previewSize!.height,
                              height: _cameraController!.value.previewSize!.width,
                              child: CameraPreview(_cameraController!),
                            ),
                          );
                          // Камера в исходном состоянии: НЕ зеркалим превью.
                          return preview;
                        },
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  
                  // Overlay с позами
                  if (_poses.isNotEmpty)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: PosePainter(
                          poses: _poses,
                          imageSize: _inputImageSize == Size.zero
                              ? Size(
                                  _cameraController?.value.previewSize?.width ?? 480,
                                  _cameraController?.value.previewSize?.height ?? 640,
                                )
                              : _inputImageSize,
                          rotation: _inputImageRotation,
                          // Зеркалим только отрисовку "скелета"
                          mirror: _cameraController?.description.lensDirection ==
                              CameraLensDirection.front,
                        ),
                      ),
                    ),
                  
                  // Индикатор записи
                  if (_isRecording)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record, 
                                 color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('REC', 
                                 style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  
                  // Счетчик повторений (большой)
                  if (_isRecording)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$_repCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'повторений',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Кнопка переключения камеры (в углу камеры)
                  if (!_isRecording)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _switchCamera,
                            child: const Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // FPS и время тренировки
                  if (_isRecording)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'FPS: ${_currentFps.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(_workoutDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Статистика и управление
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Статистика
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Повторения', '$_repCount', Icons.repeat),
                    _buildStatCard('Техника', '${_formScore.toInt()}%', Icons.star),
                    _buildStatCard('Время', _formatDuration(_workoutDuration), Icons.timer),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Обратная связь
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? Colors.green.shade50 
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isRecording 
                          ? Colors.green.shade200 
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Text(
                    _feedback,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Кнопки управления
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Кнопка "Начать"
                      _buildControlButton(
                        onPressed: _isRecording ? null : _startExercise,
                        icon: Icons.play_arrow,
                        label: 'Начать',
                        color: Colors.green,
                        isEnabled: !_isRecording,
                      ),
                      
                      // Кнопка "Остановить"
                      _buildControlButton(
                        onPressed: _isRecording ? _stopExercise : null,
                        icon: Icons.stop,
                        label: 'Стоп',
                        color: Colors.red,
                        isEnabled: _isRecording,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isEnabled,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isEnabled ? color : Colors.grey[300],
            borderRadius: BorderRadius.circular(28),
            boxShadow: isEnabled ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onPressed,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 100),
                scale: isEnabled ? 1.0 : 0.9,
                child: Icon(
                  icon,
                  color: isEnabled ? Colors.white : Colors.grey[600],
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isEnabled ? color : Colors.grey[600],
          ),
          child: Text(label),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentCamera = _cameraController!.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentCamera.lensDirection,
      orElse: () => currentCamera,
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.low, // Используем низкое разрешение для лучшей совместимости
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Используем YUV420 формат
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {});
    }
  }
}

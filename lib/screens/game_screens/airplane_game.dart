import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AirplaneGame extends StatefulWidget {
  const AirplaneGame({super.key});

  @override
  State<AirplaneGame> createState() => _AirplaneGameState();
}

class _AirplaneGameState extends State<AirplaneGame> {
  double airplaneX = 0.5;
  double airplaneY = 0.85;
  List<Obstacle> obstacles = [];
  int score = 0;
  int bestScore = 0;
  bool gameRunning = false;
  bool gameOver = false;
  Timer? gameTimer;
  double obstacleSpeed = 0.003;
  double obstacleSpawnRate = 0.03;
  final GlobalKey _gameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('airplane_best_score') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('airplane_best_score', bestScore);
  }

  void startGame() {
    setState(() {
      gameRunning = true;
      gameOver = false;
      score = 0;
      obstacles = [];
      airplaneX = 0.5;
      airplaneY = 0.85;
      obstacleSpeed = 0.003;
      obstacleSpawnRate = 0.03;
    });
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (gameRunning && mounted) {
        updateGame();
      }
    });
  }

  void updateGame() {
    if (!mounted) return;
    
    setState(() {
      // Spawn obstacles
      if (Random().nextDouble() < obstacleSpawnRate) {
        obstacles.add(Obstacle(
          x: Random().nextDouble() * 0.8 + 0.1,
          y: -0.05,
          size: 0.06,
        ));
      }

      // Move obstacles
      obstacles.removeWhere((obstacle) {
        obstacle.y += obstacleSpeed;
        return obstacle.y > 1.1;
      });

      // Check collision
      for (var obstacle in obstacles) {
        if (_checkCollision(airplaneX, airplaneY, obstacle)) {
          endGame();
          return;
        }
      }

      // Increase score
      score++;
      if (score % 500 == 0) {
        obstacleSpeed += 0.0005;
        obstacleSpawnRate += 0.005;
      }
    });
  }

  bool _checkCollision(double planeX, double planeY, Obstacle obstacle) {
    final planeLeft = planeX - 0.04;
    final planeRight = planeX + 0.04;
    final planeTop = planeY - 0.04;
    final planeBottom = planeY + 0.04;

    final obsLeft = obstacle.x - obstacle.size / 2;
    final obsRight = obstacle.x + obstacle.size / 2;
    final obsTop = obstacle.y - obstacle.size / 2;
    final obsBottom = obstacle.y + obstacle.size / 2;

    return planeRight > obsLeft &&
        planeLeft < obsRight &&
        planeBottom > obsTop &&
        planeTop < obsBottom;
  }

  void endGame() {
    setState(() {
      gameRunning = false;
      gameOver = true;
      if (score > bestScore) {
        bestScore = score;
        _saveBestScore();
      }
    });
    gameTimer?.cancel();
  }

  void updateAirplanePosition(double x) {
    if (gameRunning) {
      setState(() {
        airplaneX = x.clamp(0.05, 0.95);
      });
    } else if (!gameOver) {
      // Allow moving before game starts
      setState(() {
        airplaneX = x.clamp(0.05, 0.95);
      });
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Airplane Game')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Score', style: TextStyle(fontSize: 12)),
                      Text('$score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Best', style: TextStyle(fontSize: 12)),
                      Text('$bestScore', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  final renderBox = _gameKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final localPosition = details.localPosition;
                    final screenWidth = renderBox.size.width;
                    updateAirplanePosition(localPosition.dx / screenWidth);
                  }
                },
                onTap: () {
                  if (!gameRunning && !gameOver) {
                    startGame();
                  }
                },
                child: Container(
                  key: _gameKey,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightBlue[300]!, Colors.lightBlue[100]!],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Game canvas
                      CustomPaint(
                        painter: AirplanePainter(
                          airplaneX: airplaneX,
                          airplaneY: airplaneY,
                          obstacles: obstacles,
                          gameRunning: gameRunning,
                        ),
                        size: Size.infinite,
                      ),
                      // Game over overlay
                      if (gameOver)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Game Over!',
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Score: $score',
                                  style: const TextStyle(fontSize: 24, color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: startGame,
                                  child: const Text('Play Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (!gameRunning)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: Text(
                              'Tap to Start',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Swipe left/right to move'),
            ),
          ],
        ),
      ),
    );
  }
}

class Obstacle {
  double x;
  double y;
  double size;

  Obstacle({required this.x, required this.y, required this.size});
}

class AirplanePainter extends CustomPainter {
  final double airplaneX;
  final double airplaneY;
  final List<Obstacle> obstacles;
  final bool gameRunning;

  AirplanePainter({
    required this.airplaneX,
    required this.airplaneY,
    required this.obstacles,
    required this.gameRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw clouds
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.3);
    final now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 5; i++) {
      final cloudX = (now / 100 + i * 100) % (size.width + 100) - 50;
      final cloudY = 50.0 + i * 80.0;
      canvas.drawCircle(Offset(cloudX, cloudY), 20, cloudPaint);
      canvas.drawCircle(Offset(cloudX + 25, cloudY), 25, cloudPaint);
      canvas.drawCircle(Offset(cloudX + 50, cloudY), 20, cloudPaint);
    }

    // Draw obstacles
    final obstaclePaint = Paint()..color = Colors.red[900]!;
    final obstacleInnerPaint = Paint()..color = Colors.red;
    for (var obstacle in obstacles) {
      final rect = Rect.fromCenter(
        center: Offset(obstacle.x * size.width, obstacle.y * size.height),
        width: obstacle.size * size.width,
        height: obstacle.size * size.height,
      );
      canvas.drawRect(rect, obstaclePaint);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(obstacle.x * size.width, obstacle.y * size.height),
          width: obstacle.size * size.width * 0.7,
          height: obstacle.size * size.height * 0.7,
        ),
        obstacleInnerPaint,
      );
    }

    // Draw airplane
    final airplanePaint = Paint()..color = Colors.amber;
    final airplaneDetailPaint = Paint()..color = Colors.orange;
    final airplanePath = Path();
    final centerX = airplaneX * size.width;
    final centerY = airplaneY * size.height;
    airplanePath.moveTo(centerX, centerY - 20);
    airplanePath.lineTo(centerX - 20, centerY + 20);
    airplanePath.lineTo(centerX + 20, centerY + 20);
    airplanePath.close();
    canvas.drawPath(airplanePath, airplanePaint);
    canvas.drawCircle(Offset(centerX, centerY + 10), 8, airplaneDetailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

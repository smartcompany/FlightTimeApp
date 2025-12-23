import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AsteroidsGame extends StatefulWidget {
  const AsteroidsGame({super.key});

  @override
  State<AsteroidsGame> createState() => _AsteroidsGameState();
}

class _AsteroidsGameState extends State<AsteroidsGame> {
  double shipX = 0.5;
  double shipY = 0.5;
  double shipAngle = 0;
  bool rotatingLeft = false;
  bool rotatingRight = false;
  List<Bullet> bullets = [];
  List<Asteroid> asteroids = [];
  int score = 0;
  int bestScore = 0;
  bool gameRunning = false;
  bool gameOver = false;
  Timer? gameTimer;
  Timer? rotationTimer;
  DateTime? lastShootTime;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    // Load from SharedPreferences if needed
  }

  void startGame() {
    setState(() {
      gameRunning = true;
      gameOver = false;
      score = 0;
      shipX = 0.5;
      shipY = 0.5;
      shipAngle = 0;
      bullets = [];
      asteroids = [];
      for (int i = 0; i < 5; i++) {
        asteroids.add(Asteroid(
          x: Random().nextDouble(),
          y: Random().nextDouble(),
          size: 0.05,
          vx: (Random().nextDouble() - 0.5) * 0.002,
          vy: (Random().nextDouble() - 0.5) * 0.002,
        ));
      }
    });
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (gameRunning && mounted) {
        updateGame();
      }
    });
  }

  void updateGame() {
    if (!mounted) return;

    setState(() {
      // Rotate ship
      if (rotatingLeft) shipAngle -= 0.05;
      if (rotatingRight) shipAngle += 0.05;

      // Move bullets
      bullets.removeWhere((bullet) {
        bullet.x += bullet.vx;
        bullet.y += bullet.vy;
        if (bullet.x < 0 || bullet.x > 1 || bullet.y < 0 || bullet.y > 1) {
          return true;
        }
        return false;
      });

      // Move asteroids
      for (var asteroid in asteroids) {
        asteroid.x += asteroid.vx;
        asteroid.y += asteroid.vy;
        if (asteroid.x < 0) asteroid.x = 1;
        if (asteroid.x > 1) asteroid.x = 0;
        if (asteroid.y < 0) asteroid.y = 1;
        if (asteroid.y > 1) asteroid.y = 0;
      }

      // Check bullet-asteroid collision
      bullets.removeWhere((bullet) {
        for (var asteroid in asteroids.toList()) {
          final dx = bullet.x - asteroid.x;
          final dy = bullet.y - asteroid.y;
          final distance = sqrt(dx * dx + dy * dy);
          if (distance < asteroid.size) {
            asteroids.remove(asteroid);
            score += 10;
            // Spawn new asteroids
            if (asteroids.length < 10) {
              asteroids.add(Asteroid(
                x: Random().nextDouble(),
                y: Random().nextDouble(),
                size: 0.05,
                vx: (Random().nextDouble() - 0.5) * 0.002,
                vy: (Random().nextDouble() - 0.5) * 0.002,
              ));
            }
            return true;
          }
        }
        return false;
      });

      // Check ship-asteroid collision
      for (var asteroid in asteroids) {
        final dx = shipX - asteroid.x;
        final dy = shipY - asteroid.y;
        final distance = sqrt(dx * dx + dy * dy);
        if (distance < asteroid.size + 0.03) {
          endGame();
          return;
        }
      }
    });
  }

  void shoot() {
    if (!gameRunning) return;
    final now = DateTime.now();
    if (lastShootTime != null &&
        now.difference(lastShootTime!).inMilliseconds < 200) {
      return;
    }
    lastShootTime = now;
    setState(() {
      bullets.add(Bullet(
        x: shipX,
        y: shipY,
        vx: sin(shipAngle) * 0.01,
        vy: -cos(shipAngle) * 0.01,
      ));
    });
  }

  void endGame() {
    setState(() {
      gameRunning = false;
      gameOver = true;
      if (score > bestScore) {
        bestScore = score;
      }
    });
    gameTimer?.cancel();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asteroids')),
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
                      Text('$score',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Best', style: TextStyle(fontSize: 12)),
                      Text('$bestScore',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!gameRunning && !gameOver) {
                    startGame();
                  }
                },
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: AsteroidsPainter(
                        shipX: shipX,
                        shipY: shipY,
                        shipAngle: shipAngle,
                        bullets: bullets,
                        asteroids: asteroids,
                      ),
                      size: Size.infinite,
                    ),
                    if (gameOver)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Game Over!',
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 16),
                              Text('Score: $score',
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                  onPressed: startGame,
                                  child: const Text('Play Again')),
                            ],
                          ),
                        ),
                      )
                    else if (!gameRunning)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: Text('Tap to Start',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => rotatingLeft = true),
                    onTapUp: (_) => setState(() => rotatingLeft = false),
                    onTapCancel: () => setState(() => rotatingLeft = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('↺',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!gameRunning && !gameOver) {
                        startGame();
                      } else {
                        shoot();
                      }
                    },
                    child: const Text('FIRE'),
                  ),
                  GestureDetector(
                    onTapDown: (_) => setState(() => rotatingRight = true),
                    onTapUp: (_) => setState(() => rotatingRight = false),
                    onTapCancel: () => setState(() => rotatingRight = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('↻',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bullet {
  double x;
  double y;
  double vx;
  double vy;

  Bullet(
      {required this.x, required this.y, required this.vx, required this.vy});
}

class Asteroid {
  double x;
  double y;
  double size;
  double vx;
  double vy;

  Asteroid(
      {required this.x,
      required this.y,
      required this.size,
      required this.vx,
      required this.vy});
}

class AsteroidsPainter extends CustomPainter {
  final double shipX;
  final double shipY;
  final double shipAngle;
  final List<Bullet> bullets;
  final List<Asteroid> asteroids;

  AsteroidsPainter({
    required this.shipX,
    required this.shipY,
    required this.shipAngle,
    required this.bullets,
    required this.asteroids,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw stars
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y =
          (i * 23 + DateTime.now().millisecondsSinceEpoch / 10) % size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), starPaint);
    }

    // Draw bullets
    final bulletPaint = Paint()..color = Colors.cyan;
    for (var bullet in bullets) {
      canvas.drawCircle(Offset(bullet.x * size.width, bullet.y * size.height),
          3, bulletPaint);
    }

    // Draw asteroids
    final asteroidPaint = Paint()..color = Colors.grey[700]!;
    for (var asteroid in asteroids) {
      canvas.drawCircle(
        Offset(asteroid.x * size.width, asteroid.y * size.height),
        asteroid.size * size.width,
        asteroidPaint,
      );
    }

    // Draw ship
    final shipPaint = Paint()..color = Colors.white;
    final shipPath = Path();
    final centerX = shipX * size.width;
    final centerY = shipY * size.height;
    shipPath.moveTo(centerX, centerY - 15);
    shipPath.lineTo(centerX - 10, centerY + 15);
    shipPath.lineTo(centerX, centerY + 10);
    shipPath.lineTo(centerX + 10, centerY + 15);
    shipPath.close();

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(shipAngle);
    canvas.translate(-centerX, -centerY);
    canvas.drawPath(shipPath, shipPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

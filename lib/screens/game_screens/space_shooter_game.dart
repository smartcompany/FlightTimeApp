import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SpaceShooterGame extends StatefulWidget {
  const SpaceShooterGame({super.key});

  @override
  State<SpaceShooterGame> createState() => _SpaceShooterGameState();
}

class _SpaceShooterGameState extends State<SpaceShooterGame> {
  double playerX = 0.5;
  double playerY = 0.85;
  List<Bullet> bullets = [];
  List<Enemy> enemies = [];
  int score = 0;
  bool gameRunning = false;
  bool gameOver = false;
  Timer? gameTimer;
  Timer? shootTimer;
  DateTime? lastEnemySpawn;
  final GlobalKey _gameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      gameRunning = true;
      gameOver = false;
      score = 0;
      playerX = 0.5;
      playerY = 0.85;
      bullets = [];
      enemies = [];
      lastEnemySpawn = DateTime.now();
    });
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (gameRunning && mounted) {
        updateGame();
      }
    });
    shootTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (gameRunning) {
        shoot();
      }
    });
  }

  void updateGame() {
    if (!mounted) return;
    
    setState(() {
      // Spawn enemies
      if (lastEnemySpawn == null || DateTime.now().difference(lastEnemySpawn!).inMilliseconds > 1000) {
        enemies.add(Enemy(
          x: Random().nextDouble() * 0.9 + 0.05,
          y: -0.05,
          radius: 0.03,
        ));
        lastEnemySpawn = DateTime.now();
      }

      // Move bullets
      bullets.removeWhere((bullet) {
        bullet.y -= 0.015;
        if (bullet.y < 0) return true;
        
        // Check collision with enemies
        for (var enemy in enemies.toList()) {
          final dx = bullet.x - enemy.x;
          final dy = bullet.y - enemy.y;
          final distance = sqrt(dx * dx + dy * dy);
          if (distance < enemy.radius) {
            enemies.remove(enemy);
            score += 10;
            return true;
          }
        }
        return false;
      });

      // Move enemies
      enemies.removeWhere((enemy) {
        enemy.y += 0.003;
        if (enemy.y > 1.1) return true;
        
        // Check collision with player
        final dx = playerX - enemy.x;
        final dy = playerY - enemy.y;
        final distance = sqrt(dx * dx + dy * dy);
        if (distance < enemy.radius + 0.04) {
          endGame();
          return true;
        }
        return false;
      });
    });
  }

  void shoot() {
    if (!gameRunning) return;
    setState(() {
      bullets.add(Bullet(
        x: playerX,
        y: playerY - 0.05,
      ));
    });
  }

  void endGame() {
    setState(() {
      gameRunning = false;
      gameOver = true;
    });
    gameTimer?.cancel();
    shootTimer?.cancel();
  }

  void updatePlayerPosition(double x) {
    if (gameRunning) {
      setState(() {
        playerX = x.clamp(0.05, 0.95);
      });
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    shootTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Space Shooter')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Score: $score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GestureDetector(
                key: _gameKey,
                onPanUpdate: (details) {
                  final renderBox = _gameKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    updatePlayerPosition(details.localPosition.dx / renderBox.size.width);
                  }
                },
                onTap: () {
                  if (!gameRunning && !gameOver) {
                    startGame();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: SpaceShooterPainter(
                          playerX: playerX,
                          playerY: playerY,
                          bullets: bullets,
                          enemies: enemies,
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
                                const Text('Game Over!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                Text('Score: $score', style: const TextStyle(fontSize: 24, color: Colors.white)),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: startGame, child: const Text('Play Again')),
                              ],
                            ),
                          ),
                        )
                      else if (!gameRunning)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: Text('Tap to Start', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tap to shoot, swipe to move', style: TextStyle(color: Colors.white)),
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

  Bullet({required this.x, required this.y});
}

class Enemy {
  double x;
  double y;
  double radius;

  Enemy({required this.x, required this.y, required this.radius});
}

class SpaceShooterPainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final List<Bullet> bullets;
  final List<Enemy> enemies;

  SpaceShooterPainter({
    required this.playerX,
    required this.playerY,
    required this.bullets,
    required this.enemies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw stars
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23 + DateTime.now().millisecondsSinceEpoch / 10) % size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), starPaint);
    }

    // Draw bullets
    final bulletPaint = Paint()..color = Colors.cyan;
    for (var bullet in bullets) {
      canvas.drawRect(
        Rect.fromLTWH(
          bullet.x * size.width - 3,
          bullet.y * size.height - 10,
          6,
          10,
        ),
        bulletPaint,
      );
    }

    // Draw enemies
    final enemyPaint = Paint()..color = Colors.red;
    for (var enemy in enemies) {
      canvas.drawCircle(
        Offset(enemy.x * size.width, enemy.y * size.height),
        enemy.radius * size.width,
        enemyPaint,
      );
    }

    // Draw player
    final playerPaint = Paint()..color = Colors.blue;
    final playerPath = Path();
    final centerX = playerX * size.width;
    final centerY = playerY * size.height;
    playerPath.moveTo(centerX, centerY);
    playerPath.lineTo(centerX - 20, centerY + 40);
    playerPath.lineTo(centerX + 20, centerY + 40);
    playerPath.close();
    canvas.drawPath(playerPath, playerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

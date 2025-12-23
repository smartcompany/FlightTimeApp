import 'dart:async';
import 'package:flutter/material.dart';

class RunnerGame extends StatefulWidget {
  const RunnerGame({super.key});

  @override
  State<RunnerGame> createState() => _RunnerGameState();
}

class _RunnerGameState extends State<RunnerGame> {
  double playerY = 0.7;
  double playerVy = 0;
  bool isJumping = false;
  List<Obstacle> obstacles = [];
  int distance = 0;
  bool gameRunning = false;
  bool gameOver = false;
  Timer? gameTimer;
  double obstacleSpeed = 0.003;
  final GlobalKey _gameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      gameRunning = true;
      gameOver = false;
      distance = 0;
      playerY = 0.75; // 땅 위에 위치 (땅은 0.8부터, 플레이어 높이 고려)
      playerVy = 0;
      isJumping = false;
      obstacles = [];
      obstacleSpeed = 0.003;
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
      // Apply gravity
      final groundLevel = 0.75; // 땅 위 플레이어 위치
      if (isJumping || playerY < groundLevel) {
        playerVy += 0.0005;
        playerY += playerVy;
        if (playerY >= groundLevel) {
          playerY = groundLevel;
          playerVy = 0;
          isJumping = false;
        }
      }

      // Spawn obstacles
      if (obstacles.isEmpty || obstacles.last.x < 0.7) {
        obstacles.add(Obstacle(
          x: 1.0,
          y: 0.8, // 땅의 상단 위치
          width: 0.05,
          height: 0.15, // 장애물 높이
        ));
      }

      // Move obstacles
      obstacles.removeWhere((obstacle) {
        obstacle.x -= obstacleSpeed;
        if (obstacle.x < -0.1) {
          distance += 10;
          return true;
        }
        return false;
      });

      // Check collision (플레이어는 땅 위에 있음)
      final playerWidthRatio = 30.0 / 400.0; // 대략적인 플레이어 너비 비율
      final playerHeightRatio = 50.0 / 400.0; // 대략적인 플레이어 높이 비율
      final groundY = 0.8; // 땅의 상단
      
      final playerLeft = playerX;
      final playerRight = playerX + playerWidthRatio;
      final playerTop = groundY - playerHeightRatio; // 플레이어 상단
      final playerBottom = groundY; // 플레이어 하단 (땅에 닿음)
      
      for (var obstacle in obstacles) {
        final obsLeft = obstacle.x;
        final obsRight = obstacle.x + obstacle.width;
        final obsTop = obstacle.y - obstacle.height; // 장애물 상단
        final obsBottom = obstacle.y; // 장애물 하단 (땅)
        
        // 충돌 감지: 플레이어와 장애물이 겹치는지 확인
        if (playerRight > obsLeft && playerLeft < obsRight &&
            playerBottom > obsTop && playerTop < obsBottom) {
          endGame();
          return;
        }
      }

      // Increase speed
      if (distance % 100 == 0 && distance > 0) {
        obstacleSpeed += 0.0001;
      }
    });
  }

  void jump() {
    if (gameRunning && !isJumping && playerY >= 0.75) {
      setState(() {
        isJumping = true;
        playerVy = -0.015;
      });
    } else if (!gameRunning && !gameOver) {
      startGame();
    }
  }

  void endGame() {
    setState(() {
      gameRunning = false;
      gameOver = true;
    });
    gameTimer?.cancel();
  }

  double playerX = 0.2;

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Runner')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Distance: ${distance}m', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GestureDetector(
                key: _gameKey,
                onTap: jump,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightBlue[300]!, Colors.lightBlue[100]!],
                    ),
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: RunnerPainter(
                          playerX: playerX,
                          playerY: playerY,
                          obstacles: obstacles,
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
                                Text('Distance: ${distance}m', style: const TextStyle(fontSize: 24, color: Colors.white)),
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
                            child: Text('Tap to jump', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tap to jump'),
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
  double width;
  double height;

  Obstacle({required this.x, required this.y, required this.width, required this.height});
}

class RunnerPainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final List<Obstacle> obstacles;

  RunnerPainter({
    required this.playerX,
    required this.playerY,
    required this.obstacles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw ground
    final groundPaint = Paint()..color = Colors.brown;
    canvas.drawRect(
      Rect.fromLTWH(0, 0.8 * size.height, size.width, 0.2 * size.height),
      groundPaint,
    );

    // Draw obstacles (땅 위에 그리기)
    final obstaclePaint = Paint()..color = Colors.red;
    for (var obstacle in obstacles) {
      // 장애물은 땅 위에 그려짐 (y는 땅의 상단, 높이는 위로)
      canvas.drawRect(
        Rect.fromLTWH(
          obstacle.x * size.width,
          (obstacle.y - obstacle.height) * size.height, // 땅 위에서 시작
          obstacle.width * size.width,
          obstacle.height * size.height, // 위로 올라가는 높이
        ),
        obstaclePaint,
      );
    }

    // Draw player (땅 위에 그리기)
    final playerPaint = Paint()..color = Colors.blue;
    final playerWidth = 30.0;
    final playerHeight = 50.0;
    final groundY = 0.8 * size.height; // 땅의 상단
    // 플레이어의 하단이 땅에 닿도록
    canvas.drawRect(
      Rect.fromLTWH(
        playerX * size.width,
        groundY - playerHeight, // 땅 위에서 플레이어 높이만큼 위로
        playerWidth,
        playerHeight,
      ),
      playerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

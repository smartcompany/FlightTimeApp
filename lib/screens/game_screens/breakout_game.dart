import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BreakoutGame extends StatefulWidget {
  const BreakoutGame({super.key});

  @override
  State<BreakoutGame> createState() => _BreakoutGameState();
}

class _BreakoutGameState extends State<BreakoutGame> {
  double paddleX = 0.5;
  double ballX = 0.5;
  double ballY = 0.5;
  double ballVx = 0.005;
  double ballVy = -0.005;
  double baseSpeed = 0.005;
  List<Brick> bricks = [];
  int score = 0;
  int bricksDestroyed = 0;
  bool gameRunning = false;
  bool gameOver = false;
  Timer? gameTimer;
  final GlobalKey _gameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initBricks();
  }

  void initBricks() {
    bricks = [];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 8; col++) {
        bricks.add(Brick(
          x: col / 8.0 + 0.05,
          y: row / 10.0 + 0.1,
          width: 0.1,
          height: 0.03,
          color: Colors.primaries[row % Colors.primaries.length],
        ));
      }
    }
  }

  void startGame() {
    setState(() {
      gameRunning = true;
      gameOver = false;
      score = 0;
      bricksDestroyed = 0;
      baseSpeed = 0.005;
      paddleX = 0.5;
      ballX = 0.5;
      ballY = 0.7;
      final angle = (Random().nextDouble() - 0.5) * 0.5;
      ballVx = sin(angle) * baseSpeed;
      ballVy = -cos(angle) * baseSpeed;
      initBricks();
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
      // Move ball
      ballX += ballVx;
      ballY += ballVy;

      // Ball-wall collision
      if (ballX < 0.05 || ballX > 0.95) ballVx = -ballVx;
      if (ballY < 0.05) ballVy = -ballVy;

      // Ball-paddle collision
      if (ballY > 0.85 && ballY < 0.9 &&
          ballX > paddleX - 0.1 && ballX < paddleX + 0.1) {
        ballVy = -ballVy.abs();
        ballVx = (ballX - paddleX) * 0.01;
      }

      // Ball-brick collision
      bricks.removeWhere((brick) {
        if (ballX > brick.x && ballX < brick.x + brick.width &&
            ballY > brick.y && ballY < brick.y + brick.height) {
          ballVy = -ballVy;
          score += 10;
          bricksDestroyed++;
          
          // 속도 증가: 5개 벽돌마다 10%씩 빨라짐
          if (bricksDestroyed % 5 == 0) {
            baseSpeed *= 1.1;
            final currentSpeed = sqrt(ballVx * ballVx + ballVy * ballVy);
            final ratio = baseSpeed / currentSpeed;
            ballVx *= ratio;
            ballVy *= ratio;
          }
          
          return true;
        }
        return false;
      });

      // Check win
      if (bricks.isEmpty) {
        gameOver = true;
        gameRunning = false;
        gameTimer?.cancel();
      }

      // Check lose
      if (ballY > 1.0) {
        gameOver = true;
        gameRunning = false;
        gameTimer?.cancel();
      }
    });
  }

  void updatePaddlePosition(double x) {
    if (gameRunning) {
      setState(() {
        paddleX = x.clamp(0.1, 0.9);
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
      appBar: AppBar(title: const Text('Breakout')),
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
                    updatePaddlePosition(details.localPosition.dx / renderBox.size.width);
                  }
                },
                onTap: () {
                  if (!gameRunning && !gameOver) {
                    startGame();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[900]),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: BreakoutPainter(
                          paddleX: paddleX,
                          ballX: ballX,
                          ballY: ballY,
                          bricks: bricks,
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
                                Text(
                                  bricks.isEmpty ? 'You Win!' : 'Game Over!',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
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
              child: Text('Swipe to move paddle'),
            ),
          ],
        ),
      ),
    );
  }
}

class Brick {
  double x;
  double y;
  double width;
  double height;
  Color color;

  Brick({required this.x, required this.y, required this.width, required this.height, required this.color});
}

class BreakoutPainter extends CustomPainter {
  final double paddleX;
  final double ballX;
  final double ballY;
  final List<Brick> bricks;

  BreakoutPainter({
    required this.paddleX,
    required this.ballX,
    required this.ballY,
    required this.bricks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw bricks
    for (var brick in bricks) {
      final paint = Paint()..color = brick.color;
      canvas.drawRect(
        Rect.fromLTWH(
          brick.x * size.width,
          brick.y * size.height,
          brick.width * size.width,
          brick.height * size.height,
        ),
        paint,
      );
    }

    // Draw paddle
    final paddlePaint = Paint()..color = Colors.blue;
    canvas.drawRect(
      Rect.fromLTWH(
        (paddleX - 0.1) * size.width,
        0.9 * size.height,
        0.2 * size.width,
        0.02 * size.height,
      ),
      paddlePaint,
    );

    // Draw ball
    final ballPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(ballX * size.width, ballY * size.height),
      8,
      ballPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

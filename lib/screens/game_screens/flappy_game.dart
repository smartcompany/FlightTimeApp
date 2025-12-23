import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class FlappyGame extends StatefulWidget {
  const FlappyGame({super.key});

  @override
  State<FlappyGame> createState() => _FlappyGameState();
}

class _FlappyGameState extends State<FlappyGame> {
  double birdY = 0.5;
  double birdVy = 0;
  List<Pipe> pipes = [];
  int score = 0;
  int bestScore = 0;
  bool gameRunning = false;
  bool gameOver = false;
  Timer? gameTimer;
  double pipeSpeed = 0.0015; // 파이프 속도 감소
  double gravity = 0.0002; // 중력 감소

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
      birdY = 0.5;
      birdVy = 0;
      pipes = [];
      pipeSpeed = 0.002;
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
      birdVy += gravity;
      birdY += birdVy;

      // Spawn pipes
      if (pipes.isEmpty || pipes.last.x < 0.7) {
        final gap = 0.35; // 간격 증가 (더 넓은 통로)
        final gapY = 0.35 + Random().nextDouble() * 0.3; // 중앙에 더 가깝게 생성
        pipes.add(Pipe(x: 1.0, gapY: gapY, gap: gap));
      }

      // Move pipes
      pipes.removeWhere((pipe) {
        pipe.x -= pipeSpeed;
        if (pipe.x < -0.1) {
          score++;
          return true;
        }
        return false;
      });

      // Check collision
      for (var pipe in pipes) {
        if ((birdX > pipe.x && birdX < pipe.x + pipeWidth) &&
            (birdY < pipe.gapY - pipe.gap / 2 || birdY > pipe.gapY + pipe.gap / 2)) {
          endGame();
          return;
        }
      }

      // Check boundaries (더 여유있게)
      if (birdY < 0.05 || birdY > 0.95) {
        endGame();
        return;
      }
    });
  }

  void flap() {
    if (gameRunning) {
      setState(() {
        birdVy = -0.012; // 플랩 힘 증가
      });
    } else if (!gameOver) {
      startGame();
    }
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

  double birdX = 0.2;
  double pipeWidth = 0.12; // 파이프 너비 감소 (더 좁은 파이프)

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flappy Bird')),
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
                onTap: flap,
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
                        painter: FlappyPainter(
                          birdX: birdX,
                          birdY: birdY,
                          pipes: pipes,
                          pipeWidth: pipeWidth,
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
              child: Text('Tap to flap'),
            ),
          ],
        ),
      ),
    );
  }
}

class Pipe {
  double x;
  double gapY;
  double gap;

  Pipe({required this.x, required this.gapY, required this.gap});
}

class FlappyPainter extends CustomPainter {
  final double birdX;
  final double birdY;
  final List<Pipe> pipes;
  final double pipeWidth;

  FlappyPainter({
    required this.birdX,
    required this.birdY,
    required this.pipes,
    required this.pipeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw pipes
    final pipePaint = Paint()..color = Colors.green;
    for (var pipe in pipes) {
      // Top pipe
      canvas.drawRect(
        Rect.fromLTWH(
          pipe.x * size.width,
          0,
          pipeWidth * size.width,
          (pipe.gapY - pipe.gap / 2) * size.height,
        ),
        pipePaint,
      );
      // Bottom pipe
      canvas.drawRect(
        Rect.fromLTWH(
          pipe.x * size.width,
          (pipe.gapY + pipe.gap / 2) * size.height,
          pipeWidth * size.width,
          size.height - (pipe.gapY + pipe.gap / 2) * size.height,
        ),
        pipePaint,
      );
    }

    // Draw bird
    final birdPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(
      Offset(birdX * size.width, birdY * size.height),
      20,
      birdPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

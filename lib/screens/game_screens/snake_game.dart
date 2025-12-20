import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int gridSize = 20;
  List<Offset> snake = [const Offset(10, 10)];
  Offset food = const Offset(15, 15);
  Offset direction = const Offset(1, 0);
  Timer? timer;
  int score = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!isGameOver) {
        moveSnake();
      }
    });
  }

  void moveSnake() {
    setState(() {
      final newHead = snake.first + direction;
      
      if (newHead == food) {
        score++;
        generateFood();
      } else {
        snake.removeLast();
      }
      
      if (newHead.dx < 0 || newHead.dx >= gridSize ||
          newHead.dy < 0 || newHead.dy >= gridSize ||
          snake.contains(newHead)) {
        isGameOver = true;
        timer?.cancel();
        return;
      }
      
      snake.insert(0, newHead);
    });
  }

  void generateFood() {
    final random = Random();
    Offset newFood;
    do {
      newFood = Offset(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    } while (snake.contains(newFood));
    food = newFood;
  }

  void changeDirection(Offset newDirection) {
    if (direction + newDirection != Offset.zero) {
      direction = newDirection;
    }
  }

  void resetGame() {
    setState(() {
      snake = [const Offset(10, 10)];
      food = const Offset(15, 15);
      direction = const Offset(1, 0);
      score = 0;
      isGameOver = false;
    });
    startGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('뱀 게임')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('점수: $score', style: const TextStyle(fontSize: 20)),
                if (isGameOver)
                  ElevatedButton(
                    onPressed: resetGame,
                    child: const Text('다시 시작'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: CustomPaint(
                    painter: SnakePainter(snake: snake, food: food, gridSize: gridSize),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_upward, const Offset(0, -1)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDirectionButton(Icons.arrow_back, const Offset(-1, 0)),
                    _buildDirectionButton(Icons.arrow_forward, const Offset(1, 0)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_downward, const Offset(0, 1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, Offset dir) {
    return IconButton(
      icon: Icon(icon, size: 40),
      onPressed: isGameOver ? null : () => changeDirection(dir),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final int gridSize;

  SnakePainter({required this.snake, required this.food, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    
    // Draw food
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize),
      foodPaint,
    );
    
    // Draw snake
    final snakePaint = Paint()..color = Colors.green;
    for (var segment in snake) {
      canvas.drawRect(
        Rect.fromLTWH(segment.dx * cellSize, segment.dy * cellSize, cellSize, cellSize),
        snakePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


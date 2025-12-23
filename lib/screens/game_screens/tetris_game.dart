import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const int rows = 20;
  static const int cols = 10;
  
  List<List<int>> board = List.generate(rows, (_) => List.filled(cols, 0));
  Piece? currentPiece;
  Piece? nextPiece;
  int score = 0;
  int level = 1;
  int lines = 0;
  bool gameRunning = false;
  bool gamePaused = false;
  Timer? gameTimer;
  
  final List<List<List<int>>> pieces = [
    [[1,1,1,1]], // I
    [[1,1],[1,1]], // O
    [[0,1,0],[1,1,1]], // T
    [[0,1,1],[1,1,0]], // S
    [[1,1,0],[0,1,1]], // Z
    [[1,0,0],[1,1,1]], // J
    [[0,0,1],[1,1,1]]  // L
  ];
  
  final List<Color> colors = [
    const Color(0xFF00f0f0),
    const Color(0xFFf0f000),
    const Color(0xFFa000f0),
    const Color(0xFF00f000),
    const Color(0xFFf00000),
    const Color(0xFF0000f0),
    const Color(0xFFf0a000),
  ];

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      board = List.generate(rows, (_) => List.filled(cols, 0));
      score = 0;
      level = 1;
      lines = 0;
      gameRunning = true;
      gamePaused = false;
      currentPiece = createPiece();
      nextPiece = createPiece();
    });
    startGameLoop();
  }

  Piece createPiece() {
    final random = Random();
    final type = random.nextInt(pieces.length);
    return Piece(
      shape: pieces[type].map((row) => List<int>.from(row)).toList(),
      color: colors[type],
      x: cols ~/ 2 - 1,
      y: 0,
    );
  }

  bool isValidMove(Piece piece, {int dx = 0, int dy = 0, List<List<int>>? rotated}) {
    final shape = rotated ?? piece.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] != 0) {
          final newX = piece.x + x + dx;
          final newY = piece.y + y + dy;
          if (newX < 0 || newX >= cols || newY >= rows) return false;
          if (newY >= 0 && board[newY][newX] != 0) return false;
        }
      }
    }
    return true;
  }

  void movePiece(int dx, int dy) {
    if (currentPiece == null || !gameRunning || gamePaused) return;
    if (isValidMove(currentPiece!, dx: dx, dy: dy)) {
      setState(() {
        currentPiece!.x += dx;
        currentPiece!.y += dy;
      });
    }
  }

  void rotatePiece() {
    if (currentPiece == null || !gameRunning || gamePaused) return;
    final rotated = currentPiece!.shape[0].asMap().entries.map((entry) {
      return currentPiece!.shape.map((row) => row[entry.key]).toList().reversed.toList();
    }).toList();
    if (isValidMove(currentPiece!, rotated: rotated)) {
      setState(() {
        currentPiece!.shape = rotated;
      });
    }
  }

  void drop() {
    if (currentPiece == null || !gameRunning || gamePaused) return;
    if (!isValidMove(currentPiece!, dy: 1)) {
      placePiece();
    } else {
      setState(() {
        currentPiece!.y++;
      });
    }
  }

  void placePiece() {
    if (currentPiece == null) return;
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          final boardY = currentPiece!.y + y;
          final boardX = currentPiece!.x + x;
          if (boardY >= 0) {
            board[boardY][boardX] = 1; // Store color index
          }
        }
      }
    }
    clearLines();
    currentPiece = nextPiece;
    nextPiece = createPiece();
    if (!isValidMove(currentPiece!)) {
      gameOver();
    }
  }

  void clearLines() {
    int linesCleared = 0;
    for (int y = rows - 1; y >= 0; y--) {
      if (board[y].every((cell) => cell != 0)) {
        board.removeAt(y);
        board.insert(0, List.filled(cols, 0));
        linesCleared++;
        y++;
      }
    }
    if (linesCleared > 0) {
      setState(() {
        lines += linesCleared;
        score += linesCleared * 100 * level;
        final newLevel = (lines ~/ 10) + 1;
        if (newLevel != level) {
          level = newLevel;
          startGameLoop();
        }
      });
    }
  }

  void startGameLoop() {
    gameTimer?.cancel();
    final dropInterval = Duration(milliseconds: (1000 - (level - 1) * 50).clamp(100, 1000));
    gameTimer = Timer.periodic(dropInterval, (_) {
      if (gameRunning && !gamePaused) {
        drop();
      }
    });
  }

  void gameOver() {
    setState(() {
      gameRunning = false;
    });
    gameTimer?.cancel();
  }

  void pauseGame() {
    if (gameRunning) {
      setState(() {
        gamePaused = !gamePaused;
      });
      if (gamePaused) {
        gameTimer?.cancel();
      } else {
        startGameLoop();
      }
    }
  }

  void hardDrop() {
    if (!gameRunning || gamePaused) return;
    while (isValidMove(currentPiece!, dy: 1)) {
      setState(() {
        currentPiece!.y++;
      });
    }
    placePiece();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  Color getBlockColor(int value) {
    if (value == 0) return Colors.black;
    return colors[value % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tetris')),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Score', style: TextStyle(fontSize: 12)),
                            Text('$score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Level', style: TextStyle(fontSize: 12)),
                            Text('$level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Lines', style: TextStyle(fontSize: 12)),
                            Text('$lines', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AspectRatio(
                        aspectRatio: cols / rows,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                            color: Colors.black,
                          ),
                          child: CustomPaint(
                            painter: TetrisPainter(
                              board: board,
                              currentPiece: currentPiece,
                              blockSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => movePiece(-1, 0),
                          child: const Icon(Icons.arrow_back),
                        ),
                        ElevatedButton(
                          onPressed: rotatePiece,
                          child: const Text('Rotate'),
                        ),
                        ElevatedButton(
                          onPressed: () => movePiece(1, 0),
                          child: const Icon(Icons.arrow_forward),
                        ),
                        ElevatedButton(
                          onPressed: drop,
                          child: const Icon(Icons.arrow_downward),
                        ),
                        ElevatedButton(
                          onPressed: pauseGame,
                          child: Text(gamePaused ? 'Resume' : 'Pause'),
                        ),
                        ElevatedButton(
                          onPressed: hardDrop,
                          child: const Text('Drop'),
                        ),
                        if (!gameRunning)
                          ElevatedButton(
                            onPressed: startGame,
                            child: const Text('New Game'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text('Next', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.black,
                    ),
                    child: nextPiece != null
                        ? CustomPaint(
                            painter: NextPiecePainter(
                              piece: nextPiece!,
                              blockSize: 15,
                            ),
                          )
                        : null,
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

class Piece {
  List<List<int>> shape;
  Color color;
  int x;
  int y;

  Piece({required this.shape, required this.color, required this.x, required this.y});
}

class TetrisPainter extends CustomPainter {
  final List<List<int>> board;
  final Piece? currentPiece;
  final double blockSize;
  static const int cols = 10;

  TetrisPainter({required this.board, this.currentPiece, required this.blockSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / cols;
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey[800]!
      ..strokeWidth = 1;

    // Draw board
    for (int y = 0; y < board.length; y++) {
      for (int x = 0; x < board[y].length; x++) {
        if (board[y][x] != 0) {
          paint.color = const Color(0xFF00f0f0);
          final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize - 1, cellSize - 1);
          canvas.drawRect(rect, paint);
          canvas.drawRect(rect, strokePaint);
        }
      }
    }

    // Draw current piece
    if (currentPiece != null) {
      paint.color = currentPiece!.color;
      for (int y = 0; y < currentPiece!.shape.length; y++) {
        for (int x = 0; x < currentPiece!.shape[y].length; x++) {
          if (currentPiece!.shape[y][x] != 0) {
            final boardX = currentPiece!.x + x;
            final boardY = currentPiece!.y + y;
            if (boardY >= 0) {
              final rect = Rect.fromLTWH(
                boardX * cellSize,
                boardY * cellSize,
                cellSize - 1,
                cellSize - 1,
              );
              canvas.drawRect(rect, paint);
              canvas.drawRect(rect, strokePaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NextPiecePainter extends CustomPainter {
  final Piece piece;
  final double blockSize;

  NextPiecePainter({required this.piece, required this.blockSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = piece.color;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey[800]!
      ..strokeWidth = 1;

    final offsetX = (size.width / blockSize - piece.shape[0].length) / 2;
    final offsetY = (size.height / blockSize - piece.shape.length) / 2;

    for (int y = 0; y < piece.shape.length; y++) {
      for (int x = 0; x < piece.shape[y].length; x++) {
        if (piece.shape[y][x] != 0) {
          final rect = Rect.fromLTWH(
            (offsetX + x) * blockSize,
            (offsetY + y) * blockSize,
            blockSize - 1,
            blockSize - 1,
          );
          canvas.drawRect(rect, paint);
          canvas.drawRect(rect, strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

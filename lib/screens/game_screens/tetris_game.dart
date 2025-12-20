import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const int rows = 20;
  static const int cols = 10;
  List<List<int>> board = List.generate(rows, (_) => List.filled(cols, 0));
  List<List<int>> currentPiece = [];
  int currentRow = 0;
  int currentCol = 0;
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool isGameOver = false;
  bool isPaused = false;
  Timer? gameTimer;
  final Random random = Random();

  final List<List<List<int>>> pieces = [
    [[1, 1, 1, 1]], // I
    [[1, 1], [1, 1]], // O
    [[0, 1, 0], [1, 1, 1]], // T
    [[1, 1, 0], [0, 1, 1]], // S
    [[0, 1, 1], [1, 1, 0]], // Z
    [[1, 0, 0], [1, 1, 1]], // J
    [[0, 0, 1], [1, 1, 1]], // L
  ];

  @override
  void initState() {
    super.initState();
    _spawnPiece();
    _startGame();
  }

  void _startGame() {
    gameTimer = Timer.periodic(Duration(milliseconds: 500 - (level * 50).clamp(0, 400)), (timer) {
      if (!isPaused && !isGameOver) {
        _moveDown();
      }
    });
  }

  void _spawnPiece() {
    currentPiece = pieces[random.nextInt(pieces.length)];
    currentRow = 0;
    currentCol = cols ~/ 2 - currentPiece[0].length ~/ 2;
    
    if (_checkCollision(currentRow, currentCol, currentPiece)) {
      setState(() {
        isGameOver = true;
      });
      gameTimer?.cancel();
    }
  }

  bool _checkCollision(int row, int col, List<List<int>> piece) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] == 1) {
          int newRow = row + i;
          int newCol = col + j;
          if (newRow >= rows || newCol < 0 || newCol >= cols) return true;
          if (newRow >= 0 && board[newRow][newCol] == 1) return true;
        }
      }
    }
    return false;
  }

  void _placePiece() {
    for (int i = 0; i < currentPiece.length; i++) {
      for (int j = 0; j < currentPiece[i].length; j++) {
        if (currentPiece[i][j] == 1) {
          int row = currentRow + i;
          int col = currentCol + j;
          if (row >= 0) {
            board[row][col] = 1;
          }
        }
      }
    }
    _clearLines();
    _spawnPiece();
  }

  void _clearLines() {
    int cleared = 0;
    for (int i = rows - 1; i >= 0; i--) {
      if (board[i].every((cell) => cell == 1)) {
        board.removeAt(i);
        board.insert(0, List.filled(cols, 0));
        cleared++;
        i++;
      }
    }
    if (cleared > 0) {
      setState(() {
        linesCleared += cleared;
        score += cleared * 100 * level;
        level = (linesCleared ~/ 10) + 1;
      });
      gameTimer?.cancel();
      _startGame();
    }
  }

  void _moveDown() {
    if (_checkCollision(currentRow + 1, currentCol, currentPiece)) {
      _placePiece();
    } else {
      setState(() {
        currentRow++;
      });
    }
  }

  void _moveLeft() {
    if (!_checkCollision(currentRow, currentCol - 1, currentPiece)) {
      setState(() {
        currentCol--;
      });
    }
  }

  void _moveRight() {
    if (!_checkCollision(currentRow, currentCol + 1, currentPiece)) {
      setState(() {
        currentCol++;
      });
    }
  }

  List<List<int>> _rotatePiece(List<List<int>> piece) {
    int rows = piece.length;
    int cols = piece[0].length;
    List<List<int>> rotated = List.generate(cols, (_) => List.filled(rows, 0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rotated[j][rows - 1 - i] = piece[i][j];
      }
    }
    return rotated;
  }

  void _rotate() {
    List<List<int>> rotated = _rotatePiece(currentPiece);
    if (!_checkCollision(currentRow, currentCol, rotated)) {
      setState(() {
        currentPiece = rotated;
      });
    }
  }

  void _hardDrop() {
    while (!_checkCollision(currentRow + 1, currentCol, currentPiece)) {
      setState(() {
        currentRow++;
      });
    }
    _placePiece();
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _resetGame() {
    setState(() {
      board = List.generate(rows, (_) => List.filled(cols, 0));
      score = 0;
      level = 1;
      linesCleared = 0;
      isGameOver = false;
      isPaused = false;
    });
    gameTimer?.cancel();
    _spawnPiece();
    _startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('테트리스')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('점수: $score', style: const TextStyle(fontSize: 18)),
                    Text('레벨: $level', style: const TextStyle(fontSize: 16)),
                    Text('라인: $linesCleared', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                if (isGameOver)
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text('다시 시작'),
                  )
                else
                  IconButton(
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                    onPressed: _togglePause,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: cols / rows,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: CustomPaint(
                    painter: TetrisPainter(
                      board: board,
                      currentPiece: currentPiece,
                      currentRow: currentRow,
                      currentCol: currentCol,
                      rows: rows,
                      cols: cols,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isGameOver)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '게임 오버!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: isGameOver || isPaused ? null : _moveLeft,
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_right),
                  onPressed: isGameOver || isPaused ? null : _rotate,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: isGameOver || isPaused ? null : _moveDown,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: isGameOver || isPaused ? null : _moveRight,
                ),
                IconButton(
                  icon: const Icon(Icons.vertical_align_bottom),
                  onPressed: isGameOver || isPaused ? null : _hardDrop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TetrisPainter extends CustomPainter {
  final List<List<int>> board;
  final List<List<int>> currentPiece;
  final int currentRow;
  final int currentCol;
  final int rows;
  final int cols;

  TetrisPainter({
    required this.board,
    required this.currentPiece,
    required this.currentRow,
    required this.currentCol,
    required this.rows,
    required this.cols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // Draw board
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final rect = Rect.fromLTWH(
          j * cellWidth,
          i * cellHeight,
          cellWidth,
          cellHeight,
        );
        final paint = Paint()..color = board[i][j] == 1 ? Colors.cyan : Colors.grey[200]!;
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    }

    // Draw current piece
    for (int i = 0; i < currentPiece.length; i++) {
      for (int j = 0; j < currentPiece[i].length; j++) {
        if (currentPiece[i][j] == 1) {
          int row = currentRow + i;
          int col = currentCol + j;
          if (row >= 0 && row < rows && col >= 0 && col < cols) {
            final rect = Rect.fromLTWH(
              col * cellWidth,
              row * cellHeight,
              cellWidth,
              cellHeight,
            );
            final paint = Paint()..color = Colors.blue;
            canvas.drawRect(rect, paint);
            canvas.drawRect(rect, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


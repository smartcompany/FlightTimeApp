import 'package:flutter/material.dart';
import 'dart:math';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  int bestScore = 0;
  bool isGameOver = false;
  bool hasWon = false;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _resetGame();
  }

  void _loadBestScore() {
    // 실제로는 SharedPreferences 사용
    bestScore = 0;
  }

  void _resetGame() {
    setState(() {
      grid = List.generate(4, (_) => List.filled(4, 0));
      score = 0;
      isGameOver = false;
      hasWon = false;
    });
    _addRandomTile();
    _addRandomTile();
  }

  void _addRandomTile() {
    List<Point<int>> emptyCells = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) {
          emptyCells.add(Point(i, j));
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      final cell = emptyCells[random.nextInt(emptyCells.length)];
      grid[cell.x][cell.y] = random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool _canMove() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) return true;
        if (i < 3 && grid[i][j] == grid[i + 1][j]) return true;
        if (j < 3 && grid[i][j] == grid[i][j + 1]) return true;
      }
    }
    return false;
  }

  void _checkGameOver() {
    if (!_canMove()) {
      setState(() {
        isGameOver = true;
      });
      if (score > bestScore) {
        bestScore = score;
      }
    }
  }

  void _checkWin() {
    if (!hasWon) {
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (grid[i][j] == 2048) {
            setState(() {
              hasWon = true;
            });
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('축하합니다!'),
                content: const Text('2048을 달성했습니다!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        hasWon = false;
                      });
                    },
                    child: const Text('계속하기'),
                  ),
                ],
              ),
            );
            return;
          }
        }
      }
    }
  }

  List<int> _merge(List<int> line) {
    List<int> merged = [];
    bool canMerge = true;
    for (int i = 0; i < line.length; i++) {
      if (line[i] != 0) {
        if (merged.isNotEmpty && merged.last == line[i] && canMerge) {
          merged[merged.length - 1] *= 2;
          score += merged.last;
          canMerge = false;
        } else {
          merged.add(line[i]);
          canMerge = true;
        }
      }
    }
    while (merged.length < 4) {
      merged.add(0);
    }
    return merged;
  }

  void _moveLeft() {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> line = grid[i].toList();
      List<int> merged = _merge(line);
      if (line.toString() != merged.toString()) {
        grid[i] = merged;
        moved = true;
      }
    }
    if (moved) {
      _addRandomTile();
      _checkWin();
      _checkGameOver();
    }
  }

  void _moveRight() {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> line = grid[i].reversed.toList();
      List<int> merged = _merge(line).reversed.toList();
      if (line.toString() != merged.toString()) {
        grid[i] = merged;
        moved = true;
      }
    }
    if (moved) {
      _addRandomTile();
      _checkWin();
      _checkGameOver();
    }
  }

  void _moveUp() {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> line = [];
      for (int i = 0; i < 4; i++) {
        line.add(grid[i][j]);
      }
      List<int> merged = _merge(line);
      if (line.toString() != merged.toString()) {
        for (int i = 0; i < 4; i++) {
          grid[i][j] = merged[i];
        }
        moved = true;
      }
    }
    if (moved) {
      _addRandomTile();
      _checkWin();
      _checkGameOver();
    }
  }

  void _moveDown() {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> line = [];
      for (int i = 3; i >= 0; i--) {
        line.add(grid[i][j]);
      }
      List<int> merged = _merge(line).reversed.toList();
      if (line.toString() != merged.toString()) {
        for (int i = 0; i < 4; i++) {
          grid[i][j] = merged[i];
        }
        moved = true;
      }
    }
    if (moved) {
      _addRandomTile();
      _checkWin();
      _checkGameOver();
    }
  }

  Color _getTileColor(int value) {
    if (value == 0) return Colors.grey[300]!;
    final colors = {
      2: Colors.grey[100],
      4: Colors.grey[200],
      8: Colors.orange[200],
      16: Colors.orange[300],
      32: Colors.orange[400],
      64: Colors.orange[500],
      128: Colors.yellow[300],
      256: Colors.yellow[400],
      512: Colors.yellow[500],
      1024: Colors.yellow[600],
      2048: Colors.red[400],
    };
    return colors[value] ?? Colors.purple;
  }

  Color _getTextColor(int value) {
    return value <= 4 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2048')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('점수', style: TextStyle(fontSize: 14)),
                    Text('$score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('최고 점수', style: TextStyle(fontSize: 14)),
                    Text('$bestScore', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: _resetGame,
                  child: const Text('새 게임'),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      int row = index ~/ 4;
                      int col = index % 4;
                      int value = grid[row][col];
                      return Container(
                        decoration: BoxDecoration(
                          color: _getTileColor(value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            value == 0 ? '' : value.toString(),
                            style: TextStyle(
                              fontSize: value < 100 ? 24 : value < 1000 ? 20 : 16,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(value),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (isGameOver)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    '게임 오버!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text('다시 시작'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: isGameOver ? null : _moveUp,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: isGameOver ? null : _moveLeft,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: isGameOver ? null : _moveDown,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: isGameOver ? null : _moveRight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


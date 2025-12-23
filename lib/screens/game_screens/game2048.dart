import 'dart:math';
import 'package:flutter/material.dart';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  bool gameOver = false;
  bool won = false;
  Offset? _startPanPosition;
  Offset? _currentPanPosition;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      grid = List.generate(4, (_) => List.filled(4, 0));
      score = 0;
      gameOver = false;
      won = false;
      addRandomTile();
      addRandomTile();
    });
  }

  void addRandomTile() {
    final emptyCells = <Point<int>>[];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) {
          emptyCells.add(Point(i, j));
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      final random = Random();
      final cell = emptyCells[random.nextInt(emptyCells.length)];
      grid[cell.x][cell.y] = random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool move(Direction direction) {
    print('🎮 [2048] Move called: $direction');
    bool moved = false;
    List<List<int>> newGrid = List.generate(4, (_) => List.filled(4, 0));

    switch (direction) {
      case Direction.left:
        for (int i = 0; i < 4; i++) {
          final row = grid[i].where((x) => x != 0).toList();
          final newRow = <int>[];
          for (int j = 0; j < row.length; j++) {
            if (j < row.length - 1 && row[j] == row[j + 1]) {
              newRow.add(row[j] * 2);
              score += row[j] * 2;
              if (row[j] * 2 == 2048 && !won) {
                won = true;
              }
              j++;
            } else {
              newRow.add(row[j]);
            }
          }
          while (newRow.length < 4) newRow.add(0);
          newGrid[i] = newRow;
          if (!_listsEqual(grid[i], newRow)) moved = true;
        }
        break;
      case Direction.right:
        for (int i = 0; i < 4; i++) {
          final row = grid[i].reversed.where((x) => x != 0).toList();
          final newRow = <int>[];
          for (int j = 0; j < row.length; j++) {
            if (j < row.length - 1 && row[j] == row[j + 1]) {
              newRow.add(row[j] * 2);
              score += row[j] * 2;
              if (row[j] * 2 == 2048 && !won) {
                won = true;
              }
              j++;
            } else {
              newRow.add(row[j]);
            }
          }
          while (newRow.length < 4) newRow.add(0);
          newGrid[i] = newRow.reversed.toList();
          if (!_listsEqual(grid[i], newGrid[i])) moved = true;
        }
        break;
      case Direction.up:
        for (int j = 0; j < 4; j++) {
          final column =
              List.generate(4, (i) => grid[i][j]).where((x) => x != 0).toList();
          final newColumn = <int>[];
          for (int i = 0; i < column.length; i++) {
            if (i < column.length - 1 && column[i] == column[i + 1]) {
              newColumn.add(column[i] * 2);
              score += column[i] * 2;
              if (column[i] * 2 == 2048 && !won) {
                won = true;
              }
              i++;
            } else {
              newColumn.add(column[i]);
            }
          }
          while (newColumn.length < 4) newColumn.add(0);
          for (int i = 0; i < 4; i++) {
            newGrid[i][j] = newColumn[i];
          }
          final oldColumn = List.generate(4, (i) => grid[i][j]);
          if (!_listsEqual(oldColumn, newColumn)) moved = true;
        }
        break;
      case Direction.down:
        for (int j = 0; j < 4; j++) {
          final column = List.generate(4, (i) => grid[i][j])
              .reversed
              .where((x) => x != 0)
              .toList();
          final newColumn = <int>[];
          for (int i = 0; i < column.length; i++) {
            if (i < column.length - 1 && column[i] == column[i + 1]) {
              newColumn.add(column[i] * 2);
              score += column[i] * 2;
              if (column[i] * 2 == 2048 && !won) {
                won = true;
              }
              i++;
            } else {
              newColumn.add(column[i]);
            }
          }
          while (newColumn.length < 4) newColumn.add(0);
          final reversedNewColumn = newColumn.reversed.toList();
          for (int i = 0; i < 4; i++) {
            newGrid[i][j] = reversedNewColumn[i];
          }
          final oldColumn = List.generate(4, (i) => grid[i][j]);
          final reversedOldColumn = oldColumn.reversed.toList();
          if (!_listsEqual(reversedOldColumn, reversedNewColumn)) {
            moved = true;
          }
        }
        break;
    }

    print('🎮 [2048] Move completed, moved: $moved');
    if (moved) {
      setState(() {
        grid = newGrid;
      });
      addRandomTile();
      if (!canMove()) {
        setState(() {
          gameOver = true;
        });
      }
      print('🎮 [2048] Grid updated, score: $score');
      return true;
    }
    print('🎮 [2048] No move made');
    return false;
  }

  bool canMove() {
    // Check for empty cells
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) return true;
      }
    }
    // Check for possible merges
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if ((i < 3 && grid[i][j] == grid[i + 1][j]) ||
            (j < 3 && grid[i][j] == grid[i][j + 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Color getTileColor(int value) {
    if (value == 0) return Colors.grey[300]!;
    final colors = {
      2: Colors.blue[100]!,
      4: Colors.blue[200]!,
      8: Colors.blue[300]!,
      16: Colors.blue[400]!,
      32: Colors.blue[500]!,
      64: Colors.blue[600]!,
      128: Colors.blue[700]!,
      256: Colors.blue[800]!,
      512: Colors.blue[900]!,
      1024: Colors.purple[400]!,
      2048: Colors.purple[600]!,
    };
    return colors[value] ?? Colors.purple[900]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2048')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Score: $score', style: const TextStyle(fontSize: 20)),
                  ElevatedButton(
                    onPressed: startGame,
                    child: const Text('New Game'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Listener(
                  onPointerDown: (event) {
                    _startPanPosition = event.localPosition;
                    _currentPanPosition = event.localPosition;
                    print('📱 [2048] Pointer Down: ${event.localPosition}');
                  },
                  onPointerMove: (event) {
                    _currentPanPosition = event.localPosition;
                  },
                  onPointerUp: (event) {
                    print('📱 [2048] Pointer Up');
                    if (_startPanPosition == null ||
                        _currentPanPosition == null) {
                      print('📱 [2048] Start or current position is null');
                      _startPanPosition = null;
                      _currentPanPosition = null;
                      return;
                    }

                    final dx = _currentPanPosition!.dx - _startPanPosition!.dx;
                    final dy = _currentPanPosition!.dy - _startPanPosition!.dy;
                    final absDx = dx.abs();
                    final absDy = dy.abs();

                    print(
                        '📱 [2048] Swipe detected - dx: $dx, dy: $dy, absDx: $absDx, absDy: $absDy');

                    // 최소 스와이프 거리
                    if (absDx < 30 && absDy < 30) {
                      print('📱 [2048] Swipe too small, ignoring');
                      _startPanPosition = null;
                      _currentPanPosition = null;
                      return;
                    }

                    // 더 큰 방향으로 이동
                    Direction? direction;
                    if (absDx > absDy) {
                      // 수평 스와이프
                      if (dx > 0) {
                        direction = Direction.right;
                        print('📱 [2048] Moving RIGHT');
                      } else {
                        direction = Direction.left;
                        print('📱 [2048] Moving LEFT');
                      }
                    } else {
                      // 수직 스와이프
                      if (dy > 0) {
                        direction = Direction.down;
                        print('📱 [2048] Moving DOWN');
                      } else {
                        direction = Direction.up;
                        print('📱 [2048] Moving UP');
                      }
                    }

                    if (direction != null) {
                      final moved = move(direction);
                      print('📱 [2048] Move result: $moved');
                    }

                    _startPanPosition = null;
                    _currentPanPosition = null;
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellSize = (constraints.maxWidth - 24) / 4;
                          return Stack(
                            children: [
                              // 배경 그리드
                              ...List.generate(16, (index) {
                                final row = index ~/ 4;
                                final col = index % 4;
                                return Positioned(
                                  left: col * (cellSize + 8),
                                  top: row * (cellSize + 8),
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              }),
                              // 타일들
                              ...List.generate(16, (index) {
                                final row = index ~/ 4;
                                final col = index % 4;
                                final value = grid[row][col];
                                if (value == 0) return const SizedBox.shrink();
                                return Positioned(
                                  left: col * (cellSize + 8),
                                  top: row * (cellSize + 8),
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    decoration: BoxDecoration(
                                      color: getTileColor(value),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        value.toString(),
                                        style: TextStyle(
                                          fontSize: value > 1000 ? 16 : 22,
                                          fontWeight: FontWeight.bold,
                                          color: value < 8
                                              ? Colors.grey[800]
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (gameOver)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Game Over!',
                  style: TextStyle(fontSize: 24, color: Colors.red[700]),
                ),
              ),
            if (won)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'You Win!',
                  style: TextStyle(fontSize: 24, color: Colors.green[700]),
                ),
              ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Swipe to move tiles'),
            ),
          ],
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }

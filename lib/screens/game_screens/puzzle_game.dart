import 'dart:math';
import 'package:flutter/material.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  static const int gridSize = 3;
  List<List<int>> grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
  int emptyRow = 2;
  int emptyCol = 2;
  int moves = 0;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    final random = Random();
    final numbers = List.generate(8, (i) => i + 1);
    numbers.shuffle(random);
    
    setState(() {
      grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (i * gridSize + j < 8) {
            grid[i][j] = numbers[i * gridSize + j];
          }
        }
      }
      emptyRow = 2;
      emptyCol = 2;
      moves = 0;
    });
  }

  void moveTile(int row, int col) {
    if (grid[row][col] == 0) return;
    
    // Check if adjacent to empty space
    if ((row == emptyRow && (col == emptyCol - 1 || col == emptyCol + 1)) ||
        (col == emptyCol && (row == emptyRow - 1 || row == emptyRow + 1))) {
      setState(() {
        grid[emptyRow][emptyCol] = grid[row][col];
        grid[row][col] = 0;
        emptyRow = row;
        emptyCol = col;
        moves++;
        checkWin();
      });
    }
  }

  void checkWin() {
    int expected = 1;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (i == gridSize - 1 && j == gridSize - 1) {
          if (grid[i][j] != 0) return;
        } else {
          if (grid[i][j] != expected) return;
          expected++;
        }
      }
    }
    // Win!
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('You Win!'),
        content: Text('Moves: $moves'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              initGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Moves: $moves', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ElevatedButton(onPressed: initGame, child: const Text('New Game')),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ gridSize;
                      final col = index % gridSize;
                      final value = grid[row][col];
                      return GestureDetector(
                        onTap: () => moveTile(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: value == 0 ? Colors.grey[300] : Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: value == 0
                                ? const SizedBox()
                                : Text(
                                    value.toString(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tap to move tiles'),
            ),
          ],
        ),
      ),
    );
  }
}

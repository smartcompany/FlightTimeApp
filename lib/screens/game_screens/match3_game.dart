import 'dart:math';
import 'package:flutter/material.dart';

class Match3Game extends StatefulWidget {
  const Match3Game({super.key});

  @override
  State<Match3Game> createState() => _Match3GameState();
}

class _Match3GameState extends State<Match3Game> {
  static const int gridSize = 8;
  List<List<int>> grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
  int? selectedRow;
  int? selectedCol;
  int score = 0;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    final random = Random();
    setState(() {
      grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          grid[i][j] = random.nextInt(colors.length);
        }
      }
      score = 0;
      selectedRow = null;
      selectedCol = null;
    });
    // Remove initial matches
    while (findMatches().isNotEmpty) {
      removeMatches();
      fillGaps();
    }
  }

  void onCellTap(int row, int col) {
    if (selectedRow == null && selectedCol == null) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    } else if (selectedRow == row && selectedCol == col) {
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });
    } else {
      // Swap
      final temp = grid[row][col];
      grid[row][col] = grid[selectedRow!][selectedCol!];
      grid[selectedRow!][selectedCol!] = temp;
      
      final matches = findMatches();
      if (matches.isEmpty) {
        // Swap back
        final temp = grid[row][col];
        grid[row][col] = grid[selectedRow!][selectedCol!];
        grid[selectedRow!][selectedCol!] = temp;
      } else {
        setState(() {
          selectedRow = null;
          selectedCol = null;
        });
        removeMatches();
        fillGaps();
      }
    }
  }

  List<Match> findMatches() {
    final matches = <Match>[];
    // Horizontal matches
    for (int i = 0; i < gridSize; i++) {
      int count = 1;
      int start = 0;
      for (int j = 1; j < gridSize; j++) {
        if (grid[i][j] == grid[i][j - 1]) {
          count++;
        } else {
          if (count >= 3) {
            matches.add(Match(row: i, col: start, horizontal: true, length: count));
          }
          count = 1;
          start = j;
        }
      }
      if (count >= 3) {
        matches.add(Match(row: i, col: start, horizontal: true, length: count));
      }
    }
    // Vertical matches
    for (int j = 0; j < gridSize; j++) {
      int count = 1;
      int start = 0;
      for (int i = 1; i < gridSize; i++) {
        if (grid[i][j] == grid[i - 1][j]) {
          count++;
        } else {
          if (count >= 3) {
            matches.add(Match(row: start, col: j, horizontal: false, length: count));
          }
          count = 1;
          start = i;
        }
      }
      if (count >= 3) {
        matches.add(Match(row: start, col: j, horizontal: false, length: count));
      }
    }
    return matches;
  }

  void removeMatches() {
    final matches = findMatches();
    for (var match in matches) {
      if (match.horizontal) {
        for (int j = 0; j < match.length; j++) {
          grid[match.row][match.col + j] = -1;
        }
      } else {
        for (int i = 0; i < match.length; i++) {
          grid[match.row + i][match.col] = -1;
        }
      }
      score += match.length * 10;
    }
    setState(() {});
  }

  void fillGaps() {
    final random = Random();
    // Drop gems
    for (int j = 0; j < gridSize; j++) {
      int writeIndex = gridSize - 1;
      for (int i = gridSize - 1; i >= 0; i--) {
        if (grid[i][j] != -1) {
          grid[writeIndex][j] = grid[i][j];
          if (writeIndex != i) grid[i][j] = -1;
          writeIndex--;
        }
      }
      // Fill empty spaces
      for (int i = writeIndex; i >= 0; i--) {
        grid[i][j] = random.nextInt(colors.length);
      }
    }
    setState(() {});
    // Check for new matches
    if (findMatches().isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        removeMatches();
        fillGaps();
      });
    }
  }

  void showHowToPlay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Match 3 or more gems of the same color!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('1. Tap a gem to select it'),
              Text('2. Tap an adjacent gem to swap'),
              Text('3. Match 3 or more in a row to score'),
              Text('4. Matched gems will disappear'),
              Text('5. New gems will fall from the top'),
              SizedBox(height: 8),
              Text(
                'Tip: Look for opportunities to create matches!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match 3'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: showHowToPlay,
            tooltip: 'How to Play',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Score: $score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ gridSize;
                      final col = index % gridSize;
                      final isSelected = selectedRow == row && selectedCol == col;
                      return GestureDetector(
                        onTap: () => onCellTap(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors[grid[row][col]],
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: isSelected ? 3 : 0,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Tap a gem to select, then tap an adjacent gem to swap',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Match 3 or more of the same color to score points!',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
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

class Match {
  int row;
  int col;
  bool horizontal;
  int length;

  Match({required this.row, required this.col, required this.horizontal, required this.length});
}

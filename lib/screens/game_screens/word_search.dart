import 'dart:math';
import 'package:flutter/material.dart';

class WordSearch extends StatefulWidget {
  const WordSearch({super.key});

  @override
  State<WordSearch> createState() => _WordSearchState();
}

class _WordSearchState extends State<WordSearch> {
  final List<String> words = ['비행', '하늘', '구름', '태양'];
  List<List<String>> grid = [];
  List<String> foundWords = [];
  int gridSize = 10;
  Set<int> selectedCells = {};
  int? startCell;

  @override
  void initState() {
    super.initState();
    generateGrid();
  }

  void generateGrid() {
    final random = Random();
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));

    // Fill with random letters
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        grid[i][j] = String.fromCharCode(0xAC00 + random.nextInt(11172));
      }
    }

    // Place words
    for (var word in words) {
      placeWord(word, random);
    }

    setState(() {
      foundWords = [];
      selectedCells = {};
    });
  }

  void placeWord(String word, Random random) {
    bool placed = false;
    int attempts = 0;

    while (!placed && attempts < 100) {
      int row = random.nextInt(gridSize);
      int col = random.nextInt(gridSize);
      int direction = random.nextInt(8);

      int dr = [0, 0, 1, -1, 1, -1, 1, -1][direction];
      int dc = [1, -1, 0, 0, 1, -1, -1, 1][direction];

      if (row + dr * (word.length - 1) >= 0 &&
          row + dr * (word.length - 1) < gridSize &&
          col + dc * (word.length - 1) >= 0 &&
          col + dc * (word.length - 1) < gridSize) {
        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          int r = row + dr * i;
          int c = col + dc * i;
          if (grid[r][c] != '' && grid[r][c] != word[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            grid[row + dr * i][col + dc * i] = word[i];
          }
          placed = true;
        }
      }
      attempts++;
    }
  }

  void onCellTap(int index) {
    if (startCell == null) {
      setState(() {
        startCell = index;
        selectedCells = {index};
      });
    } else {
      int startRow = startCell! ~/ gridSize;
      int startCol = startCell! % gridSize;
      int endRow = index ~/ gridSize;
      int endCol = index % gridSize;

      int dr = endRow - startRow;
      int dc = endCol - startCol;

      if (dr != 0 && dc != 0 && dr.abs() != dc.abs()) {
        // Not a straight line
        setState(() {
          startCell = index;
          selectedCells = {index};
        });
        return;
      }

      int length = max(dr.abs() + dc.abs(), 1);
      Set<int> newSelection = {};

      for (int i = 0; i <= length; i++) {
        int r = startRow + (dr == 0 ? 0 : (dr > 0 ? i : -i));
        int c = startCol + (dc == 0 ? 0 : (dc > 0 ? i : -i));
        newSelection.add(r * gridSize + c);
      }

      String selectedWord = newSelection.map((idx) {
        int row = idx ~/ gridSize;
        int col = idx % gridSize;
        return grid[row][col];
      }).join('');

      setState(() {
        selectedCells = newSelection;
      });

      if (words.contains(selectedWord) && !foundWords.contains(selectedWord)) {
        setState(() {
          foundWords.add(selectedWord);
          selectedCells = {};
          startCell = null;
        });

        if (foundWords.length == words.length) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('축하합니다!'),
              content: const Text('모든 단어를 찾았습니다!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    generateGrid();
                  },
                  child: const Text('다시 시작'),
                ),
              ],
            ),
          );
        }
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              selectedCells = {};
              startCell = null;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단어 찾기')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '찾을 단어: ${words.join(', ')}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '찾은 단어: ${foundWords.join(', ')}',
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
                Text(
                  '${foundWords.length} / ${words.length}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;
                      bool isSelected = selectedCells.contains(index);

                      return GestureDetector(
                        onTap: () => onCellTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.yellow : Colors.white,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              grid[row][col],
                              style: const TextStyle(fontSize: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: generateGrid,
              child: const Text('새 게임'),
            ),
          ),
        ],
      ),
    );
  }
}

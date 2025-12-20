import 'dart:math';
import 'package:flutter/material.dart';

class NumberPuzzle extends StatefulWidget {
  const NumberPuzzle({super.key});

  @override
  State<NumberPuzzle> createState() => _NumberPuzzleState();
}

class _NumberPuzzleState extends State<NumberPuzzle> {
  List<List<int>> board = [];
  int emptyRow = 3;
  int emptyCol = 3;
  int moves = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<int> numbers = List.generate(15, (i) => i + 1);
    numbers.shuffle(Random());
    
    setState(() {
      board = [];
      for (int i = 0; i < 4; i++) {
        List<int> row = [];
        for (int j = 0; j < 4; j++) {
          if (i * 4 + j < 15) {
            row.add(numbers[i * 4 + j]);
          } else {
            row.add(0); // Empty space
          }
        }
        board.add(row);
      }
      emptyRow = 3;
      emptyCol = 3;
      moves = 0;
    });
  }

  void moveTile(int row, int col) {
    if (board[row][col] == 0) return;

    // Check if adjacent to empty space
    if ((row == emptyRow && (col == emptyCol - 1 || col == emptyCol + 1)) ||
        (col == emptyCol && (row == emptyRow - 1 || row == emptyRow + 1))) {
      setState(() {
        board[emptyRow][emptyCol] = board[row][col];
        board[row][col] = 0;
        emptyRow = row;
        emptyCol = col;
        moves++;
        checkWin();
      });
    }
  }

  void checkWin() {
    int expected = 1;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (i == 3 && j == 3) {
          if (board[i][j] != 0) return;
        } else {
          if (board[i][j] != expected) return;
          expected++;
        }
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('축하합니다!'),
        content: Text('$moves번의 이동으로 완료했습니다!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              initializeGame();
            },
            child: const Text('다시 시작'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('숫자 퍼즐')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('이동 횟수: $moves', style: const TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: initializeGame,
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
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      int row = index ~/ 4;
                      int col = index % 4;
                      int value = board[row][col];
                      
                      return GestureDetector(
                        onTap: () => moveTile(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: value == 0 ? Colors.grey[200] : Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Center(
                            child: value == 0
                                ? const SizedBox()
                                : Text(
                                    value.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
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
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

/// 스도쿠 게임 - 서버에서 다운로드 가능한 게임 예시
class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  List<List<int?>> board = List.generate(9, (_) => List.filled(9, null));
  int selectedRow = -1;
  int selectedCol = -1;
  int score = 0;
  int mistakes = 0;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    // 간단한 스도쿠 퍼즐 생성 (실제로는 더 복잡한 로직 필요)
    setState(() {
      board = List.generate(9, (_) => List.filled(9, null));
      // 예시로 일부 숫자만 채움
      board[0][0] = 5;
      board[0][4] = 3;
      board[1][1] = 7;
      board[2][2] = 1;
      board[3][3] = 9;
      board[4][4] = 2;
      board[5][5] = 8;
      board[6][6] = 4;
      board[7][7] = 6;
      board[8][8] = 3;
    });
  }

  bool _isValid(int row, int col, int value) {
    // 행 체크
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == value && i != col) return false;
    }
    // 열 체크
    for (int i = 0; i < 9; i++) {
      if (board[i][col] == value && i != row) return false;
    }
    // 3x3 박스 체크
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if (board[i][j] == value && (i != row || j != col)) return false;
      }
    }
    return true;
  }

  void _selectCell(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void _placeNumber(int number) {
    if (selectedRow == -1 || selectedCol == -1) return;
    if (board[selectedRow][selectedCol] != null) return;

    setState(() {
      if (_isValid(selectedRow, selectedCol, number)) {
        board[selectedRow][selectedCol] = number;
        score++;
      } else {
        mistakes++;
      }
      _checkWin();
    });
  }

  void _checkWin() {
    bool isComplete = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == null) {
          isComplete = false;
          break;
        }
      }
      if (!isComplete) break;
    }

    if (isComplete) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('축하합니다!'),
          content: Text('점수: $score, 실수: $mistakes'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _generatePuzzle();
                setState(() {
                  score = 0;
                  mistakes = 0;
                });
              },
              child: const Text('다시 시작'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스도쿠')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('점수: $score', style: const TextStyle(fontSize: 18)),
                Text('실수: $mistakes', style: const TextStyle(fontSize: 18)),
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
                      crossAxisCount: 9,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;
                      bool isSelected = selectedRow == row && selectedCol == col;
                      bool isBoxBorder = (row % 3 == 0 && row > 0) || (col % 3 == 0 && col > 0);

                      return GestureDetector(
                        onTap: () => _selectCell(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[200] : Colors.white,
                            border: Border.all(
                              color: isBoxBorder ? Colors.black : Colors.grey,
                              width: isBoxBorder ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              board[row][col]?.toString() ?? '',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: board[row][col] != null ? Colors.black : Colors.blue,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(9, (index) {
                return ElevatedButton(
                  onPressed: () => _placeNumber(index + 1),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 50),
                  ),
                  child: Text('${index + 1}'),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


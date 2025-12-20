import 'package:flutter/material.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<List<String?>> board = List.generate(3, (_) => List.filled(3, null));
  bool isXTurn = true;
  String? winner;
  int xWins = 0;
  int oWins = 0;
  int draws = 0;

  void makeMove(int row, int col) {
    if (board[row][col] != null || winner != null) return;

    setState(() {
      board[row][col] = isXTurn ? 'X' : 'O';
      checkWinner();
      if (winner == null) {
        isXTurn = !isXTurn;
      }
    });
  }

  void checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != null &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        winner = board[i][0];
        if (winner == 'X') xWins++;
        if (winner == 'O') oWins++;
        return;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != null &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        winner = board[0][i];
        if (winner == 'X') xWins++;
        if (winner == 'O') oWins++;
        return;
      }
    }

    // Check diagonals
    if (board[0][0] != null &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      winner = board[0][0];
      if (winner == 'X') xWins++;
      if (winner == 'O') oWins++;
      return;
    }

    if (board[0][2] != null &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      winner = board[0][2];
      if (winner == 'X') xWins++;
      if (winner == 'O') oWins++;
      return;
    }

    // Check for draw
    if (board.every((row) => row.every((cell) => cell != null)) && winner == null) {
      winner = 'Draw';
      draws++;
    }
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, null));
      isXTurn = true;
      winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('틱택토')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  winner == null
                      ? '${isXTurn ? 'X' : 'O'} 차례'
                      : winner == 'Draw'
                          ? '무승부!'
                          : '$winner 승리!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('X: $xWins'),
                    Text('O: $oWins'),
                    Text('무승부: $draws'),
                  ],
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
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      int row = index ~/ 3;
                      int col = index % 3;
                      return GestureDetector(
                        onTap: () => makeMove(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              board[row][col] ?? '',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: board[row][col] == 'X' ? Colors.blue : Colors.red,
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
            child: ElevatedButton(
              onPressed: resetGame,
              child: const Text('다시 시작'),
            ),
          ),
        ],
      ),
    );
  }
}


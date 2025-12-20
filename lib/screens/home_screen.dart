import 'package:flutter/material.dart';
import 'game_screens/snake_game.dart';
import 'game_screens/tic_tac_toe.dart';
import 'game_screens/memory_game.dart';
import 'game_screens/number_puzzle.dart';
import 'game_screens/rock_paper_scissors.dart';
import 'game_screens/hangman_game.dart';
import 'game_screens/quiz_game.dart';
import 'game_screens/reaction_test.dart';
import 'game_screens/color_match.dart';
import 'game_screens/word_search.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Time Games'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildGameCard(context, '뱀 게임', Icons.gamepad, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SnakeGame()));
          }),
          _buildGameCard(context, '틱택토', Icons.grid_3x3, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TicTacToe()));
          }),
          _buildGameCard(context, '기억력 게임', Icons.memory, Colors.purple, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGame()));
          }),
          _buildGameCard(context, '숫자 퍼즐', Icons.numbers, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NumberPuzzle()));
          }),
          _buildGameCard(context, '가위바위보', Icons.handshake, Colors.red, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RockPaperScissors()));
          }),
          _buildGameCard(context, '행맨', Icons.text_fields, Colors.teal, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HangmanGame()));
          }),
          _buildGameCard(context, '퀴즈', Icons.quiz, Colors.indigo, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizGame()));
          }),
          _buildGameCard(context, '반응속도', Icons.timer, Colors.amber, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReactionTest()));
          }),
          _buildGameCard(context, '색깔 맞추기', Icons.palette, Colors.pink, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorMatch()));
          }),
          _buildGameCard(context, '단어 찾기', Icons.search, Colors.cyan, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WordSearch()));
          }),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}


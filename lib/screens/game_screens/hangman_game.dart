import 'dart:math';
import 'package:flutter/material.dart';

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final List<String> words = ['비행기', '하늘', '구름', '태양', '별', '달', '바다', '산'];
  String currentWord = '';
  List<String> guessedLetters = [];
  List<String> wordLetters = [];
  int wrongGuesses = 0;
  final int maxWrongGuesses = 6;
  bool gameWon = false;
  bool gameLost = false;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    final random = Random();
    currentWord = words[random.nextInt(words.length)];
    wordLetters = currentWord.split('');
    guessedLetters = [];
    wrongGuesses = 0;
    gameWon = false;
    gameLost = false;
  }

  void guessLetter(String letter) {
    if (guessedLetters.contains(letter) || gameWon || gameLost) return;

    setState(() {
      guessedLetters.add(letter);
      
      if (!wordLetters.contains(letter)) {
        wrongGuesses++;
        if (wrongGuesses >= maxWrongGuesses) {
          gameLost = true;
        }
      } else {
        if (wordLetters.every((l) => guessedLetters.contains(l))) {
          gameWon = true;
        }
      }
    });
  }

  String getDisplayWord() {
    return wordLetters.map((letter) => guessedLetters.contains(letter) ? letter : '_').join(' ');
  }

  String getHangmanImage() {
    if (wrongGuesses == 0) return '     \n     \n     \n     \n     ';
    if (wrongGuesses == 1) return '  |  \n  |  \n  |  \n  |  \n  |  ';
    if (wrongGuesses == 2) return '  |  \n  |  \n  O  \n  |  \n  |  ';
    if (wrongGuesses == 3) return '  |  \n  |  \n  O  \n /|  \n  |  ';
    if (wrongGuesses == 4) return '  |  \n  |  \n  O  \n /|\\ \n  |  ';
    if (wrongGuesses == 5) return '  |  \n  |  \n  O  \n /|\\ \n /   ';
    return '  |  \n  |  \n  O  \n /|\\ \n / \\ ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('행맨')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  getDisplayWord(),
                  style: const TextStyle(fontSize: 32, letterSpacing: 4),
                ),
                const SizedBox(height: 16),
                Text(
                  '틀린 횟수: $wrongGuesses / $maxWrongGuesses',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getHangmanImage(),
                    style: const TextStyle(fontSize: 24, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 32),
                  if (gameWon)
                    Column(
                      children: [
                        const Text('축하합니다!', style: TextStyle(fontSize: 24, color: Colors.green)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: startNewGame,
                          child: const Text('다시 시작'),
                        ),
                      ],
                    ),
                  if (gameLost)
                    Column(
                      children: [
                        const Text('게임 오버!', style: TextStyle(fontSize: 24, color: Colors.red)),
                        Text('단어: $currentWord', style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: startNewGame,
                          child: const Text('다시 시작'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: 'ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎ'.split('').map((letter) {
                return ElevatedButton(
                  onPressed: (gameWon || gameLost) ? null : () => guessLetter(letter),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: guessedLetters.contains(letter)
                        ? (wordLetters.contains(letter) ? Colors.green : Colors.red)
                        : null,
                  ),
                  child: Text(letter),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


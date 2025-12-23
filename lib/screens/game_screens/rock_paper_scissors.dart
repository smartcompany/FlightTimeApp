import 'dart:math';
import 'package:flutter/material.dart';

class RockPaperScissors extends StatefulWidget {
  const RockPaperScissors({super.key});

  @override
  State<RockPaperScissors> createState() => _RockPaperScissorsState();
}

class _RockPaperScissorsState extends State<RockPaperScissors> {
  String? playerChoice;
  String? computerChoice;
  String? result;
  int playerScore = 0;
  int computerScore = 0;
  final Random random = Random();

  void play(String choice) {
    setState(() {
      playerChoice = choice;
      List<String> options = ['바위', '보', '가위'];
      computerChoice = options[random.nextInt(3)];

      result = determineWinner(choice, computerChoice!);
      if (result == '승리!') playerScore++;
      if (result == '패배!') computerScore++;
    });
  }

  String determineWinner(String player, String computer) {
    if (player == computer) return '무승부!';

    if ((player == '바위' && computer == '가위') ||
        (player == '보' && computer == '바위') ||
        (player == '가위' && computer == '보')) {
      return '승리!';
    }

    return '패배!';
  }

  IconData getIcon(String choice) {
    switch (choice) {
      case '바위':
        return Icons.panorama_fish_eye;
      case '보':
        return Icons.back_hand;
      case '가위':
        return Icons.content_cut;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가위바위보')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('나',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('$playerScore',
                          style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('컴퓨터',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('$computerScore',
                          style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (playerChoice != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Icon(getIcon(playerChoice!),
                                size: 80, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(playerChoice!,
                                style: const TextStyle(fontSize: 20)),
                            const Text('나', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const Text('VS',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        Column(
                          children: [
                            Icon(getIcon(computerChoice!),
                                size: 80, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(computerChoice!,
                                style: const TextStyle(fontSize: 20)),
                            const Text('컴퓨터', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      result ?? '',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: result == '승리!'
                            ? Colors.green
                            : result == '패배!'
                                ? Colors.red
                                : Colors.grey,
                      ),
                    ),
                  ] else
                    const Text('선택하세요!', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChoiceButton('바위', Icons.panorama_fish_eye),
                  _buildChoiceButton('보', Icons.back_hand),
                  _buildChoiceButton('가위', Icons.content_cut),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    playerScore = 0;
                    computerScore = 0;
                    playerChoice = null;
                    computerChoice = null;
                    result = null;
                  });
                },
                child: const Text('점수 초기화'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String choice, IconData icon) {
    return ElevatedButton(
      onPressed: () => play(choice),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
      ),
      child: Icon(icon, size: 40),
    );
  }
}

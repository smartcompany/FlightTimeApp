import 'dart:math';
import 'package:flutter/material.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<int> cards = [];
  List<bool> flipped = [];
  List<bool> matched = [];
  int? firstCard;
  int? secondCard;
  int moves = 0;
  int pairsFound = 0;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<int> cardValues = List.generate(8, (index) => index ~/ 2);
    cardValues.shuffle(Random());
    setState(() {
      cards = cardValues;
      flipped = List.filled(16, false);
      matched = List.filled(16, false);
      firstCard = null;
      secondCard = null;
      moves = 0;
      pairsFound = 0;
      isProcessing = false;
    });
  }

  void flipCard(int index) {
    if (flipped[index] || matched[index] || isProcessing) return;

    setState(() {
      flipped[index] = true;
      if (firstCard == null) {
        firstCard = index;
      } else if (secondCard == null) {
        secondCard = index;
        moves++;
        checkMatch();
      }
    });
  }

  void checkMatch() {
    isProcessing = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        if (cards[firstCard!] == cards[secondCard!]) {
          matched[firstCard!] = true;
          matched[secondCard!] = true;
          pairsFound++;
        } else {
          flipped[firstCard!] = false;
          flipped[secondCard!] = false;
        }
        firstCard = null;
        secondCard = null;
        isProcessing = false;

        if (pairsFound == 8) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('축하합니다!'),
              content: Text('$moves번의 시도로 완료했습니다!'),
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
      });
    });
  }

  Color getCardColor(int value) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[value];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기억력 게임')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('시도: $moves', style: const TextStyle(fontSize: 18)),
                Text('찾은 쌍: $pairsFound/8', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => flipCard(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: matched[index]
                            ? getCardColor(cards[index])
                            : flipped[index]
                                ? getCardColor(cards[index])
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: matched[index] || flipped[index]
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 40,
                              )
                            : const Icon(Icons.help_outline, size: 40),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: initializeGame,
              child: const Text('다시 시작'),
            ),
          ),
        ],
      ),
    );
  }
}


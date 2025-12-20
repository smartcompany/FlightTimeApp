import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ReactionTest extends StatefulWidget {
  const ReactionTest({super.key});

  @override
  State<ReactionTest> createState() => _ReactionTestState();
}

class _ReactionTestState extends State<ReactionTest> {
  bool isWaiting = false;
  bool canClick = false;
  DateTime? startTime;
  List<int> reactionTimes = [];
  Timer? timer;
  String displayText = '시작하려면 클릭하세요';
  Color backgroundColor = Colors.blue;

  void startTest() {
    if (isWaiting) return;

    setState(() {
      isWaiting = true;
      canClick = false;
      displayText = '대기 중...';
      backgroundColor = Colors.red;
    });

    // Random delay between 2-5 seconds
    final delay = Random().nextInt(3000) + 2000;
    timer = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          canClick = true;
          displayText = '지금 클릭!';
          backgroundColor = Colors.green;
          startTime = DateTime.now();
        });
      }
    });
  }

  void recordReaction() {
    if (!canClick) {
      // Clicked too early
      setState(() {
        displayText = '너무 빨랐습니다! 다시 시작하세요.';
        backgroundColor = Colors.orange;
        isWaiting = false;
        canClick = false;
      });
      timer?.cancel();
      return;
    }

    final reactionTime = DateTime.now().difference(startTime!).inMilliseconds;
    setState(() {
      reactionTimes.add(reactionTime);
      displayText = '반응 시간: ${reactionTime}ms';
      backgroundColor = Colors.blue;
      isWaiting = false;
      canClick = false;
    });
    timer?.cancel();
  }

  void reset() {
    timer?.cancel();
    setState(() {
      isWaiting = false;
      canClick = false;
      displayText = '시작하려면 클릭하세요';
      backgroundColor = Colors.blue;
    });
  }

  double getAverageReactionTime() {
    if (reactionTimes.isEmpty) return 0;
    return reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('반응속도 테스트')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (reactionTimes.isNotEmpty) ...[
                  Text(
                    '평균: ${getAverageReactionTime().toStringAsFixed(0)}ms',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '최고 기록: ${reactionTimes.reduce((a, b) => a < b ? a : b)}ms',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '시도 횟수: ${reactionTimes.length}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: canClick ? recordReaction : startTest,
              child: Container(
                width: double.infinity,
                color: backgroundColor,
                child: Center(
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: reset,
                  child: const Text('초기화'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      reactionTimes.clear();
                    });
                  },
                  child: const Text('기록 지우기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


import 'dart:math';
import 'package:flutter/material.dart';

class ColorMatch extends StatefulWidget {
  const ColorMatch({super.key});

  @override
  State<ColorMatch> createState() => _ColorMatchState();
}

class _ColorMatchState extends State<ColorMatch> {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  final List<String> colorNames = [
    '빨강',
    '파랑',
    '초록',
    '노랑',
    '주황',
    '보라',
  ];

  Color? targetColor;
  String? targetColorName;
  int score = 0;
  int level = 1;
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    final random = Random();
    final colorIndex = random.nextInt(colors.length);
    final nameIndex = random.nextInt(colorNames.length);

    setState(() {
      targetColor = colors[colorIndex];
      targetColorName = colorNames[nameIndex];
      showResult = false;
    });
  }

  void checkAnswer(Color selectedColor, String selectedName) {
    final correct =
        selectedColor == targetColor && selectedName == targetColorName;

    setState(() {
      showResult = true;
      isCorrect = correct;
      if (correct) {
        score++;
        if (score % 5 == 0) {
          level++;
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        generateQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('색깔 맞추기')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('점수: $score', style: const TextStyle(fontSize: 20)),
                Text('레벨: $level', style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (targetColor != null && targetColorName != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: targetColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '색깔 이름: $targetColorName',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '이 색깔을 선택하세요',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      if (showResult) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCorrect ? '정답!' : '오답!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 180,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: showResult
                        ? null
                        : () => checkAnswer(colors[index], colorNames[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          colorNames[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

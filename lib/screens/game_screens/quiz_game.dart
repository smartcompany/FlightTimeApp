import 'dart:math';
import 'package:flutter/material.dart';

class QuizGame extends StatefulWidget {
  const QuizGame({super.key});

  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': '지구에서 가장 가까운 별은?',
      'options': ['태양', '달', '화성', '금성'],
      'correct': 0,
    },
    {
      'question': '비행기가 처음 발명된 연도는?',
      'options': ['1900년', '1903년', '1910년', '1920년'],
      'correct': 1,
    },
    {
      'question': '한국의 수도는?',
      'options': ['부산', '서울', '대구', '인천'],
      'correct': 1,
    },
    {
      'question': '가장 큰 대륙은?',
      'options': ['아프리카', '아시아', '유럽', '북미'],
      'correct': 1,
    },
    {
      'question': '1+1은?',
      'options': ['1', '2', '3', '4'],
      'correct': 1,
    },
  ];

  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  int? selectedAnswer;

  @override
  void initState() {
    super.initState();
    questions.shuffle(Random());
  }

  void selectAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedAnswer = index;
      answered = true;
      if (index == questions[currentQuestion]['correct']) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        answered = false;
        selectedAnswer = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('퀴즈 완료!'),
          content: Text('점수: $score / ${questions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetQuiz();
              },
              child: const Text('다시 시작'),
            ),
          ],
        ),
      );
    }
  }

  void resetQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      answered = false;
      selectedAnswer = null;
      questions.shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('문제가 없습니다.')));
    }

    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈 게임')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('문제 ${currentQuestion + 1} / ${questions.length}'),
                Text('점수: $score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    question['question'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(question['options'].length, (index) {
                    final isCorrect = index == question['correct'];
                    final isSelected = selectedAnswer == index;
                    Color? color;

                    if (answered) {
                      if (isCorrect) {
                        color = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        color = Colors.red;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => selectAnswer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: Text(
                            question['options'][index],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


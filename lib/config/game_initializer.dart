import 'package:flutter/material.dart';
import '../services/game_registry.dart';
import '../games/base_game_wrapper.dart';
import '../screens/game_screens/snake_game.dart';
import '../screens/game_screens/tic_tac_toe.dart';
import '../screens/game_screens/memory_game.dart';
import '../screens/game_screens/number_puzzle.dart';
import '../screens/game_screens/rock_paper_scissors.dart';
import '../screens/game_screens/hangman_game.dart';
import '../screens/game_screens/quiz_game.dart';
import '../screens/game_screens/reaction_test.dart';
import '../screens/game_screens/color_match.dart';
import '../screens/game_screens/word_search.dart';

/// 기본 게임들을 레지스트리에 등록
class GameInitializer {
  static void initializeBuiltInGames() {
    final registry = GameRegistry();

    // 뱀 게임
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'snake',
        name: '뱀 게임',
        description: '클래식한 뱀 게임',
        icon: Icons.gamepad,
        color: Colors.green,
        categories: ['액션', '클래식'],
        gameBuilder: () => const SnakeGame(),
      ),
    );

    // 틱택토
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'tic_tac_toe',
        name: '틱택토',
        description: '3x3 보드에서 하는 틱택토',
        icon: Icons.grid_3x3,
        color: Colors.blue,
        categories: ['퍼즐', '전략'],
        gameBuilder: () => const TicTacToe(),
      ),
    );

    // 기억력 게임
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'memory',
        name: '기억력 게임',
        description: '카드 매칭 게임',
        icon: Icons.memory,
        color: Colors.purple,
        categories: ['기억력', '퍼즐'],
        gameBuilder: () => const MemoryGame(),
      ),
    );

    // 숫자 퍼즐
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'number_puzzle',
        name: '숫자 퍼즐',
        description: '15-퍼즐 게임',
        icon: Icons.numbers,
        color: Colors.orange,
        categories: ['퍼즐', '논리'],
        gameBuilder: () => const NumberPuzzle(),
      ),
    );

    // 가위바위보
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'rock_paper_scissors',
        name: '가위바위보',
        description: '컴퓨터와 대전',
        icon: Icons.handshake,
        color: Colors.red,
        categories: ['간단', '랜덤'],
        gameBuilder: () => const RockPaperScissors(),
      ),
    );

    // 행맨
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'hangman',
        name: '행맨',
        description: '단어 맞추기 게임',
        icon: Icons.text_fields,
        color: Colors.teal,
        categories: ['단어', '추측'],
        gameBuilder: () => const HangmanGame(),
      ),
    );

    // 퀴즈
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'quiz',
        name: '퀴즈',
        description: '퀴즈 게임',
        icon: Icons.quiz,
        color: Colors.indigo,
        categories: ['지식', '교육'],
        gameBuilder: () => const QuizGame(),
      ),
    );

    // 반응속도
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'reaction',
        name: '반응속도',
        description: '반응 속도 테스트',
        icon: Icons.timer,
        color: Colors.amber,
        categories: ['반응', '테스트'],
        gameBuilder: () => const ReactionTest(),
      ),
    );

    // 색깔 맞추기
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'color_match',
        name: '색깔 맞추기',
        description: '색상과 이름 매칭 게임',
        icon: Icons.palette,
        color: Colors.pink,
        categories: ['색상', '인지'],
        gameBuilder: () => const ColorMatch(),
      ),
    );

    // 단어 찾기
    registry.registerBuiltInGame(
      BaseGameWrapper(
        id: 'word_search',
        name: '단어 찾기',
        description: '단어 찾기 퍼즐',
        icon: Icons.search,
        color: Colors.cyan,
        categories: ['단어', '퍼즐'],
        gameBuilder: () => const WordSearch(),
      ),
    );
  }
}


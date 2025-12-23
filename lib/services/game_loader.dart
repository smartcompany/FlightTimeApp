import 'package:flutter/material.dart';
import '../models/game_metadata.dart';
import '../games/base_game_wrapper.dart';
import '../screens/game_screens/airplane_game.dart';
import '../screens/game_screens/asteroids_game.dart';
import '../screens/game_screens/breakout_game.dart';
import '../screens/game_screens/flappy_game.dart';
import '../screens/game_screens/space_shooter_game.dart';
import '../screens/game_screens/match3_game.dart';
import '../screens/game_screens/runner_game.dart';
import '../screens/game_screens/puzzle_game.dart';
import '../screens/game_screens/tetris_game.dart';
import '../screens/game_screens/game2048.dart';
import 'game_registry.dart';
import 'game_unlocker.dart';

/// 클라이언트에 있는 게임을 로드하는 서비스
/// 실제로는 다운로드가 아니라 잠금 해제된 게임을 등록하는 역할
class GameLoader {
  static final GameLoader _instance = GameLoader._internal();
  factory GameLoader() => _instance;
  GameLoader._internal();

  final GameRegistry _registry = GameRegistry();
  final GameUnlocker _unlocker = GameUnlocker();

  /// 잠금 해제된 게임을 로드하고 레지스트리에 등록
  Future<bool> loadUnlockedGame(String gameId, GameMetadata metadata) async {
    try {
      // 게임이 잠금 해제되었는지 확인
      final isUnlocked = await _unlocker.isGameUnlocked(gameId);
      if (!isUnlocked) {
        print('Game is locked: $gameId');
        return false;
      }

      // 클라이언트에 있는 게임 위젯 가져오기
      final gameBuilder = _getGameBuilder(gameId);
      if (gameBuilder == null) {
        print('Game builder not found for: $gameId');
        return false;
      }

      // 게임 등록
      final game = BaseGameWrapper(
        id: metadata.id,
        name: metadata.name,
        description: metadata.description,
        icon: _getIconForGameType(gameId),
        color: _getColorForGameType(gameId),
        categories: metadata.categories,
        gameBuilder: gameBuilder,
      );

      _registry.registerDownloadedGame(game);
      _registry.registerMetadata(metadata);
      return true;
    } catch (e) {
      print('Error loading game: $e');
      return false;
    }
  }

  /// 게임 ID에 따른 게임 빌더 반환
  Widget Function()? _getGameBuilder(String gameId) {
    switch (gameId) {
      case 'airplane':
        return () => const AirplaneGame();
      case 'asteroids':
        return () => const AsteroidsGame();
      case 'breakout':
        return () => const BreakoutGame();
      case 'flappy':
        return () => const FlappyGame();
      case 'space_shooter':
        return () => const SpaceShooterGame();
      case 'match3':
        return () => const Match3Game();
      case 'runner':
        return () => const RunnerGame();
      case 'puzzle':
        return () => const PuzzleGame();
      case 'tetris':
        return () => const TetrisGame();
      case 'game2048':
        return () => const Game2048();
      default:
        return null;
    }
  }

  /// 게임 ID에 따른 아이콘 반환
  IconData _getIconForGameType(String gameId) {
    switch (gameId) {
      case 'airplane':
        return Icons.flight;
      case 'asteroids':
        return Icons.rocket_launch;
      case 'breakout':
        return Icons.sports_tennis;
      case 'flappy':
        return Icons.flutter_dash;
      case 'space_shooter':
        return Icons.space_dashboard;
      case 'match3':
        return Icons.grid_3x3;
      case 'runner':
        return Icons.directions_run;
      case 'puzzle':
        return Icons.extension;
      case 'tetris':
        return Icons.view_module;
      case 'game2048':
        return Icons.grid_on;
      default:
        return Icons.gamepad;
    }
  }

  /// 게임 ID에 따른 색상 반환
  Color _getColorForGameType(String gameId) {
    switch (gameId) {
      case 'airplane':
        return Colors.blue;
      case 'asteroids':
        return Colors.deepPurple;
      case 'breakout':
        return Colors.orange;
      case 'flappy':
        return Colors.green;
      case 'space_shooter':
        return Colors.indigo;
      case 'match3':
        return Colors.pink;
      case 'runner':
        return Colors.teal;
      case 'puzzle':
        return Colors.amber;
      case 'tetris':
        return Colors.cyan;
      case 'game2048':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

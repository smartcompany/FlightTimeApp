import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/game_metadata.dart';
import '../games/base_game_wrapper.dart';
import '../screens/game_screens/sudoku_game.dart';
import '../screens/game_screens/tetris_game.dart';
import '../screens/game_screens/game2048.dart';
import 'game_registry.dart';

/// 다운로드된 게임을 로드하는 서비스
class GameLoader {
  static final GameLoader _instance = GameLoader._internal();
  factory GameLoader() => _instance;
  GameLoader._internal();

  final GameRegistry _registry = GameRegistry();

  /// 게임 타입별 로더 맵
  final Map<String, Widget Function(Map<String, dynamic>)> _gameLoaders = {
    'sudoku': (config) => const SudokuGame(),
    'tetris': (config) => const TetrisGame(),
    'game2048': (config) => const Game2048(),
  };

  /// 다운로드된 게임을 로드하고 레지스트리에 등록
  Future<bool> loadGameFromFile(String gameId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final gameFile = File('${directory.path}/games/$gameId.dart');
      final metadataFile = File('${directory.path}/games/$gameId.json');

      if (!await gameFile.exists() || !await metadataFile.exists()) {
        return false;
      }

      // 메타데이터 로드
      final metadataJson = await metadataFile.readAsString();
      final metadataMap = json.decode(metadataJson) as Map<String, dynamic>;
      final metadata = GameMetadata.fromJson(metadataMap);

      // 게임 타입 확인
      final gameType = metadataMap['gameType'] as String?;
      if (gameType == null) {
        return false;
      }

      // 게임 로더가 있는지 확인
      if (!_gameLoaders.containsKey(gameType)) {
        print('Game loader not found for type: $gameType');
        return false;
      }

      // 게임 설정 로드
      final config = metadataMap['config'] as Map<String, dynamic>? ?? {};

      // 게임 인스턴스 생성
      final gameWidget = _gameLoaders[gameType]!(config);

      // 게임을 래퍼로 감싸서 등록
      final game = BaseGameWrapper(
        id: metadata.id,
        name: metadata.name,
        description: metadata.description,
        icon: _getIconForGameType(gameType),
        color: _getColorForGameType(gameType),
        categories: metadata.categories,
        gameBuilder: () => gameWidget,
      );

      _registry.registerDownloadedGame(game);
      _registry.registerMetadata(metadata);

      return true;
    } catch (e) {
      print('Error loading game: $e');
      return false;
    }
  }

  /// 게임 타입에 따른 아이콘 반환
  IconData _getIconForGameType(String gameType) {
    switch (gameType) {
      case 'sudoku':
        return Icons.grid_4x4;
      case 'tetris':
        return Icons.view_module;
      case 'game2048':
        return Icons.grid_on;
      default:
        return Icons.gamepad;
    }
  }

  /// 게임 타입에 따른 색상 반환
  Color _getColorForGameType(String gameType) {
    switch (gameType) {
      case 'sudoku':
        return Colors.deepPurple;
      case 'tetris':
        return Colors.cyan;
      case 'game2048':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// 게임 타입별 로더 등록
  void registerGameLoader(String gameType, Widget Function(Map<String, dynamic>) loader) {
    _gameLoaders[gameType] = loader;
  }
}


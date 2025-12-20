import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/game_metadata.dart';
import '../games/base_game_wrapper.dart';
import '../screens/webview_game_screen.dart';
import 'game_registry.dart';

/// 다운로드된 게임을 로드하는 서비스
class GameLoader {
  static final GameLoader _instance = GameLoader._internal();
  factory GameLoader() => _instance;
  GameLoader._internal();

  final GameRegistry _registry = GameRegistry();

  /// 다운로드된 게임을 로드하고 레지스트리에 등록
  ///
  /// 주의: Flutter는 동적 코드 로딩을 지원하지 않으므로,
  /// 서버에서 받은 메타데이터를 기반으로 클라이언트에 미리 구현된
  /// 게임 타입을 로드합니다.
  Future<bool> loadGameFromFile(String gameId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/games/$gameId.json');

      if (!await metadataFile.exists()) {
        print('Metadata file not found for game: $gameId');
        return false;
      }

      // 메타데이터 로드 (서버에서 받은 전체 게임 데이터)
      final metadataJson = await metadataFile.readAsString();
      final metadataMap = json.decode(metadataJson) as Map<String, dynamic>;
      final metadata = GameMetadata.fromJson(metadataMap);

      // 게임 타입 확인
      final gameType = metadataMap['gameType'] as String?;
      if (gameType == null) {
        print('Game type not found in metadata');
        return false;
      }

      // 모든 다운로드 게임은 WebView로 HTML 게임 로드
      if (gameType == 'webview') {
        final htmlFile = File('${directory.path}/games/$gameId.html');
        if (!await htmlFile.exists()) {
          print('HTML file not found for webview game: $gameId');
          return false;
        }

        // WebView 게임 등록
        final game = BaseGameWrapper(
          id: metadata.id,
          name: metadata.name,
          description: metadata.description,
          icon: _getIconForGameType(gameId),
          color: _getColorForGameType(gameId),
          categories: metadata.categories,
          gameBuilder: () => WebViewGameScreen(
            gameId: metadata.id,
            gameName: metadata.name,
            htmlFilePath: htmlFile.path,
          ),
        );

        _registry.registerDownloadedGame(game);
        _registry.registerMetadata(metadata);
        return true;
      }

      // webview 타입이 아닌 경우
      print(
          'Game type must be "webview" for downloaded games. Found: $gameType');
      return false;
    } catch (e) {
      print('Error loading game: $e');
      return false;
    }
  }

  /// 게임 ID에 따른 아이콘 반환
  IconData _getIconForGameType(String gameId) {
    switch (gameId) {
      case 'sudoku':
        return Icons.grid_4x4;
      case 'tetris':
        return Icons.view_module;
      case 'game2048':
        return Icons.grid_on;
      default:
        return Icons.web;
    }
  }

  /// 게임 ID에 따른 색상 반환
  Color _getColorForGameType(String gameId) {
    switch (gameId) {
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
}

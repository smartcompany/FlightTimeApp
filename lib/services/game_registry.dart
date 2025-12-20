import '../interfaces/game_interface.dart';
import '../models/game_metadata.dart';

/// 게임 레지스트리 - 모든 게임을 관리
class GameRegistry {
  static final GameRegistry _instance = GameRegistry._internal();
  factory GameRegistry() => _instance;
  GameRegistry._internal();

  final Map<String, GameInterface> _builtInGames = {};
  final Map<String, GameInterface> _downloadedGames = {};
  final Map<String, GameMetadata> _gameMetadata = {};

  /// 기본 게임 등록
  void registerBuiltInGame(GameInterface game) {
    _builtInGames[game.id] = game;
  }

  /// 다운로드된 게임 등록
  void registerDownloadedGame(GameInterface game) {
    _downloadedGames[game.id] = game;
  }

  /// 게임 메타데이터 등록
  void registerMetadata(GameMetadata metadata) {
    _gameMetadata[metadata.id] = metadata;
  }

  /// 모든 게임 목록 가져오기
  List<GameInterface> getAllGames() {
    return [
      ..._builtInGames.values,
      ..._downloadedGames.values,
    ];
  }

  /// 기본 게임 목록
  List<GameInterface> getBuiltInGames() {
    return _builtInGames.values.toList();
  }

  /// 다운로드된 게임 목록
  List<GameInterface> getDownloadedGames() {
    return _downloadedGames.values.toList();
  }

  /// 게임 ID로 찾기
  GameInterface? getGameById(String id) {
    return _builtInGames[id] ?? _downloadedGames[id];
  }

  /// 게임 메타데이터 가져오기
  GameMetadata? getMetadata(String id) {
    return _gameMetadata[id];
  }

  /// 게임 제거 (다운로드된 게임만)
  bool unregisterGame(String id) {
    if (_downloadedGames.containsKey(id)) {
      _downloadedGames.remove(id);
      _gameMetadata.remove(id);
      return true;
    }
    return false;
  }

  /// 게임 존재 여부 확인
  bool hasGame(String id) {
    return _builtInGames.containsKey(id) || _downloadedGames.containsKey(id);
  }
}


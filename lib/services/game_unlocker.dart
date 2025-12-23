import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_metadata.dart';

/// 게임 잠금 해제 서비스
/// 실제로는 다운로드가 아니라 광고를 보고 락을 푸는 개념
class GameUnlocker {
  static final GameUnlocker _instance = GameUnlocker._internal();
  factory GameUnlocker() => _instance;
  GameUnlocker._internal();

  final String _unlockedGamesKey = 'unlocked_games';

  /// 게임 잠금 해제
  Future<bool> unlockGame(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlockedGames = await getUnlockedGames();
      if (!unlockedGames.contains(gameId)) {
        unlockedGames.add(gameId);
        await prefs.setStringList(_unlockedGamesKey, unlockedGames);
      }
      return true;
    } catch (e) {
      print('Error unlocking game: $e');
      return false;
    }
  }

  /// 게임이 잠금 해제되었는지 확인
  Future<bool> isGameUnlocked(String gameId) async {
    final unlockedGames = await getUnlockedGames();
    return unlockedGames.contains(gameId);
  }

  /// 잠금 해제된 게임 목록 가져오기
  Future<List<String>> getUnlockedGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedGamesKey) ?? [];
  }

  /// 모든 게임 잠금 해제 (디버그용)
  Future<void> unlockAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    // 서버에서 제공하는 모든 게임 ID 목록
    final allGameIds = [
      'airplane',
      'asteroids',
      'breakout',
      'flappy',
      'space_shooter',
      'match3',
      'runner',
      'puzzle',
      'tetris',
      'game2048',
    ];
    await prefs.setStringList(_unlockedGamesKey, allGameIds);
  }
}


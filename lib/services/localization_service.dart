import 'package:flutter/material.dart';

/// 로컬라이징 서비스
class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Locale _currentLocale = const Locale('ko', 'KR');
  final Map<Locale, Map<String, String>> _translations = {};

  Locale get currentLocale => _currentLocale;

  /// 초기화 - 시스템 언어 감지
  Future<void> initialize() async {
    _loadTranslations();
    // 시스템 언어는 main.dart에서 설정됨
  }

  /// 시스템 언어로 설정
  void setSystemLocale(Locale locale) {
    // 지원하는 언어인지 확인
    final supportedLocales = [
      const Locale('en', 'US'),
      const Locale('ko', 'KR'),
      const Locale('ja', 'JP'),
      const Locale('zh', 'CN'),
    ];

    // 정확히 일치하는 언어 찾기
    Locale? matchedLocale = supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => const Locale('en', 'US'), // 기본값: 영어
    );

    _currentLocale = matchedLocale;
  }

  /// 번역 가져오기
  String translate(String key) {
    return _translations[_currentLocale]?[key] ??
        _translations[const Locale('en', 'US')]?[key] ??
        key;
  }

  /// 번역 로드
  void _loadTranslations() {
    // 영어
    _translations[const Locale('en', 'US')] = {
      // App
      'app_title': 'Flight Time Games',
      'game_store': 'Game Store',
      'all_games': 'All',
      'built_in_games': 'Built-in',
      'downloaded': 'Downloaded',
      'no_games': 'No games available',
      'no_games_available': 'No games available',
      'download_before_flight_title': 'Download Games Before Flight',
      'download_before_flight_message':
          'Download additional games now to play offline during your flight',

      // Game Store
      'available_games': 'Available Games',
      'downloaded_games': 'Downloaded Games',
      'download': 'Download',
      'delete': 'Delete',
      'delete_game': 'Delete Game',
      'delete_confirmation': 'Are you sure you want to delete {name}?',
      'download_complete': '{name} downloaded',
      'download_failed': '{name} download failed',
      'delete_complete': '{name} deleted',
      'delete_failed': '{name} delete failed',
      'file_size': 'Size',
      'cancel': 'Cancel',
      'confirm': 'Confirm',

      // Games
      'snake_game': 'Snake Game',
      'tic_tac_toe': 'Tic Tac Toe',
      'memory_game': 'Memory Game',
      'number_puzzle': 'Number Puzzle',
      'rock_paper_scissors': 'Rock Paper Scissors',
      'hangman': 'Hangman',
      'quiz': 'Quiz',
      'reaction_test': 'Reaction Test',
      'color_match': 'Color Match',
      'word_search': 'Word Search',
      'sudoku': 'Sudoku',
      'tetris': 'Tetris',
      'game2048': '2048',

      // Common
      'score': 'Score',
      'level': 'Level',
      'best_score': 'Best Score',
      'new_game': 'New Game',
      'restart': 'Restart',
      'game_over': 'Game Over',
      'congratulations': 'Congratulations',
      'correct': 'Correct',
      'wrong': 'Wrong',
      'pause': 'Pause',
      'resume': 'Resume',
      'settings': 'Settings',
      'select_language': 'Select Language',
      'language_changed': 'changed',
    };

    // 한국어
    _translations[const Locale('ko', 'KR')] = {
      // App
      'app_title': 'Flight Time Games',
      'game_store': '게임 스토어',
      'all_games': '전체',
      'built_in_games': '기본 게임',
      'downloaded': '다운로드됨',
      'no_games': '게임이 없습니다',
      'no_games_available': '사용 가능한 게임이 없습니다',
      'download_before_flight_title': '비행 전 게임 다운로드',
      'download_before_flight_message': '지금 추가 게임을 다운로드하여 비행 중 오프라인으로 플레이하세요',

      // Game Store
      'available_games': '사용 가능한 게임',
      'downloaded_games': '다운로드된 게임',
      'download': '다운로드',
      'delete': '삭제',
      'delete_game': '게임 삭제',
      'delete_confirmation': '{name}을(를) 삭제하시겠습니까?',
      'download_complete': '{name} 다운로드 완료',
      'download_failed': '{name} 다운로드 실패',
      'delete_complete': '{name} 삭제 완료',
      'delete_failed': '{name} 삭제 실패',
      'file_size': '크기',
      'cancel': '취소',
      'confirm': '확인',

      // Games
      'snake_game': '뱀 게임',
      'tic_tac_toe': '틱택토',
      'memory_game': '기억력 게임',
      'number_puzzle': '숫자 퍼즐',
      'rock_paper_scissors': '가위바위보',
      'hangman': '행맨',
      'quiz': '퀴즈',
      'reaction_test': '반응속도',
      'color_match': '색깔 맞추기',
      'word_search': '단어 찾기',
      'sudoku': '스도쿠',
      'tetris': '테트리스',
      'game2048': '2048',

      // Common
      'score': '점수',
      'level': '레벨',
      'best_score': '최고 점수',
      'new_game': '새 게임',
      'restart': '다시 시작',
      'game_over': '게임 오버',
      'congratulations': '축하합니다',
      'correct': '정답',
      'wrong': '오답',
      'pause': '일시정지',
      'resume': '재개',
      'settings': '설정',
      'select_language': '언어 선택',
      'language_changed': '로 변경되었습니다',
    };

    // 일본어
    _translations[const Locale('ja', 'JP')] = {
      // App
      'app_title': 'Flight Time Games',
      'game_store': 'ゲームストア',
      'all_games': 'すべて',
      'built_in_games': '組み込み',
      'downloaded': 'ダウンロード済み',
      'no_games': 'ゲームがありません',
      'no_games_available': '利用可能なゲームがありません',
      'download_before_flight_title': 'フライト前にゲームをダウンロード',
      'download_before_flight_message': '今すぐ追加ゲームをダウンロードして、フライト中にオフラインでプレイできます',

      // Game Store
      'available_games': '利用可能なゲーム',
      'downloaded_games': 'ダウンロード済みゲーム',
      'download': 'ダウンロード',
      'delete': '削除',
      'delete_game': 'ゲームを削除',
      'delete_confirmation': '{name}を削除しますか？',
      'download_complete': '{name}のダウンロードが完了しました',
      'download_failed': '{name}のダウンロードに失敗しました',
      'delete_complete': '{name}を削除しました',
      'delete_failed': '{name}の削除に失敗しました',
      'file_size': 'サイズ',
      'cancel': 'キャンセル',
      'confirm': '確認',

      // Games
      'snake_game': 'スネークゲーム',
      'tic_tac_toe': '三目並べ',
      'memory_game': '記憶ゲーム',
      'number_puzzle': '数字パズル',
      'rock_paper_scissors': 'じゃんけん',
      'hangman': 'ハングマン',
      'quiz': 'クイズ',
      'reaction_test': '反応速度',
      'color_match': '色合わせ',
      'word_search': '単語検索',
      'sudoku': '数独',
      'tetris': 'テトリス',
      'game2048': '2048',

      // Common
      'score': 'スコア',
      'level': 'レベル',
      'best_score': '最高スコア',
      'new_game': '新しいゲーム',
      'restart': '再開',
      'game_over': 'ゲームオーバー',
      'congratulations': 'おめでとうございます',
      'correct': '正解',
      'wrong': '不正解',
      'pause': '一時停止',
      'resume': '再開',
      'settings': '設定',
      'select_language': '言語を選択',
      'language_changed': 'に変更されました',
    };

    // 중국어 (간체)
    _translations[const Locale('zh', 'CN')] = {
      // App
      'app_title': 'Flight Time Games',
      'game_store': '游戏商店',
      'all_games': '全部',
      'built_in_games': '内置',
      'downloaded': '已下载',
      'no_games': '没有游戏',
      'no_games_available': '没有可用游戏',
      'download_before_flight_title': '飞行前下载游戏',
      'download_before_flight_message': '立即下载更多游戏，以便在飞行期间离线游玩',

      // Game Store
      'available_games': '可用游戏',
      'downloaded_games': '已下载游戏',
      'download': '下载',
      'delete': '删除',
      'delete_game': '删除游戏',
      'delete_confirmation': '确定要删除{name}吗？',
      'download_complete': '{name}下载完成',
      'download_failed': '{name}下载失败',
      'delete_complete': '{name}已删除',
      'delete_failed': '{name}删除失败',
      'file_size': '大小',
      'cancel': '取消',
      'confirm': '确认',

      // Games
      'snake_game': '贪吃蛇',
      'tic_tac_toe': '井字棋',
      'memory_game': '记忆游戏',
      'number_puzzle': '数字拼图',
      'rock_paper_scissors': '石头剪刀布',
      'hangman': '猜词游戏',
      'quiz': '测验',
      'reaction_test': '反应速度',
      'color_match': '颜色匹配',
      'word_search': '单词搜索',
      'sudoku': '数独',
      'tetris': '俄罗斯方块',
      'game2048': '2048',

      // Common
      'score': '分数',
      'level': '等级',
      'best_score': '最高分',
      'new_game': '新游戏',
      'restart': '重新开始',
      'game_over': '游戏结束',
      'congratulations': '恭喜',
      'correct': '正确',
      'wrong': '错误',
      'pause': '暂停',
      'resume': '继续',
      'settings': '设置',
      'select_language': '选择语言',
      'language_changed': '已更改',
    };
  }

  /// 문자열 포맷팅 (플레이스홀더 지원)
  String translateWithParams(String key, Map<String, String> params) {
    String text = translate(key);
    params.forEach((key, value) {
      text = text.replaceAll('{$key}', value);
    });
    return text;
  }
}

/// 로컬라이징 확장
extension LocalizationExtension on BuildContext {
  String t(String key) {
    return LocalizationService().translate(key);
  }

  String tWithParams(String key, Map<String, String> params) {
    return LocalizationService().translateWithParams(key, params);
  }
}

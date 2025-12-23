import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_lib/share_lib.dart' as share_lib;
import '../models/game_metadata.dart';
import '../services/game_downloader.dart';
import '../services/game_unlocker.dart';
import '../services/game_loader.dart';
import '../services/localization_service.dart';

/// 게임 스토어 화면 - 광고를 보고 게임 잠금 해제
class GameStoreScreen extends StatefulWidget {
  final String serverUrl;

  const GameStoreScreen({
    super.key,
    required this.serverUrl,
  });

  @override
  State<GameStoreScreen> createState() => _GameStoreScreenState();
}

class _GameStoreScreenState extends State<GameStoreScreen> {
  final GameDownloader _downloader = GameDownloader();
  final GameUnlocker _unlocker = GameUnlocker();
  final GameLoader _loader = GameLoader();
  final LocalizationService _localization = LocalizationService();
  List<GameMetadata> _availableGames = [];
  List<String> _unlockedGames = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, bool> _unlockingGames = {};

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _loadGames();
  }

  Future<void> _initializeAds() async {
    share_lib.AdService.shared.setBaseUrl(widget.serverUrl);
    await share_lib.AdService.shared.loadSettings();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 서버에서 게임 목록 가져오기
      final available = await _downloader.fetchAvailableGames(widget.serverUrl);

      // 잠금 해제된 게임 목록 가져오기
      final unlocked = await _unlocker.getUnlockedGames();

      setState(() {
        _availableGames = available;
        _unlockedGames = unlocked;
        _isLoading = false;
        if (available.isEmpty) {
          _errorMessage = '서버에서 게임을 불러올 수 없습니다. 서버 상태를 확인해주세요.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '게임 목록을 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }

  Future<void> _unlockGame(GameMetadata game) async {
    // 광고 타입에 따라 자동으로 적절한 광고 표시
    // 광고가 로드되지 않았거나 실패하면 바로 잠금 해제 진행

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await share_lib.AdService.shared.showAd(
        onAdDismissed: () {
          // 광고 시청 완료 후 잠금 해제 진행
          if (mounted) {
            Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
            _performUnlock(game);
          }
        },
        onAdFailedToShow: () {
          // 광고 표시 실패 시에도 잠금 해제 진행
          if (mounted) {
            Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
            _performUnlock(game);
          }
        },
      );
    } catch (e) {
      // 광고 표시 중 에러 발생 시 바로 잠금 해제 진행
      debugPrint('Ad show error: $e');
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        _performUnlock(game);
      }
    }
  }

  Future<void> _performUnlock(GameMetadata game) async {
    if (!mounted) return;

    setState(() {
      _unlockingGames[game.id] = true;
    });

    // 게임 잠금 해제
    final success = await _unlocker.unlockGame(game.id);

    if (mounted) {
      setState(() {
        _unlockingGames[game.id] = false;
      });

      if (success) {
        // 게임 로드
        await _loader.loadUnlockedGame(game.id, game);
        await _loadGames();
        // 잠금 해제 완료는 조용히 처리 (스낵바 표시 안 함)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('게임 잠금 해제에 실패했습니다: ${game.name}')),
        );
      }
    }
  }

  Future<void> _unlockAllGames() async {
    if (!mounted) return;

    // 디버그 모드에서만 사용 가능
    if (!kDebugMode) return;

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 게임 잠금 해제 (디버그)'),
        content: const Text('모든 게임을 잠금 해제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('잠금 해제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _unlocker.unlockAllGames();
    await _loadGames();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 게임이 잠금 해제되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isUnlocked(String gameId) {
    return _unlockedGames.contains(gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.translate('game_store')),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.lock_open),
              tooltip: '모든 게임 잠금 해제 (디버그)',
              onPressed: _unlockAllGames,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGames,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGames,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                )
                  : _availableGames.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.games_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _localization.translate('no_games_available'),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // 잠금 해제된 게임 섹션
                        if (_unlockedGames.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                '잠금 해제된 게임',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ListView.builder(
                              itemCount: _availableGames
                                  .where((g) => _isUnlocked(g.id))
                                  .length,
                              itemBuilder: (context, index) {
                                final game = _availableGames
                                    .where((g) => _isUnlocked(g.id))
                                    .elementAt(index);
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.gamepad, size: 40),
                                    title: Text(game.name),
                                    subtitle: Text(game.description),
                                    trailing: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),
                        ],
                        // 잠금된 게임 섹션
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              '잠금된 게임',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            itemCount: _availableGames
                                .where((g) => !_isUnlocked(g.id))
                                .length,
                            itemBuilder: (context, index) {
                              final game = _availableGames
                                  .where((g) => !_isUnlocked(g.id))
                                  .elementAt(index);
                              final isUnlocking =
                                  _unlockingGames[game.id] ?? false;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: Stack(
                                    children: [
                                      const Icon(Icons.gamepad, size: 40),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Icon(Icons.lock,
                                            size: 16, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  title: Text(game.name),
                                  subtitle: Text(game.description),
                                  trailing: IconButton(
                                    icon: isUnlocking
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.lock_open),
                                    onPressed: isUnlocking
                                        ? null
                                        : () => _unlockGame(game),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}

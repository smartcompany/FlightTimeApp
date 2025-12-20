import 'package:flutter/material.dart';
import 'package:share_lib/share_lib.dart' as share_lib;
import '../services/game_registry.dart';
import '../services/game_downloader.dart';
import '../services/localization_service.dart';
import '../interfaces/game_interface.dart';
import 'game_store_screen.dart';

/// 새로운 구조의 홈 화면 - 게임 레지스트리 사용
class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  final GameRegistry _registry = GameRegistry();
  final GameDownloader _downloader = GameDownloader();
  final LocalizationService _localization = LocalizationService();
  List<GameInterface> _games = [];
  bool _showBuiltInOnly = false;
  bool _showDownloadBanner = true;
  bool _hasAvailableGames = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _loadGames();
    _checkAvailableGames();
  }

  Future<void> _initializeAds() async {
    share_lib.AdService.shared
        .setBaseUrl('https://flight-time-server.vercel.app');
    await share_lib.AdService.shared.loadSettings();
  }

  Future<void> _checkAvailableGames() async {
    try {
      final available = await _downloader
          .fetchAvailableGames('https://flight-time-server.vercel.app');
      setState(() {
        _hasAvailableGames = available.isNotEmpty;
      });
    } catch (e) {
      // 서버 연결 실패 시 배너 숨기기
      setState(() {
        _hasAvailableGames = false;
      });
    }
  }

  void _loadGames() {
    setState(() {
      _games = _showBuiltInOnly
          ? _registry.getBuiltInGames()
          : _registry.getAllGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.translate('app_title')),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.store),
                color: Colors.orange,
                iconSize: 28,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GameStoreScreen(
                        serverUrl: 'https://flight-time-server.vercel.app',
                      ),
                    ),
                  ).then((_) {
                    _loadGames();
                    _checkAvailableGames();
                  });
                },
                tooltip: _localization.translate('game_store'),
              ),
              if (_hasAvailableGames)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 8,
                      height: 8,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 다운로드 안내 배너
          if (_showDownloadBanner && _hasAvailableGames)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameStoreScreen(
                      serverUrl: 'https://flight-time-server.vercel.app',
                    ),
                  ),
                ).then((_) {
                  _loadGames();
                  _checkAvailableGames();
                });
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flight_takeoff,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _localization
                                .translate('download_before_flight_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _localization
                                .translate('download_before_flight_message'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showDownloadBanner = false;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 필터 버튼
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(_localization.translate('all_games')),
                  selected: !_showBuiltInOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showBuiltInOnly = false;
                      _loadGames();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(_localization.translate('built_in_games')),
                  selected: _showBuiltInOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showBuiltInOnly = true;
                      _loadGames();
                    });
                  },
                ),
              ],
            ),
          ),
          // 게임 그리드
          Expanded(
            child: _games.isEmpty
                ? Center(child: Text(_localization.translate('no_games')))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    padding: const EdgeInsets.all(16),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      return _buildGameCard(game);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGame(GameInterface game) async {
    // 다운로드된 게임인 경우 광고 표시
    final isDownloaded =
        _registry.getDownloadedGames().any((g) => g.id == game.id);

    if (isDownloaded) {
      try {
        await share_lib.AdService.shared.showInterstitialAd(
          onAdDismissed: () {
            // 광고 시청 완료 후 게임 실행
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => game.buildGame()),
            );
          },
          onAdFailedToShow: () {
            // 광고 표시 실패 시에도 게임 실행
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => game.buildGame()),
            );
          },
        );
      } catch (e) {
        // 광고 표시 중 에러 발생 시 바로 게임 실행
        debugPrint('Ad show error: $e');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => game.buildGame()),
        );
      }
    } else {
      // 기본 게임은 바로 실행
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => game.buildGame()),
      );
    }
  }

  Widget _buildGameCard(GameInterface game) {
    // 다운로드된 게임인지 확인
    final isDownloaded =
        _registry.getDownloadedGames().any((g) => g.id == game.id);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          _launchGame(game);
        },
        onLongPress: isDownloaded ? () => _showDeleteDialog(game) : null,
        child: SizedBox(
          height: 120,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(game.icon, size: 48, color: game.color),
                      const SizedBox(height: 8),
                      Text(
                        game.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isDownloaded)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _localization.translate('downloaded'),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isDownloaded)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _showDeleteDialog(game),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(GameInterface game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('delete_game')),
        content: Text(_localization
            .translateWithParams('delete_confirmation', {'name': game.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_localization.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_localization.translate('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _downloader.deleteGame(game.id);
      if (success) {
        _loadGames();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_localization.translateWithParams(
                    'delete_complete', {'name': game.name}))),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_localization.translateWithParams(
                    'delete_failed', {'name': game.name}))),
          );
        }
      }
    }
  }
}

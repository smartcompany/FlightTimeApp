import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadGames();
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
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GameStoreScreen(
                    serverUrl: 'https://flight-time-server.vercel.app',
                  ),
                ),
              ).then((_) => _loadGames());
            },
            tooltip: _localization.translate('game_store'),
          ),
        ],
      ),
      body: Column(
        children: [
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

  Widget _buildGameCard(GameInterface game) {
    // 다운로드된 게임인지 확인
    final isDownloaded =
        _registry.getDownloadedGames().any((g) => g.id == game.id);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => game.buildGame()),
          );
        },
        onLongPress: isDownloaded ? () => _showDeleteDialog(game) : null,
        child: Stack(
          children: [
            Column(
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
                ),
                if (isDownloaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _localization.translate('downloaded'),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            if (isDownloaded)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showDeleteDialog(game),
                ),
              ),
          ],
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

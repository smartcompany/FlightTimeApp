import 'package:flutter/material.dart';
import '../models/game_metadata.dart';
import '../services/game_downloader.dart';
import '../services/localization_service.dart';

/// 게임 스토어 화면 - 서버에서 게임 다운로드
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
  final LocalizationService _localization = LocalizationService();
  List<GameMetadata> _availableGames = [];
  List<GameMetadata> _downloadedGames = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, bool> _downloadingGames = {};
  Map<String, int> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 서버에서 게임 목록 가져오기
      final available = await _downloader.fetchAvailableGames(widget.serverUrl);

      // 다운로드된 게임 목록 가져오기
      final downloaded = await _downloader.getDownloadedGames();

      setState(() {
        _availableGames = available;
        _downloadedGames = downloaded;
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

  Future<void> _downloadGame(GameMetadata game) async {
    setState(() {
      _downloadingGames[game.id] = true;
      _downloadProgress[game.id] = 0;
    });

    final success = await _downloader.downloadGame(
      game,
      (downloaded, total) {
        setState(() {
          _downloadProgress[game.id] = ((downloaded / total) * 100).toInt();
        });
      },
    );

    setState(() {
      _downloadingGames[game.id] = false;
      _downloadProgress.remove(game.id);
    });

    if (success) {
      // 게임 로드
      await _downloader.loadDownloadedGame(game.id);
      await _loadGames();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_localization.translateWithParams(
                  'download_complete', {'name': game.name}))),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_localization.translateWithParams(
                  'download_failed', {'name': game.name}))),
        );
      }
    }
  }

  Future<void> _deleteGame(GameMetadata game) async {
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
            child: Text(_localization.translate('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _downloader.deleteGame(game.id);
      await _loadGames();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_localization.translateWithParams(
                  'delete_complete', {'name': game.name}))),
        );
      }
    }
  }

  bool _isDownloaded(String gameId) {
    return _downloadedGames.any((game) => game.id == gameId);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.translate('game_store')),
        actions: [
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
              : _availableGames.isEmpty && _downloadedGames.isEmpty
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
                        // 다운로드된 게임 섹션
                        if (_downloadedGames.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _localization.translate('downloaded_games'),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ListView.builder(
                              itemCount: _downloadedGames.length,
                              itemBuilder: (context, index) {
                                final game = _downloadedGames[index];
                                return ListTile(
                                  leading: const Icon(Icons.gamepad),
                                  title: Text(game.name),
                                  subtitle: Text(game.description),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteGame(game),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),
                        ],
                        // 사용 가능한 게임 섹션
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _localization.translate('available_games'),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            itemCount: _availableGames.length,
                            itemBuilder: (context, index) {
                              final game = _availableGames[index];
                              final isDownloaded = _isDownloaded(game.id);
                              final isDownloading =
                                  _downloadingGames[game.id] ?? false;
                              final progress = _downloadProgress[game.id] ?? 0;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.gamepad, size: 40),
                                  title: Text(game.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(game.description),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_localization.translate('file_size')}: ${_formatFileSize(game.fileSize)}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                      if (isDownloading) ...[
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                            value: progress / 100),
                                        Text('$progress%',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ],
                                    ],
                                  ),
                                  trailing: isDownloaded
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : IconButton(
                                          icon: isDownloading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : const Icon(Icons.download),
                                          onPressed: isDownloading
                                              ? null
                                              : () => _downloadGame(game),
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

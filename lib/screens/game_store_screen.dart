import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_lib/share_lib.dart' as share_lib;
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
    // 광고 타입에 따라 자동으로 적절한 광고 표시
    // 광고가 로드되지 않았거나 실패하면 바로 다운로드 진행

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
          // 광고 시청 완료 후 다운로드 진행
          if (mounted) {
            Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
            _performDownload(game);
          }
        },
        onAdFailedToShow: () {
          // 광고 표시 실패 시에도 다운로드 진행
          if (mounted) {
            Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
            _performDownload(game);
          }
        },
      );
    } catch (e) {
      // 광고 표시 중 에러 발생 시 바로 다운로드 진행
      debugPrint('Ad show error: $e');
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        _performDownload(game);
      }
    }
  }

  Future<void> _performDownload(GameMetadata game) async {
    if (!mounted) return;

    setState(() {
      _downloadingGames[game.id] = true;
      _downloadProgress[game.id] = 0;
    });

    final success = await _downloader.downloadGame(
      game,
      (downloaded, total) {
        if (mounted) {
          setState(() {
            _downloadProgress[game.id] = ((downloaded / total) * 100).toInt();
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _downloadingGames[game.id] = false;
        _downloadProgress.remove(game.id);
      });

      if (success) {
        // 게임 로드
        await _downloader.loadDownloadedGame(game.id);
        await _loadGames();
        // 다운로드 완료는 조용히 처리 (스낵바 표시 안 함)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_localization.translateWithParams(
                  'download_failed', {'name': game.name}))),
        );
      }
    }
  }

  Future<void> _downloadAllGames() async {
    if (!mounted) return;

    // 디버그 모드에서는 이미 다운로드된 게임도 포함하여 모두 다운로드
    final gamesToDownload = _availableGames.toList();

    if (gamesToDownload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다운로드할 게임이 없습니다.')),
      );
      return;
    }

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 게임 다운로드'),
        content: Text(
            '${gamesToDownload.length}개의 게임을 다운로드하시겠습니까?\n(이미 다운로드된 게임도 다시 다운로드됩니다)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('다운로드'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    int successCount = 0;
    int failCount = 0;

    for (var game in gamesToDownload) {
      if (!mounted) break;

      final success = await _downloader.downloadGame(
        game,
        (downloaded, total) {
          // 진행률은 표시하지 않음 (여러 게임 동시 다운로드)
        },
      );

      if (success) {
        await _downloader.loadDownloadedGame(game.id);
        successCount++;
      } else {
        failCount++;
      }
    }

    if (mounted) {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      await _loadGames();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('다운로드 완료: $successCount개 성공, $failCount개 실패'),
          duration: const Duration(seconds: 3),
        ),
      );
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
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.download_for_offline),
              tooltip: '모든 게임 다운로드 (디버그)',
              onPressed: _downloadAllGames,
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

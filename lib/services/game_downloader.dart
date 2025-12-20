import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_metadata.dart';
import 'game_registry.dart';
import 'game_loader.dart';

/// 게임 다운로드 및 관리 서비스
class GameDownloader {
  static final GameDownloader _instance = GameDownloader._internal();
  factory GameDownloader() => _instance;
  GameDownloader._internal();

  final GameRegistry _registry = GameRegistry();
  final String _metadataKey = 'downloaded_games_metadata';
  String? _currentServerUrl;

  /// 서버에서 게임 목록 가져오기
  Future<List<GameMetadata>> fetchAvailableGames(String serverUrl) async {
    _currentServerUrl = serverUrl;
    try {
      final client = HttpClient();
      // URL 끝에 슬래시가 있으면 제거
      final cleanUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
      final uri = Uri.parse('$cleanUrl/api/games');
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        if (jsonString.isEmpty) {
          print('Empty response from server');
          return [];
        }
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => GameMetadata.fromJson(json)).toList();
      } else {
        print('Server returned status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching games: $e');
      rethrow; // 에러를 다시 던져서 UI에서 처리할 수 있도록
    }
  }

  /// 게임 다운로드
  /// 
  /// Flutter는 동적 코드 로딩을 지원하지 않으므로,
  /// 다운로드는 게임 메타데이터만 받습니다.
  /// 실제 게임 코드는 클라이언트에 미리 구현되어 있어야 합니다.
  Future<bool> downloadGame(
      GameMetadata metadata, Function(int, int)? onProgress) async {
    try {
      print('Starting download for game: ${metadata.id}');
      print('Download URL: ${metadata.downloadUrl}');

      final directory = await getApplicationDocumentsDirectory();
      final gamesDir = Directory('${directory.path}/games');
      if (!await gamesDir.exists()) {
        await gamesDir.create(recursive: true);
      }

      // 서버에서 받은 전체 게임 데이터를 JSON으로 저장 (게임 로더에서 사용)
      // 서버 API에서 전체 게임 정보 가져오기
      final client = HttpClient();
      try {
        final metadataPath = metadata.downloadUrl.replaceAll('/download', '');
        final metadataUrl = metadataPath.startsWith('http')
            ? metadataPath
            : '${_currentServerUrl ?? 'http://localhost:3000'}$metadataPath';
        final metadataUri = Uri.parse(metadataUrl);
        print('Fetching metadata from: $metadataUri');

        final metadataRequest = await client.getUrl(metadataUri);
        final metadataResponse = await metadataRequest.close();

        if (metadataResponse.statusCode == 200) {
          final metadataJsonString =
              await metadataResponse.transform(utf8.decoder).join();
          final fullGameData =
              json.decode(metadataJsonString) as Map<String, dynamic>;

          // 게임 타입 확인
          final gameType = fullGameData['gameType'] as String?;
          
          // WebView 게임인 경우 HTML 파일 다운로드
          if (gameType == 'webview') {
            final htmlUrl = fullGameData['htmlUrl'] as String?;
            if (htmlUrl == null) {
              print('htmlUrl not found for webview game');
              return false;
            }
            
            // HTML 파일 다운로드
            final htmlDownloadUrl = htmlUrl.startsWith('http')
                ? htmlUrl
                : '${_currentServerUrl ?? 'http://localhost:3000'}$htmlUrl';
            final htmlUri = Uri.parse(htmlDownloadUrl);
            print('Downloading HTML file from: $htmlUri');

            final htmlRequest = await client.getUrl(htmlUri);
            final htmlResponse = await htmlRequest.close();

            if (htmlResponse.statusCode == 200) {
              final contentLength = htmlResponse.contentLength;
              final bytes = <int>[];
              int downloaded = 0;

              await for (var chunk in htmlResponse) {
                bytes.addAll(chunk);
                downloaded += chunk.length;
                if (onProgress != null && contentLength > 0) {
                  // 진행률 계산 (메타데이터 20%, HTML 80%)
                  final progress = ((downloaded / contentLength) * 80 + 20).round();
                  onProgress(progress, 100);
                }
              }

              final htmlContent = utf8.decode(bytes);
              final htmlFile = File('${directory.path}/games/${metadata.id}.html');
              await htmlFile.writeAsString(htmlContent);
              print('HTML file saved to: ${htmlFile.path} (${bytes.length} bytes)');
            } else {
              print('Failed to download HTML file: ${htmlResponse.statusCode}');
              return false;
            }
          }

          // 전체 게임 데이터를 JSON 파일로 저장
          final metadataFile =
              File('${directory.path}/games/${metadata.id}.json');
          await metadataFile.writeAsString(json.encode(fullGameData));
          print('Metadata file saved to: ${metadataFile.path}');
          
          // 다운로드 완료
          if (onProgress != null) {
            onProgress(100, 100);
          }

          // 메타데이터 저장
          await _saveDownloadedGameMetadata(metadata);
          print('Download completed successfully');

          return true;
        } else {
          print(
              'Failed to fetch game metadata: ${metadataResponse.statusCode}');
          return false;
        }
      } catch (e) {
        print('Error fetching game metadata: $e');
        return false;
      } finally {
        client.close();
      }
    } catch (e, stackTrace) {
      print('Error downloading game: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// 다운로드된 게임 로드
  Future<bool> loadDownloadedGame(String gameId) async {
    try {
      // GameLoader를 사용하여 게임 로드
      final gameLoader = GameLoader();
      return await gameLoader.loadGameFromFile(gameId);
    } catch (e) {
      print('Error loading game: $e');
      return false;
    }
  }

  /// 다운로드된 게임 목록 가져오기
  Future<List<GameMetadata>> getDownloadedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_metadataKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => GameMetadata.fromJson(json)).toList();
  }

  /// 게임 삭제
  Future<bool> deleteGame(String gameId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // Dart 파일 삭제
      final gameFile = File('${directory.path}/games/$gameId.dart');
      if (await gameFile.exists()) {
        await gameFile.delete();
      }

      // JSON 메타데이터 파일 삭제
      final metadataFile = File('${directory.path}/games/$gameId.json');
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      // SharedPreferences에서 메타데이터 제거
      final games = await getDownloadedGames();
      games.removeWhere((game) => game.id == gameId);
      await _saveDownloadedGamesMetadata(games);

      // 레지스트리에서 제거
      _registry.unregisterGame(gameId);
      return true;
    } catch (e) {
      print('Error deleting game: $e');
      return false;
    }
  }

  /// 메타데이터 저장
  Future<void> _saveDownloadedGameMetadata(GameMetadata metadata) async {
    final games = await getDownloadedGames();
    games.removeWhere((game) => game.id == metadata.id);
    games.add(metadata);
    await _saveDownloadedGamesMetadata(games);
  }

  /// 다운로드된 게임 메타데이터 목록 저장
  Future<void> _saveDownloadedGamesMetadata(List<GameMetadata> games) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = games.map((game) => game.toJson()).toList();
    await prefs.setString(_metadataKey, json.encode(jsonList));
  }
}

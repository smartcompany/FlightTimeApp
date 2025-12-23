import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen_v2.dart';
import 'config/game_initializer.dart';
import 'services/game_downloader.dart';
import 'services/game_unlocker.dart';
import 'services/game_loader.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Mobile Ads 초기화 (가장 먼저 실행)
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('MobileAds initialization error: $e');
    // 광고 초기화 실패해도 앱은 계속 실행
  }

  // 로컬라이징 초기화
  final localization = LocalizationService();
  await localization.initialize();

  // 시스템 언어 감지
  final systemLocale = PlatformDispatcher.instance.locale;
  localization.setSystemLocale(systemLocale);

  // 기본 게임 초기화
  GameInitializer.initializeBuiltInGames();

  // 잠금 해제된 게임 로드
  final unlocker = GameUnlocker();
  final loader = GameLoader();
  final downloader = GameDownloader();

  // 서버에서 게임 목록 가져오기
  try {
    final availableGames = await downloader
        .fetchAvailableGames('https://flight-time-server.vercel.app');
    final unlockedGameIds = await unlocker.getUnlockedGames();

    debugPrint('Unlocked games: $unlockedGameIds');
    debugPrint('Available games: ${availableGames.map((g) => g.id).toList()}');

    // 잠금 해제된 게임들을 로드
    for (var gameId in unlockedGameIds) {
      try {
        final game = availableGames.firstWhere(
          (g) => g.id == gameId,
        );
        final success = await loader.loadUnlockedGame(gameId, game);
        debugPrint('Loaded game $gameId: $success');
      } catch (e) {
        debugPrint('Error loading game $gameId: $e');
      }
    }
  } catch (e) {
    debugPrint('Error loading unlocked games: $e');
    // 서버 연결 실패해도 앱은 계속 실행
  }

  runApp(const FlightTimeGamesApp());
}

class FlightTimeGamesApp extends StatefulWidget {
  const FlightTimeGamesApp({super.key});

  @override
  State<FlightTimeGamesApp> createState() => _FlightTimeGamesAppState();
}

class _FlightTimeGamesAppState extends State<FlightTimeGamesApp> {
  final LocalizationService _localization = LocalizationService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Time Games',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      locale: _localization.currentLocale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
        Locale('ja', 'JP'),
        Locale('zh', 'CN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreenV2(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:ui';
import 'screens/home_screen_v2.dart';
import 'config/game_initializer.dart';
import 'services/game_downloader.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로컬라이징 초기화
  final localization = LocalizationService();
  await localization.initialize();

  // 시스템 언어 감지
  final systemLocale = PlatformDispatcher.instance.locale;
  localization.setSystemLocale(systemLocale);

  // 기본 게임 초기화
  GameInitializer.initializeBuiltInGames();

  // 다운로드된 게임 로드
  final downloader = GameDownloader();
  final downloadedGames = await downloader.getDownloadedGames();
  for (var game in downloadedGames) {
    await downloader.loadDownloadedGame(game.id);
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
      home: const HomeScreenV2(),
      debugShowCheckedModeBanner: false,
    );
  }
}

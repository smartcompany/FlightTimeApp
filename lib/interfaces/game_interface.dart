import 'package:flutter/material.dart';

/// 모든 게임이 구현해야 하는 인터페이스
abstract class GameInterface {
  /// 게임 ID (고유 식별자)
  String get id;

  /// 게임 이름
  String get name;

  /// 게임 설명
  String get description;

  /// 게임 아이콘
  IconData get icon;

  /// 게임 색상
  Color get color;

  /// 게임 카테고리
  List<String> get categories;

  /// 게임 위젯을 반환
  Widget buildGame();

  /// 게임 초기화 (필요시)
  void initialize() {}

  /// 게임 정리 (필요시)
  void dispose() {}
}


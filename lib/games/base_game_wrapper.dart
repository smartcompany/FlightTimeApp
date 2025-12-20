import 'package:flutter/material.dart';
import '../interfaces/game_interface.dart';

/// 기본 게임을 GameInterface로 래핑하는 헬퍼 클래스
class BaseGameWrapper implements GameInterface {
  final String _id;
  final String _name;
  final String _description;
  final IconData _icon;
  final Color _color;
  final List<String> _categories;
  final Widget Function() _gameBuilder;

  BaseGameWrapper({
    required String id,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    List<String>? categories,
    required Widget Function() gameBuilder,
  })  : _id = id,
        _name = name,
        _description = description,
        _icon = icon,
        _color = color,
        _categories = categories ?? [],
        _gameBuilder = gameBuilder;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get description => _description;

  @override
  IconData get icon => _icon;

  @override
  Color get color => _color;

  @override
  List<String> get categories => _categories;

  @override
  Widget buildGame() => _gameBuilder();

  @override
  void initialize() {}

  @override
  void dispose() {}
}


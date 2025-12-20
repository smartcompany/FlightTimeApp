/// 게임 메타데이터 모델
class GameMetadata {
  final String id;
  final String name;
  final String description;
  final String version;
  final String iconUrl;
  final String downloadUrl;
  final int fileSize; // bytes
  final bool isBuiltIn; // 기본 게임인지 여부
  final List<String> categories;
  final DateTime? lastUpdated;
  final String? gameType; // 게임 타입 (로더에서 사용)
  final Map<String, dynamic>? config; // 게임 설정

  GameMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.iconUrl,
    required this.downloadUrl,
    required this.fileSize,
    this.isBuiltIn = false,
    this.categories = const [],
    this.lastUpdated,
    this.gameType,
    this.config,
  });

  factory GameMetadata.fromJson(Map<String, dynamic> json) {
    return GameMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      iconUrl: json['iconUrl'] as String,
      downloadUrl: json['downloadUrl'] as String,
      fileSize: json['fileSize'] as int,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      gameType: json['gameType'] as String?,
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'iconUrl': iconUrl,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'isBuiltIn': isBuiltIn,
      'categories': categories,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'gameType': gameType,
      'config': config,
    };
  }
}


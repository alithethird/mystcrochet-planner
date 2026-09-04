import 'yarn_color.dart';

enum MotifType {
  classicGranny,
  solidGranny,
  sunburst,
}

extension MotifTypeExtension on MotifType {
  String get displayName {
    switch (this) {
      case MotifType.classicGranny:
        return 'Klasik Granny / Classic Granny';
      case MotifType.solidGranny:
        return 'Düz / Solid Granny';
      case MotifType.sunburst:
        return 'Papatya / Sunburst';
    }
  }

  String get key => name;

  static MotifType fromKey(String key) {
    return MotifType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => MotifType.classicGranny,
    );
  }
}

class Motif {
  final String id;
  final String name;
  final MotifType type;
  final List<YarnColor> rounds;

  const Motif({
    required this.id,
    required this.name,
    required this.type,
    required this.rounds,
  });

  Motif copyWith({
    String? id,
    String? name,
    MotifType? type,
    List<YarnColor>? rounds,
  }) {
    return Motif(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rounds: rounds ?? List.from(this.rounds),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.key,
        'rounds': rounds.map((r) => r.toJson()).toList(),
      };

  factory Motif.fromJson(Map<String, dynamic> json) => Motif(
        id: json['id'] as String,
        name: json['name'] as String,
        type: MotifTypeExtension.fromKey(json['type'] as String),
        rounds: (json['rounds'] as List<dynamic>)
            .map((r) => YarnColor.fromJson(r as Map<String, dynamic>))
            .toList(),
      );

  /// Sample starter motifs for every new project
  static List<Motif> defaultMotifs() {
    return [
      Motif(
        id: 'motif_1',
        name: 'Güneş Işığı (Motif A)',
        type: MotifType.sunburst,
        rounds: [
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'mustard'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'cream'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'terracotta'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'linen'),
        ],
      ),
      Motif(
        id: 'motif_2',
        name: 'Adaçayı Esintisi (Motif B)',
        type: MotifType.classicGranny,
        rounds: [
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'sage'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'oat'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'forest'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'cream'),
        ],
      ),
      Motif(
        id: 'motif_3',
        name: 'Gül Kurusu (Motif C)',
        type: MotifType.classicGranny,
        rounds: [
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'blush'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'dusty_rose'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'terracotta'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'cream'),
        ],
      ),
      Motif(
        id: 'motif_4',
        name: 'Keten Solid (Motif D)',
        type: MotifType.solidGranny,
        rounds: [
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'oat'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'linen'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'cream'),
          YarnColor.defaultPalette.firstWhere((c) => c.id == 'coffee'),
        ],
      ),
    ];
  }
}

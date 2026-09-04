import 'package:flutter/material.dart';

class YarnColor {
  final String id;
  final String name;
  final int colorValue;

  const YarnColor({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
      };

  factory YarnColor.fromJson(Map<String, dynamic> json) => YarnColor(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: (json['colorValue'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YarnColor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          colorValue == other.colorValue;

  @override
  int get hashCode => id.hashCode ^ colorValue.hashCode;

  /// Preset cozy crochet yarn color palette
  static const List<YarnColor> defaultPalette = [
    YarnColor(id: 'cream', name: 'Krem / Cream', colorValue: 0xFFFDFBF7),
    YarnColor(id: 'linen', name: 'Keten / Linen', colorValue: 0xFFEBE3D5),
    YarnColor(id: 'oat', name: 'Yulaf / Oat', colorValue: 0xFFD8C4B6),
    YarnColor(id: 'mustard', name: 'Hardal / Mustard', colorValue: 0xFFE9B34C),
    YarnColor(id: 'terracotta', name: 'Kiremit / Terracotta', colorValue: 0xFFD36B50),
    YarnColor(id: 'rust', name: 'Pas / Rust', colorValue: 0xFFA7412A),
    YarnColor(id: 'blush', name: 'Pudra / Blush Pink', colorValue: 0xFFF4C2C2),
    YarnColor(id: 'dusty_rose', name: 'Gül Kurusu / Dusty Rose', colorValue: 0xFFC08081),
    YarnColor(id: 'sage', name: 'Adaçayı / Sage', colorValue: 0xFF9CAF88),
    YarnColor(id: 'olive', name: 'Zeytin / Olive', colorValue: 0xFF6B7B4B),
    YarnColor(id: 'forest', name: 'Orman Yeşili / Forest', colorValue: 0xFF355E3B),
    YarnColor(id: 'duck_egg', name: 'Ördek Başı / Duck Egg', colorValue: 0xFF9FC5E8),
    YarnColor(id: 'denim', name: 'Denim Mavi / Denim Blue', colorValue: 0xFF4A708B),
    YarnColor(id: 'navy', name: 'Lacivert / Navy', colorValue: 0xFF1B2A4A),
    YarnColor(id: 'lavender', name: 'Lavanta / Lavender', colorValue: 0xFFC3B1E1),
    YarnColor(id: 'plum', name: 'Mürdüm / Plum', colorValue: 0xFF703657),
    YarnColor(id: 'coffee', name: 'Kahve / Warm Cocoa', colorValue: 0xFF5C4033),
    YarnColor(id: 'charcoal', name: 'Antrasit / Charcoal', colorValue: 0xFF36454F),
  ];
}

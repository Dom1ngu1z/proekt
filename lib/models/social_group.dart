import 'package:flutter/material.dart';

class SocialGroup {
  const SocialGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.membersCount,
    required this.accentColor,
    this.coverImageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int membersCount;
  final Color accentColor;
  final String? coverImageUrl;

  factory SocialGroup.fromMap(Map<String, dynamic> map) {
    return SocialGroup(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Без названия',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Обсуждение',
      membersCount: _asInt(map['members_count']) ?? 0,
      accentColor: _parseColor(map['accent_color']),
      coverImageUrl: map['cover_image_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'members_count': membersCount,
      'accent_color': '#${accentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'cover_image_url': coverImageUrl,
    };
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static Color _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    }
    final raw = value?.toString().replaceAll('#', '');
    if (raw == null || raw.length != 6 && raw.length != 8) {
      return const Color(0xFF6C63FF);
    }
    final normalized = raw.length == 6 ? 'FF$raw' : raw;
    return Color(int.parse(normalized, radix: 16));
  }
}



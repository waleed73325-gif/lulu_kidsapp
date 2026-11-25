import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum AccessLevel { free, premium }
enum CategoryType { letters, numbers, colorsShapes, stories, games }

class LessonCategory {
  final String id;
  final String title;
  final String subtitle;
  final CategoryType type;
  final IconData icon;
  final LinearGradient gradient;

  const LessonCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.gradient,
  });

  factory LessonCategory.fromJson(Map<String, dynamic> json) {
    final slug = json['slug']?.toString() ?? json['id']?.toString() ?? 'cat_letters';
    final type = _categoryTypeFromSlug(slug);

    return LessonCategory(
      id: slug,
      title: json['name_ar']?.toString() ?? json['title']?.toString() ?? 'جزيرة لولو',
      subtitle: json['subtitle_ar']?.toString() ?? json['subtitle']?.toString() ?? '',
      type: type,
      icon: _parseIcon(json['icon']?.toString()),
      gradient: _gradientForType(type),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'icon': icon.codePoint,
    };
  }

  static CategoryType _categoryTypeFromSlug(String slug) {
    if (slug.contains('letter')) return CategoryType.letters;
    if (slug.contains('number')) return CategoryType.numbers;
    if (slug.contains('color')) return CategoryType.colorsShapes;
    if (slug.contains('stor')) return CategoryType.stories;
    if (slug.contains('game')) return CategoryType.games;
    return CategoryType.letters;
  }

  static LinearGradient _gradientForType(CategoryType type) {
    switch (type) {
      case CategoryType.letters:
        return AppColors.lettersIslandGradient;
      case CategoryType.numbers:
        return AppColors.numbersIslandGradient;
      case CategoryType.colorsShapes:
        return AppColors.colorsIslandGradient;
      case CategoryType.stories:
        return AppColors.storiesIslandGradient;
      case CategoryType.games:
        return AppColors.gamesIslandGradient;
    }
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'sort_by_alpha_rounded':
        return Icons.sort_by_alpha_rounded;
      case 'pin_outlined':
        return Icons.pin_outlined;
      case 'palette_outlined':
        return Icons.palette_outlined;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'videogame_asset_outlined':
        return Icons.videogame_asset_outlined;
      default:
        return Icons.stars_rounded;
    }
  }
}

class Lesson {
  final String id;
  final String categoryId;
  final String title;
  final String subtitle;
  final String contentArabic;
  final String exampleWord;
  final IconData displayIcon;
  final AccessLevel accessLevel;
  final int starsReward;
  final Color primaryColor;
  final String narrationText;
  final String? audioUrl;

  const Lesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.subtitle,
    required this.contentArabic,
    required this.exampleWord,
    required this.displayIcon,
    this.accessLevel = AccessLevel.free,
    this.starsReward = 3,
    required this.primaryColor,
    required this.narrationText,
    this.audioUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final access = (json['access_level'] == 'premium') ? AccessLevel.premium : AccessLevel.free;
    final catId = json['category_slug']?.toString() ??
        json['category_id']?.toString() ??
        'cat_letters';

    return Lesson(
      id: json['id']?.toString() ?? '',
      categoryId: catId.startsWith('cat_') ? catId : 'cat_letters',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      contentArabic: json['content_arabic']?.toString() ?? '',
      exampleWord: json['example_word']?.toString() ?? '',
      narrationText: json['narration_text']?.toString() ?? '',
      displayIcon: parseLessonIcon(json['display_icon']?.toString()),
      accessLevel: access,
      starsReward: json['stars_reward'] is int ? json['stars_reward'] as int : 3,
      primaryColor: parseHexColor(json['primary_color']?.toString()),
      audioUrl: json['audio_url']?.toString() ?? json['audio_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'subtitle': subtitle,
      'content_arabic': contentArabic,
      'example_word': exampleWord,
      'narration_text': narrationText,
      'access_level': accessLevel.name,
      'stars_reward': starsReward,
      'audio_url': audioUrl,
    };
  }

  static IconData parseLessonIcon(String? name) {
    switch (name) {
      case 'pets_rounded':
        return Icons.pets_rounded;
      case 'flutter_dash_rounded':
        return Icons.flutter_dash_rounded;
      case 'eco_rounded':
        return Icons.eco_rounded;
      case 'cruelty_free_rounded':
        return Icons.cruelty_free_rounded;
      case 'brightness_3_rounded':
        return Icons.brightness_3_rounded;
      case 'visibility_rounded':
        return Icons.visibility_rounded;
      case 'water_rounded':
        return Icons.water_rounded;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      case 'circle':
        return Icons.circle;
      case 'auto_stories_rounded':
        return Icons.auto_stories_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  static Color parseHexColor(String? hexString, {Color fallback = const Color(0xFFFF7675)}) {
    if (hexString == null || hexString.isEmpty) return fallback;
    final clean = hexString.replaceAll('#', '').trim();
    final parsed = int.tryParse(clean, radix: 16);
    if (parsed == null) return fallback;
    if (clean.length == 6) {
      return Color(0xFF000000 | parsed);
    }
    return Color(parsed);
  }
}

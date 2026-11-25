import 'package:flutter/material.dart';

enum GameType {
  letterMatching,
  letterOrdering,
  unknown;

  static GameType fromString(String? type) {
    switch (type) {
      case 'letter_matching':
        return GameType.letterMatching;
      case 'letter_ordering':
        return GameType.letterOrdering;
      default:
        return GameType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case GameType.letterMatching:
        return 'مطابقة الحروف والكلمات';
      case GameType.letterOrdering:
        return 'ترتيب حروف الكلمات';
      case GameType.unknown:
        return 'لعبة تفاعلية';
    }
  }
}

class MatchingOption {
  final String id;
  final String text;
  final String subtext;
  final String emoji;
  final bool isCorrect;

  const MatchingOption({
    required this.id,
    required this.text,
    required this.subtext,
    required this.emoji,
    required this.isCorrect,
  });

  factory MatchingOption.fromJson(Map<String, dynamic> json) {
    return MatchingOption(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      subtext: json['subtext']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '⭐',
      isCorrect: json['is_correct'] == true || json['is_correct'] == 1,
    );
  }
}

class LetterMatchingPayload {
  final String targetLetter;
  final String targetWord;
  final String targetEmoji;
  final List<MatchingOption> options;

  const LetterMatchingPayload({
    required this.targetLetter,
    required this.targetWord,
    required this.targetEmoji,
    required this.options,
  });

  factory LetterMatchingPayload.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List? ?? [];
    return LetterMatchingPayload(
      targetLetter: json['target_letter']?.toString() ?? '',
      targetWord: json['target_word']?.toString() ?? '',
      targetEmoji: json['target_emoji']?.toString() ?? '⭐',
      options: rawOptions
          .map((e) => MatchingOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LetterOrderingPayload {
  final String targetWord;
  final String hintEmoji;
  final List<String> scrambledLetters;
  final List<String> correctOrder;

  const LetterOrderingPayload({
    required this.targetWord,
    required this.hintEmoji,
    required this.scrambledLetters,
    required this.correctOrder,
  });

  factory LetterOrderingPayload.fromJson(Map<String, dynamic> json) {
    final rawScrambled = json['scrambled_letters'] as List? ?? [];
    final rawCorrect = json['correct_order'] as List? ?? [];

    return LetterOrderingPayload(
      targetWord: json['target_word']?.toString() ?? '',
      hintEmoji: json['hint_emoji']?.toString() ?? '⭐',
      scrambledLetters: rawScrambled.map((e) => e.toString()).toList(),
      correctOrder: rawCorrect.map((e) => e.toString()).toList(),
    );
  }
}

class GameQuestion {
  final String id;
  final String title;
  final String prompt;
  final String? hint;
  final int questionOrder;
  final Map<String, dynamic> payload;
  final String? audioUrl;
  final bool isActive;

  const GameQuestion({
    required this.id,
    required this.title,
    required this.prompt,
    this.hint,
    required this.questionOrder,
    required this.payload,
    this.audioUrl,
    required this.isActive,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    return GameQuestion(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      hint: json['hint']?.toString(),
      questionOrder: int.tryParse(json['question_order']?.toString() ?? '1') ?? 1,
      payload: (json['payload'] is Map<String, dynamic>)
          ? json['payload'] as Map<String, dynamic>
          : {},
      audioUrl: json['audio_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  LetterMatchingPayload toLetterMatchingPayload() {
    return LetterMatchingPayload.fromJson(payload);
  }

  LetterOrderingPayload toLetterOrderingPayload() {
    return LetterOrderingPayload.fromJson(payload);
  }
}

class EducationalGame {
  final String id;
  final String? categoryId;
  final String title;
  final String slug;
  final String? description;
  final GameType gameType;
  final IconData icon;
  final Color primaryColor;
  final bool isFree;
  final int starsReward;
  final int questionsCount;
  final List<GameQuestion> questions;

  const EducationalGame({
    required this.id,
    this.categoryId,
    required this.title,
    required this.slug,
    this.description,
    required this.gameType,
    required this.icon,
    required this.primaryColor,
    required this.isFree,
    required this.starsReward,
    required this.questionsCount,
    this.questions = const [],
  });

  EducationalGame copyWithQuestions(List<GameQuestion> questions) {
    return EducationalGame(
      id: id,
      categoryId: categoryId,
      title: title,
      slug: slug,
      description: description,
      gameType: gameType,
      icon: icon,
      primaryColor: primaryColor,
      isFree: isFree,
      starsReward: starsReward,
      questionsCount: questions.length,
      questions: questions,
    );
  }

  factory EducationalGame.fromJson(Map<String, dynamic> json) {
    final questionsList = (json['active_questions'] as List? ?? json['questions'] as List? ?? [])
        .map((e) => GameQuestion.fromJson(e as Map<String, dynamic>))
        .toList();

    return EducationalGame(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      gameType: GameType.fromString(json['game_type']?.toString()),
      icon: _parseIcon(json['icon']?.toString()),
      primaryColor: _parseColor(json['primary_color']?.toString()),
      isFree: (json['access_level']?.toString() ?? 'free') == 'free',
      starsReward: int.tryParse(json['stars_reward']?.toString() ?? '5') ?? 5,
      questionsCount: int.tryParse(
              json['active_questions_count']?.toString() ??
                  json['questions_count']?.toString() ??
                  '${questionsList.length}') ??
          questionsList.length,
      questions: questionsList,
    );
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'extension_rounded':
        return Icons.extension_rounded;
      case 'sort_by_alpha_rounded':
        return Icons.sort_by_alpha_rounded;
      case 'palette_outlined':
        return Icons.palette_outlined;
      case 'videogame_asset_rounded':
      case 'videogame_asset_outlined':
      default:
        return Icons.videogame_asset_rounded;
    }
  }

  static Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF6C5CE7);
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    final intVal = int.tryParse(buffer.toString(), radix: 16);
    return intVal != null ? Color(intVal) : const Color(0xFF6C5CE7);
  }
}

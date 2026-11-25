import 'package:flutter_test/flutter_test.dart';
import 'package:lulu_kids/core/services/audio_player_service.dart';
import 'package:lulu_kids/features/lessons/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    AudioPlayerService().isTesting = true;

    const globalChannel = MethodChannel('xyz.luan/audioplayers.global');
    const playerChannel = MethodChannel('xyz.luan/audioplayers');
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(globalChannel, (MethodCall methodCall) async => 1);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(playerChannel, (MethodCall methodCall) async => 1);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall methodCall) async => '.');
  });

  group('AudioPlayerService Unit Tests', () {
    test('AudioPlayerService is a singleton', () {
      final s1 = AudioPlayerService();
      final s2 = AudioPlayerService();
      expect(identical(s1, s2), isTrue);
    });

    test('AudioPlayerService stop resets isPlaying flag safely', () async {
      final service = AudioPlayerService();
      await service.stop();
      expect(service.isPlaying, isFalse);
    });

    test('AudioPlayerService resolveAudioUrl formats paths correctly', () {
      final service = AudioPlayerService();
      expect(service.resolveAudioUrl('https://example.com/sound.mp3'), equals('https://example.com/sound.mp3'));
      expect(service.resolveAudioUrl('http://example.com/sound.mp3'), equals('http://example.com/sound.mp3'));
      expect(service.resolveAudioUrl('/storage/audio/test.mp3'), contains('/storage/audio/test.mp3'));
    });

    test('AudioPlayerService playLessonAudio and playMotivationalSound run safely', () async {
      final service = AudioPlayerService();
      const lessonWithoutAudio = Lesson(
        id: 'let_1',
        categoryId: 'cat_letters',
        title: 'حرف الألف',
        subtitle: 'أ - أرنب',
        contentArabic: 'أ',
        exampleWord: 'أرنب',
        displayIcon: Icons.pets,
        primaryColor: Colors.orange,
        narrationText: 'أ، أ، أرنب يقفز بمرح!',
      );

      const lessonWithAudio = Lesson(
        id: 'let_2',
        categoryId: 'cat_letters',
        title: 'حرف الباء',
        subtitle: 'ب - بطة',
        contentArabic: 'ب',
        exampleWord: 'بطة',
        displayIcon: Icons.pets,
        primaryColor: Colors.teal,
        narrationText: 'ب، ب، بطة!',
        audioUrl: 'http://localhost:8000/storage/audio/lessons/sample.mp3',
      );

      // Should run safely without throwing
      await service.playLessonAudio(lessonWithoutAudio);
      await service.playLessonAudio(lessonWithAudio);
      await service.playMotivationalSound('stars_reward');
      await service.stop();
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lulu_kids/features/games/models/educational_game_model.dart';
import 'package:lulu_kids/features/games/widgets/letter_matching_widget.dart';
import 'package:lulu_kids/features/games/widgets/letter_ordering_widget.dart';
import 'package:lulu_kids/features/games/game_play_screen.dart';
import 'package:lulu_kids/features/games/games_hub_screen.dart';
import 'package:lulu_kids/features/progress/progress_provider.dart';
import 'package:lulu_kids/core/services/audio_player_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AudioPlayerService().isTesting = true;
  });

  group('Educational Game Models Tests', () {
    test('parses LetterMatchingPayload correctly', () {
      final json = {
        'target_letter': 'أ',
        'target_word': 'أرنب',
        'target_emoji': '🐰',
        'options': [
          {'id': '1', 'text': 'أ', 'subtext': 'أرنب', 'emoji': '🐰', 'is_correct': true},
          {'id': '2', 'text': 'ب', 'subtext': 'بطة', 'emoji': '🦆', 'is_correct': false},
        ],
      };

      final payload = LetterMatchingPayload.fromJson(json);
      expect(payload.targetLetter, 'أ');
      expect(payload.targetWord, 'أرنب');
      expect(payload.targetEmoji, '🐰');
      expect(payload.options.length, 2);
      expect(payload.options.first.isCorrect, true);
      expect(payload.options.last.isCorrect, false);
    });

    test('parses LetterOrderingPayload correctly', () {
      final json = {
        'target_word': 'أرنب',
        'hint_emoji': '🐰',
        'scrambled_letters': ['ن', 'أ', 'ب', 'ر'],
        'correct_order': ['أ', 'ر', 'ن', 'ب'],
      };

      final payload = LetterOrderingPayload.fromJson(json);
      expect(payload.targetWord, 'أرنب');
      expect(payload.hintEmoji, '🐰');
      expect(payload.scrambledLetters, ['ن', 'أ', 'ب', 'ر']);
      expect(payload.correctOrder, ['أ', 'ر', 'ن', 'ب']);
    });
  });

  group('LetterMatchingWidget Tests', () {
    testWidgets('triggers onCorrectAnswer callback when tapping correct card', (tester) async {
      bool answered = false;

      const payload = LetterMatchingPayload(
        targetLetter: 'أ',
        targetWord: 'أرنب',
        targetEmoji: '🐰',
        options: [
          MatchingOption(id: '1', text: 'أ', subtext: 'أرنب', emoji: '🐰', isCorrect: true),
          MatchingOption(id: '2', text: 'ب', subtext: 'بطة', emoji: '🦆', isCorrect: false),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterMatchingWidget(
              payload: payload,
              onCorrectAnswer: () {
                answered = true;
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('أ'), findsWidgets);
      expect(find.text('أرنب'), findsWidgets);

      // Tap on correct card option
      await tester.tap(find.text('أ').last);
      await tester.pump(const Duration(seconds: 2));

      expect(answered, true);
    });
  });

  group('LetterOrderingWidget Tests', () {
    testWidgets('places letters in slots and verifies word', (tester) async {
      bool answered = false;

      const payload = LetterOrderingPayload(
        targetWord: 'أب',
        hintEmoji: '👨',
        scrambledLetters: ['ب', 'أ'],
        correctOrder: ['أ', 'ب'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterOrderingWidget(
              payload: payload,
              onCorrectAnswer: () {
                answered = true;
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      // Tap 'أ' then 'ب'
      await tester.tap(find.text('أ'));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('ب'));
      await tester.pump(const Duration(seconds: 2));

      expect(answered, true);
    });
  });

  group('GamesHubScreen and GamePlayScreen Tests', () {
    testWidgets('GamesHubScreen renders games list', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(),
          child: const MaterialApp(
            home: GamesHubScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('حديقة ألعاب لولو 🎮'), findsOneWidget);
      expect(find.text('لعبة مطابقة الحروف والكلمات'), findsOneWidget);
      expect(find.text('لعبة ترتيب حروف الكلمات'), findsOneWidget);
    });

    testWidgets('GamePlayScreen displays Next Question button upon correct answer', (tester) async {
      final game = ProgressProvider().games.first;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(),
          child: MaterialApp(
            home: GamePlayScreen(game: game),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Next button should NOT be visible initially
      expect(find.text('السؤال التالي ➡️'), findsNothing);

      // Tap on correct option (letter 'أ' card)
      await tester.tap(find.text('أ').last);
      await tester.pump(const Duration(seconds: 2));

      // Next button MUST now be visible!
      expect(find.text('السؤال التالي ➡️'), findsOneWidget);
    });
    testWidgets('GamePlayScreen resumes from saved stage and allows restart to stage 1', (tester) async {
      final progress = ProgressProvider();
      final game = progress.games.first;
      // محاكاة وصول الطفل للمرحلة 2 (الفهرس 1)
      await progress.saveGameStage(game.id, 1);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: progress,
          child: MaterialApp(
            home: GamePlayScreen(game: game),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // تحقق من فتح اللعبة على المرحلة 2
      expect(find.text('المرحلة 2 من ${game.questionsCount}'), findsOneWidget);
      // تحقق من ظهور زر المرحلة 1 للعودة للبداية
      expect(find.text('المرحلة 1'), findsOneWidget);
      // تحقق من ظهور لافتة مواصلة اللعب
      expect(find.textContaining('تواصل اللعب من حيث توقفت'), findsOneWidget);

      // الضغط على زر العودة للمرحلة الأولى
      await tester.tap(find.text('المرحلة 1'));
      await tester.pump(const Duration(milliseconds: 300));

      // يظهر حوار التأكيد
      expect(find.text('العودة للمرحلة الأولى؟'), findsOneWidget);
      await tester.tap(find.text('نعم، ابدأ من البداية 🔄'));
      await tester.pump(const Duration(milliseconds: 300));

      // أصبحت الآن المرحلة 1
      expect(find.text('المرحلة 1 من ${game.questionsCount}'), findsOneWidget);
      expect(progress.getSavedStageForGame(game.id), 0);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('GamesHubScreen displays resume badge and reset button when game has progress', (tester) async {
      final progress = ProgressProvider();
      final game = progress.games.first;
      await progress.saveGameStage(game.id, 2);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: progress,
          child: const MaterialApp(
            home: GamesHubScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // تحقق من ظهور شارة مواصلة اللعبة
      expect(find.text('واصل: مرحلة 3'), findsOneWidget);
      // تحقق من ظهور زر الإعادة على البطاقة
      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

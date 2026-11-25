import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/audio_player_service.dart';
import '../progress/progress_provider.dart';
import 'models/educational_game_model.dart';
import 'widgets/letter_matching_widget.dart';
import 'widgets/letter_ordering_widget.dart';
import 'widgets/game_victory_dialog.dart';

class GamePlayScreen extends StatefulWidget {
  final EducationalGame game;

  const GamePlayScreen({
    super.key,
    required this.game,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  int _currentQuestionIndex = 0;
  bool _isAnswered = false;
  late List<GameQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.game.questions.isNotEmpty
        ? widget.game.questions
        : _fallbackQuestionsForGame(widget.game);

    // استعادة المرحلة المحفوظة التي توقف عندها الطفل
    final savedIndex = context.read<ProgressProvider>().getSavedStageForGame(widget.game.id);
    if (savedIndex > 0 && savedIndex < _questions.length) {
      _currentQuestionIndex = savedIndex;
    }

    // تشغيل الصوت التوجيهي للمرحلة إن وُجد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCurrentQuestionAudio();
    });
  }

  void _playCurrentQuestionAudio() {
    if (_questions.isNotEmpty && _currentQuestionIndex < _questions.length) {
      final audioUrl = _questions[_currentQuestionIndex].audioUrl;
      if (audioUrl != null && audioUrl.isNotEmpty) {
        AudioPlayerService().playAudioUrl(audioUrl);
      }
    }
  }

  void _onCorrectAnswer() {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
    });

    // تشغيل صوت الإجابة الصحيحة والتشجيع
    AudioPlayerService().playMotivationalSound('correct_answer');
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
      });
      // حفظ رقم المرحلة التي وصل إليها الطفل لمواصلة اللعب لاحقاً
      context.read<ProgressProvider>().saveGameStage(widget.game.id, _currentQuestionIndex);
      _playCurrentQuestionAudio();
    } else {
      _finishGame();
    }
  }

  Future<void> _confirmRestartFromBeginning() async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.replay_rounded, color: AppColors.playfulCoral),
            const SizedBox(width: 8),
            Text(
              'العودة للمرحلة الأولى؟',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'هل تريد إعادة هذه اللعبة والبدء من المرحلة 1 يا بطل؟',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: AppTypography.bodyMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.playfulCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، ابدأ من البداية 🔄', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldRestart == true && mounted) {
      setState(() {
        _currentQuestionIndex = 0;
        _isAnswered = false;
      });
      await context.read<ProgressProvider>().resetGameStage(widget.game.id);
      _playCurrentQuestionAudio();
    }
  }

  Future<void> _finishGame() async {
    // تشغيل صوت مكافأة النجوم
    await AudioPlayerService().playMotivationalSound('stars_reward');

    if (!mounted) return;

    // إضافة النجوم لتقدم الطفل
    await context.read<ProgressProvider>().completeEducationalGame(widget.game);

    if (!mounted) return;

    // عرض نافذة الفوز والاحتفال
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameVictoryDialog(
        gameTitle: widget.game.title,
        starsReward: widget.game.starsReward,
        onReplay: () {
          Navigator.pop(context);
          setState(() {
            _currentQuestionIndex = 0;
            _isAnswered = false;
          });
          _playCurrentQuestionAudio();
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.game.title)),
        body: const Center(
          child: Text('المراحل قادمة قريباً لهذه اللعبة! 🌟'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progressPercent = (_currentQuestionIndex + 1) / _questions.length;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.game.title,
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          // زر العودة للمرحلة الأولى إذا تجاوز المرحلة الأولى
          if (_currentQuestionIndex > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: TextButton.icon(
                onPressed: _confirmRestartFromBeginning,
                icon: const Icon(Icons.replay_rounded, size: 18, color: AppColors.playfulCoral),
                label: Text(
                  'المرحلة 1',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.playfulCoral,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          // عداد النجوم الحالي
          Consumer<ProgressProvider>(
            builder: (_, prog, __) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sunshineYellow, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.goldenStar, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${prog.starsCount}',
                    style: AppTypography.starCounterText.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // شريط التقدم بين المراحل
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المرحلة ${_currentQuestionIndex + 1} من ${_questions.length}',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        currentQuestion.title,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // تنبيه استكمال المرحلة إن كان في مرحلة متقدمة مع زر البدء من البداية
            if (_currentQuestionIndex > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تواصل اللعب من حيث توقفت (المرحلة ${_currentQuestionIndex + 1}) 🌟',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _confirmRestartFromBeginning,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.playfulCoral.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.replay_rounded, size: 14, color: AppColors.playfulCoral),
                              const SizedBox(width: 4),
                              Text(
                                'ابدأ من البداية',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.playfulCoral,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // محتوى السؤال واللعبة القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // نص السؤال التوجيهي
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.islandShadow,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology_alt_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentQuestion.prompt,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (currentQuestion.hint != null &&
                                    currentQuestion.hint!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '💡 تلميح: ${currentQuestion.hint}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // زر الاستماع للصوت إن وُجد
                          if (currentQuestion.audioUrl != null &&
                              currentQuestion.audioUrl!.isNotEmpty)
                            IconButton(
                              onPressed: _playCurrentQuestionAudio,
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                color: AppColors.primary,
                                size: 26,
                              ),
                              tooltip: 'استمع للتوجيه',
                            ),
                        ],
                      ),
                    ),

                    // ودجت اللعبة المخصصة حسب النوع
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildGameWidget(currentQuestion),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // زر "التالي" الذي يظهر عندما يجيب الطفل إجابة صحيحة!
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _goToNextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mintGreen,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: AppColors.mintGreen.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastQuestion
                              ? 'إنهاء اللعبة ونيل النجوم! 🌟'
                              : 'السؤال التالي ➡️',
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameWidget(GameQuestion question) {
    if (widget.game.gameType == GameType.letterMatching) {
      return LetterMatchingWidget(
        key: ValueKey(question.id),
        payload: question.toLetterMatchingPayload(),
        onCorrectAnswer: _onCorrectAnswer,
      );
    } else if (widget.game.gameType == GameType.letterOrdering) {
      return LetterOrderingWidget(
        key: ValueKey(question.id),
        payload: question.toLetterOrderingPayload(),
        onCorrectAnswer: _onCorrectAnswer,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.extension_rounded, size: 60, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              question.prompt,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onCorrectAnswer,
              child: const Text('أحسنت! إجابة صحيحة'),
            ),
          ],
        ),
      );
    }
  }

  List<GameQuestion> _fallbackQuestionsForGame(EducationalGame game) {
    if (game.gameType == GameType.letterOrdering) {
      return const [
        GameQuestion(
          id: 'fb_1',
          title: 'المرحلة 1: كلمة أرنب',
          prompt: 'رتّب حروف كلمة (أَرْنَب) يا بطل 🐰',
          hint: 'ابدأ بحرف الألف ثم الراء ثم النون ثم الباء',
          questionOrder: 1,
          isActive: true,
          payload: {
            'target_word': 'أرنب',
            'hint_emoji': '🐰',
            'scrambled_letters': ['ن', 'أ', 'ب', 'ر'],
            'correct_order': ['أ', 'ر', 'ن', 'ب'],
          },
        ),
      ];
    }

    return const [
      GameQuestion(
        id: 'fb_0',
        title: 'المرحلة 1: حرف الألف (أ)',
        prompt: 'أي بطاقة تبدأ بحرف الألف (أ)؟ 🐰',
        hint: 'حيوان أليف يحب الجزر ولديه أذنان طويلتان',
        questionOrder: 1,
        isActive: true,
        payload: {
          'target_letter': 'أ',
          'target_word': 'أرنب',
          'target_emoji': '🐰',
          'options': [
            {'id': '1', 'text': 'أ', 'subtext': 'أرنب', 'emoji': '🐰', 'is_correct': true},
            {'id': '2', 'text': 'ب', 'subtext': 'بطة', 'emoji': '🦆', 'is_correct': false},
            {'id': '3', 'text': 'ت', 'subtext': 'تمساح', 'emoji': '🐊', 'is_correct': false},
          ],
        },
      ),
    ];
  }
}

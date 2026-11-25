import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/lulu_button.dart';
import '../../core/widgets/lulu_character.dart';
import '../progress/progress_provider.dart';
import 'models/lesson_model.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final AudioPlayerService _audio = AudioPlayerService();
  bool _isSpeaking = false;
  bool _rewardCollected = false;

  @override
  void initState() {
    super.initState();
    _audio.onAudioStarted = () {
      if (mounted) setState(() => _isSpeaking = true);
    };
    _audio.onAudioCompleted = () {
      if (mounted) setState(() => _isSpeaking = false);
    };

    // تشغيل المقطع الصوتي المرفوع للدرس إن وُجد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.lesson.audioUrl != null && widget.lesson.audioUrl!.isNotEmpty) {
        _audio.playLessonAudio(widget.lesson);
      }
    });
  }

  @override
  void dispose() {
    _audio.stop();
    _audio.onAudioStarted = null;
    _audio.onAudioCompleted = null;
    super.dispose();
  }

  void _playNarration() {
    if (_isSpeaking) {
      _audio.stop();
    } else {
      _audio.playLessonAudio(widget.lesson);
    }
  }

  void _playCardPronunciation() {
    _audio.playLessonAudio(widget.lesson);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final isAlreadyCompleted = progress.completedLessonIds.contains(widget.lesson.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.lesson.title, style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                key: ValueKey<bool>(_isSpeaking),
                color: _isSpeaking ? AppColors.goldenStar : AppColors.primary,
                size: 30,
              ),
            ),
            tooltip: _isSpeaking ? 'إيقاف الصوت' : 'الاستماع لصوت وشرح لولو',
            onPressed: _playNarration,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // حوار لولو التفاعلي مع الطفل (يمكن الضغط عليه للاستماع)
              GestureDetector(
                onTap: _playNarration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LuluCharacter(size: _isSpeaking ? 100 : 90)
                        .animate(target: _isSpeaking ? 1 : 0)
                        .shake(duration: 400.ms, hz: 2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isSpeaking
                                  ? AppColors.primary.withValues(alpha: 0.25)
                                  : AppColors.islandShadow,
                              blurRadius: _isSpeaking ? 16 : 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: _isSpeaking
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                            width: _isSpeaking ? 2.5 : 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الأرنب لولو يشرح لك:',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _isSpeaking ? Icons.graphic_eq_rounded : Icons.record_voice_over_rounded,
                                  size: 18,
                                  color: _isSpeaking ? AppColors.primary : AppColors.textMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.lesson.narrationText,
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // بطاقة التعلم التفاعلية الكبيرة (المس لنطق الحرف والكلمة فوراً)
              GestureDetector(
                onTap: _playCardPronunciation,
                child: Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: widget.lesson.primaryColor.withValues(alpha: 0.35),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.lesson.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // علامة مائية مرحة في الخلفية
                      Positioned(
                        right: 20,
                        bottom: 10,
                        child: Icon(
                          widget.lesson.displayIcon,
                          size: 130,
                          color: widget.lesson.primaryColor.withValues(alpha: 0.08),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.lesson.contentArabic,
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 90,
                              fontWeight: FontWeight.w900,
                              color: widget.lesson.primaryColor,
                            ),
                          )
                              .animate(target: _isSpeaking ? 1 : 0)
                              .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 250.ms),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.lesson.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              widget.lesson.exampleWord,
                              style: AppTypography.titleLarge.copyWith(
                                color: widget.lesson.primaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volume_up_rounded,
                                size: 18,
                                color: widget.lesson.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'المس هنا لسماع نطق الحرف والكلمة 🔊',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.lesson.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // زر إكمال الدرس وجمع النجوم
              if (isAlreadyCompleted || _rewardCollected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mintGreen, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.goldenStar, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'أحسنت يا بطل! تم جمع نجوم هذا الدرس 🌟',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.mintGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn()
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0))
              else
                LuluButton(
                  label: 'أتقنت هذا الدرس! (جمع 3 نجوم) ⭐',
                  backgroundColor: AppColors.sunshineYellow,
                  shadowColor: const Color(0xFFE58E26),
                  icon: Icons.star_rounded,
                  onPressed: () {
                    setState(() => _rewardCollected = true);
                    progress.completeLesson(widget.lesson.id, widget.lesson.starsReward);
                    _audio.playMotivationalSound('stars_reward');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.mintGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: Text(
                          'رائع جداً! أضفنا 3 نجوم إلى صندوقك يا بطل! 🌟🌟🌟',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

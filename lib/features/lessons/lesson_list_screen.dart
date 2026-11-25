import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'models/lesson_model.dart';
import '../progress/progress_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/parental_gate.dart';
import '../parent_portal/subscription_screen.dart';
import 'lesson_detail_screen.dart';
import '../../core/services/audio_player_service.dart';

class LessonListScreen extends StatelessWidget {
  final LessonCategory category;

  const LessonListScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final lessons = progress.getLessonsForCategory(category.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          category.title,
          style: AppTypography.titleLarge,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sunshineYellow, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.goldenStar, size: 22),
                const SizedBox(width: 4),
                Text(
                  '${progress.starsCount}',
                  style: AppTypography.starCounterText.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: lessons.isEmpty
          ? Center(
              child: Text(
                'الدروس قادمة قريباً في هذه الجزيرة! 🌟',
                style: AppTypography.titleMedium,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.76,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isCompleted = progress.completedLessonIds.contains(lesson.id);
                final isLocked = lesson.accessLevel == AccessLevel.premium && !progress.isSubscribed;

                return GestureDetector(
                  onTap: () async {
                    if (isLocked) {
                      final passed = await ParentalGate.show(context);
                      if (passed && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionScreen(),
                          ),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonDetailScreen(lesson: lesson),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isLocked
                            ? const Color(0xFFDFE6E9)
                            : lesson.primaryColor.withValues(alpha: 0.35),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isLocked
                              ? Colors.black.withValues(alpha: 0.04)
                              : lesson.primaryColor.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // حرف / رقم / رمز كبير
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? const Color(0xFFF1F2F6)
                                      : lesson.primaryColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    lesson.contentArabic,
                                    style: AppTypography.displayMedium.copyWith(
                                      fontSize: 26,
                                      color: isLocked ? AppColors.textLight : lesson.primaryColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lesson.title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 15,
                                  color: isLocked ? AppColors.textMedium : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lesson.exampleWord,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // شارة الإنجاز أو القفل
                        if (isCompleted)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.mintGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          )
                        else if (isLocked)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.sunshineYellow,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          )
                        else if (lesson.audioUrl != null && lesson.audioUrl!.isNotEmpty)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: InkWell(
                              onTap: () => AudioPlayerService().playLessonAudio(lesson),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: lesson.primaryColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  color: lesson.primaryColor,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (index * 80).ms, duration: 400.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
              },
            ),
    );
  }
}

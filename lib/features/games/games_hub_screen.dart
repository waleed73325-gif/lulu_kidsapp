import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/lulu_character.dart';
import '../../core/utils/parental_gate.dart';
import '../../core/network/api_service.dart';
import '../progress/progress_provider.dart';
import '../parent_portal/subscription_screen.dart';
import 'models/educational_game_model.dart';
import 'game_play_screen.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  Future<void> _launchGame(BuildContext context, EducationalGame game) async {
    final progress = context.read<ProgressProvider>();
    final isLocked = !game.isFree && !progress.isSubscribed;

    if (isLocked) {
      final passed = await ParentalGate.show(context);
      if (passed && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
      }
      return;
    }

    // إذا كانت اللعبة لا تحتوي على الأسئلة بعد، نجلبها من السيرفر
    EducationalGame gameToPlay = game;
    if (game.questions.isEmpty) {
      try {
        final res = await ApiService().getGameDetails(game.id);
        if (res.statusCode == 200 && res.data != null && res.data['data'] != null) {
          gameToPlay = EducationalGame.fromJson(res.data['data'] as Map<String, dynamic>);
        }
      } catch (_) {
        // الاستمرار باللعبة الحالية
      }
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GamePlayScreen(game: gameToPlay),
        ),
      );
    }
  }

  Future<void> _confirmResetGame(
    BuildContext context,
    ProgressProvider progress,
    EducationalGame game,
  ) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.replay_rounded, color: AppColors.playfulCoral),
            const SizedBox(width: 8),
            Text(
              'إعادة اللعبة للبداية؟',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'هل تريد إعادة لعبة "${game.title}" والبدء من المرحلة الأولى؟',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.playfulCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'نعم، ابدأ من البداية 🔄',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldReset == true && context.mounted) {
      await progress.resetGameStage(game.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إعادة لعبة "${game.title}" للمرحلة الأولى! 🚀'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final games = progress.games;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'حديقة ألعاب لولو 🎮',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
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
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await context.read<ProgressProvider>().fetchRemoteContent();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // لافتة الترحيب بحديقة الألعاب
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.gamesIslandGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bubblegumPink.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const LuluCharacter(size: 85),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ألعاب الذكاء والمرح! 🎈',
                                style: AppTypography.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'طابق الحروف، ورتّب الكلمات، وتحدى ذكاءك لتكسب النجوم البراقة مع لولو!',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // عنوان قائمة الألعاب
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.videogame_asset_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'اختر لعبتك التعليمية المفضلة:',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // قائمة بطاقات الألعاب
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = games[index];
                      final isLocked = !game.isFree && !progress.isSubscribed;
                      final savedStage = progress.getSavedStageForGame(game.id);
                      final hasProgress = savedStage > 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.islandShadow,
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: game.primaryColor.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => _launchGame(context, game),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  // رمز اللعبة الملون
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: game.primaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: game.primaryColor.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      game.icon,
                                      color: game.primaryColor,
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                game.title,
                                                style: AppTypography.titleMedium.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ),
                                            if (isLocked)
                                              const Icon(Icons.lock_rounded, color: AppColors.playfulCoral, size: 20),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          game.description ?? 'لعبة تعليمية ممتعة مع لولو للأطفال',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textMedium,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: game.primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${game.questionsCount} مراحل',
                                                style: AppTypography.bodySmall.copyWith(
                                                  color: game.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF9E6),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star_rounded, color: AppColors.goldenStar, size: 16),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '+${game.starsReward}',
                                                    style: AppTypography.bodySmall.copyWith(
                                                      color: AppColors.textDark,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (hasProgress)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.playfulCoral.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppColors.playfulCoral.withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.play_arrow_rounded, color: AppColors.playfulCoral, size: 15),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'واصل: مرحلة ${savedStage + 1}',
                                                      style: AppTypography.bodySmall.copyWith(
                                                        color: AppColors.playfulCoral,
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (hasProgress) ...[
                                        IconButton(
                                          icon: const Icon(Icons.replay_rounded, color: AppColors.playfulCoral, size: 22),
                                          tooltip: 'البدء من المرحلة الأولى',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => _confirmResetGame(context, progress, game),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.neutralMedium,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
                    },
                    childCount: games.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

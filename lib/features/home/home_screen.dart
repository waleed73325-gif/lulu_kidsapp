import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/parental_gate.dart';
import '../../core/widgets/lulu_character.dart';
import '../lessons/lesson_list_screen.dart';
import '../lessons/models/lesson_model.dart';
import '../games/games_hub_screen.dart';
import '../parent_portal/parent_portal_screen.dart';
import '../progress/progress_provider.dart';
import 'widgets/island_card.dart';
import 'widgets/star_counter_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await context.read<ProgressProvider>().fetchRemoteContent();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
            // الشريط العلوي المخصص للأطفال وبوابة الوالدين
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // رصيد نجوم الطفل
                    StarCounterBadge(
                      count: progress.starsCount,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'لديك ${progress.starsCount} نجمة براقة يا بطل! 🌟 أحسنت!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),

                    // بوابة ولي الأمر المحمية
                    GestureDetector(
                      onTap: () async {
                        final passed = await ParentalGate.show(context);
                        if (passed && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ParentPortalScreen(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.islandShadow,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.family_restroom_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ولي الأمر',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
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

            // لولو الترحيبي ورسالة اليوم
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.islandShadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const LuluCharacter(size: 80),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أهلاً ${progress.childNickname}! 👋',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'هيا نخوض مغامرة شيقة في جزر لولو التعليمية! اختر الجزيرة التي تحبها اليوم 🎈',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMedium,
                                fontSize: 13,
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

            // عنوان قسم الجزر
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.explore_rounded, color: AppColors.playfulCoral, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'جزر لولو التعليمية',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // قائمة الجزر
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = progress.categories[index];
                  return IslandCard(
                    category: category,
                    onTap: () {
                      if (category.type == CategoryType.games || category.id.contains('game')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GamesHubScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonListScreen(category: category),
                          ),
                        );
                      }
                    },
                  );
                },
                childCount: progress.categories.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

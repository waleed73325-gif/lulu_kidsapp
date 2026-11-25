import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/educational_game_model.dart';

class LetterMatchingWidget extends StatefulWidget {
  final LetterMatchingPayload payload;
  final VoidCallback onCorrectAnswer;

  const LetterMatchingWidget({
    super.key,
    required this.payload,
    required this.onCorrectAnswer,
  });

  @override
  State<LetterMatchingWidget> createState() => _LetterMatchingWidgetState();
}

class _LetterMatchingWidgetState extends State<LetterMatchingWidget> {
  String? _selectedOptionId;
  bool _isAnsweredCorrectly = false;

  @override
  void didUpdateWidget(covariant LetterMatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload.targetLetter != widget.payload.targetLetter ||
        oldWidget.payload.targetWord != widget.payload.targetWord) {
      _selectedOptionId = null;
      _isAnsweredCorrectly = false;
    }
  }

  void _onOptionTap(MatchingOption option) {
    if (_isAnsweredCorrectly) return;

    if (option.isCorrect) {
      setState(() {
        _selectedOptionId = option.id;
        _isAnsweredCorrectly = true;
      });
      widget.onCorrectAnswer();
    } else {
      setState(() {
        _selectedOptionId = option.id;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حاول ثانية يا بطل! ركّز في الحرف والصورة 🎈',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.playfulCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;

    return Column(
      children: [
        // الحرف والكلمة والرمز المستهدف
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: AppColors.islandShadow,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                payload.targetEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الحرف المطلوب:',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        payload.targetLetter,
                        style: AppTypography.displayLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 46,
                        ),
                      ),
                      if (payload.targetWord.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Text(
                          '(${payload.targetWord})',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'المس البطاقة المطابقة الصحيحة أدناه:',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // بطاقات الخيارات التفاعلية
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: payload.options.map((opt) {
                  final isSelected = _selectedOptionId == opt.id;
                  final isCorrect = opt.isCorrect;

                  Color cardBg = Colors.white;
                  Color borderColor = AppColors.neutralSoft;
                  double borderWidth = 2.0;

                  if (isSelected && isCorrect) {
                    cardBg = const Color(0xFFE8F8F5);
                    borderColor = AppColors.mintGreen;
                    borderWidth = 3.5;
                  } else if (isSelected && !isCorrect) {
                    cardBg = const Color(0xFFFDEDEC);
                    borderColor = AppColors.playfulCoral;
                    borderWidth = 3.0;
                  }

                  final cardWidth = (constraints.maxWidth - 36) /
                      (payload.options.length <= 3 ? payload.options.length : 3);

                  Widget card = GestureDetector(
                    onTap: () => _onOptionTap(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: cardWidth.clamp(95.0, 140.0),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: borderWidth),
                        boxShadow: [
                          BoxShadow(
                            color: (isSelected && isCorrect)
                                ? AppColors.mintGreen.withValues(alpha: 0.3)
                                : AppColors.islandShadow,
                            blurRadius: (isSelected && isCorrect) ? 14 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            opt.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            opt.text,
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: (isSelected && isCorrect)
                                  ? AppColors.mintGreen
                                  : AppColors.primary,
                            ),
                          ),
                          if (opt.subtext.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              opt.subtext,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (isSelected && isCorrect) ...[
                            const SizedBox(height: 6),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.mintGreen,
                              size: 26,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );

                  return AnimatedScale(
                    scale: (isSelected && isCorrect) ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: card,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

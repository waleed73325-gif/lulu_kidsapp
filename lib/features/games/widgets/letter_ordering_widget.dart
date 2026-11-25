import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/educational_game_model.dart';

class LetterOrderingWidget extends StatefulWidget {
  final LetterOrderingPayload payload;
  final VoidCallback onCorrectAnswer;

  const LetterOrderingWidget({
    super.key,
    required this.payload,
    required this.onCorrectAnswer,
  });

  @override
  State<LetterOrderingWidget> createState() => _LetterOrderingWidgetState();
}

class _LetterOrderingWidgetState extends State<LetterOrderingWidget> {
  late List<String?> _placedLetters;
  late List<bool> _isLetterUsed;
  late List<String> _availablePool;
  bool _isAnsweredCorrectly = false;
  int _shakeAttemptKey = 0;

  @override
  void initState() {
    super.initState();
    _initRound();
  }

  @override
  void didUpdateWidget(covariant LetterOrderingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload.targetWord != widget.payload.targetWord) {
      _initRound();
    }
  }

  void _initRound() {
    final correct = widget.payload.correctOrder;
    _placedLetters = List<String?>.filled(correct.length, null);
    _availablePool = List<String>.from(widget.payload.scrambledLetters);
    _isLetterUsed = List<bool>.filled(_availablePool.length, false);
    _isAnsweredCorrectly = false;
    _shakeAttemptKey = 0;
  }

  void _onLetterPoolTap(int poolIndex) {
    if (_isAnsweredCorrectly || _isLetterUsed[poolIndex]) return;

    final letter = _availablePool[poolIndex];
    // ابحث عن أول خانة فارغة
    final emptySlotIndex = _placedLetters.indexOf(null);
    if (emptySlotIndex != -1) {
      setState(() {
        _placedLetters[emptySlotIndex] = letter;
        _isLetterUsed[poolIndex] = true;
      });

      _checkCompletion();
    }
  }

  void _onSlotTap(int slotIndex) {
    if (_isAnsweredCorrectly) return;

    final letter = _placedLetters[slotIndex];
    if (letter != null) {
      // إرجاع الحرف إلى المجمع
      for (int i = 0; i < _availablePool.length; i++) {
        if (_availablePool[i] == letter && _isLetterUsed[i]) {
          setState(() {
            _isLetterUsed[i] = false;
            _placedLetters[slotIndex] = null;
          });
          break;
        }
      }
    }
  }

  void _checkCompletion() {
    // إذا امتلأت جميع الخانات
    if (!_placedLetters.contains(null)) {
      final formed = _placedLetters.map((e) => e ?? '').join();
      final target = widget.payload.correctOrder.join();

      if (formed == target) {
        setState(() {
          _isAnsweredCorrectly = true;
        });
        widget.onCorrectAnswer();
      } else {
        setState(() {
          _shakeAttemptKey++;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'الترتيب غير صحيح، اضغط على الحرف لتغييره يا بطل! 🔄',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 1),
            backgroundColor: AppColors.playfulCoral,
          ),
        );
      }
    }
  }

  void _resetPool() {
    if (_isAnsweredCorrectly) return;
    setState(() {
      _placedLetters = List<String?>.filled(widget.payload.correctOrder.length, null);
      _isLetterUsed = List<bool>.filled(_availablePool.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;

    return Column(
      children: [
        // تلميح الكلمة والصورة
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              color: AppColors.mintGreen.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                payload.hintEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الكلمة المطلوب تكوينها:',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    payload.targetWord,
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.mintGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

        const SizedBox(height: 16),

        // خانات وضع الحروف بالترتيب (Slots)
        Text(
          'رتّب الحروف في الخانات بالترتيب الصحيح:',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: _isAnsweredCorrectly
                  ? const Color(0xFFE8F8F5)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isAnsweredCorrectly ? AppColors.mintGreen : AppColors.neutralSoft,
                width: _isAnsweredCorrectly ? 3 : 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_placedLetters.length, (index) {
                final letter = _placedLetters[index];
                final isFilled = letter != null;

                return GestureDetector(
                  onTap: () => _onSlotTap(index),
                  child: Container(
                    width: 58,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? (_isAnsweredCorrectly
                              ? AppColors.mintGreen
                              : AppColors.primary)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFilled ? Colors.transparent : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color: (_isAnsweredCorrectly
                                        ? AppColors.mintGreen
                                        : AppColors.primary)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter ?? '_',
                      style: AppTypography.displayMedium.copyWith(
                        color: isFilled ? Colors.white : Colors.grey.shade400,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ).animate(key: ValueKey(_shakeAttemptKey)).shake(
                duration: 400.ms,
                hz: 4,
                curve: Curves.easeInOut,
              ),
        ),

        const SizedBox(height: 24),

        // الحروف المبعثرة المتاحة للضغط
        Text(
          'اضغط على الحرف لنقله إلى الخانة:',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMedium,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_availablePool.length, (index) {
              final letter = _availablePool[index];
              final isUsed = _isLetterUsed[index];

              return GestureDetector(
                onTap: isUsed ? null : () => _onLetterPoolTap(index),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isUsed ? 0.25 : 1.0,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.sunshineYellow,
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.islandShadow,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.textDark,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // زر إعادة المحاولة وتفريغ الخانات
        if (!_isAnsweredCorrectly && _placedLetters.any((l) => l != null))
          TextButton.icon(
            onPressed: _resetPool,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.playfulCoral),
            label: Text(
              'تفريغ الخانات والبدء من جديد',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.playfulCoral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

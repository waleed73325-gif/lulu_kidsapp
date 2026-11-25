import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// ويدجت شخصية الأرنب "لولو" مرسومة كرتونياً لتظهر فورياً وتتحرك بمرح
class LuluCharacter extends StatelessWidget {
  final double size;
  final bool isAnimated;
  final String mood; // 'happy', 'waving', 'thinking'

  const LuluCharacter({
    super.key,
    this.size = 140,
    this.isAnimated = true,
    this.mood = 'happy',
  });

  @override
  Widget build(BuildContext context) {
    Widget character = SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // أذنا الأرنب لولو
          Positioned(
            top: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEar(isLeft: true),
                SizedBox(width: size * 0.15),
                _buildEar(isLeft: false),
              ],
            ),
          ),
          // وجه لولو
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.85,
              height: size * 0.82,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF1F2F6),
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الخدود الوردية
                  Positioned(
                    bottom: size * 0.28,
                    left: size * 0.12,
                    child: _buildCheek(),
                  ),
                  Positioned(
                    bottom: size * 0.28,
                    right: size * 0.12,
                    child: _buildCheek(),
                  ),
                  // العينان
                  Positioned(
                    top: size * 0.26,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEye(),
                        SizedBox(width: size * 0.22),
                        _buildEye(),
                      ],
                    ),
                  ),
                  // أنف لولو والابتسامة
                  Positioned(
                    bottom: size * 0.24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // أنف وردي لطيف
                        Container(
                          width: size * 0.12,
                          height: size * 0.08,
                          decoration: BoxDecoration(
                            color: AppColors.candyPink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 3),
                        // ابتسامة لولو الواسعة
                        Container(
                          width: size * 0.22,
                          height: size * 0.11,
                          decoration: const BoxDecoration(
                            color: AppColors.textDark,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: size * 0.12,
                              height: size * 0.06,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF7675),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ربطة عنق لطيفة للولو
          Positioned(
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sunshineYellow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFE58E26),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );

    if (isAnimated) {
      return character
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: 0, end: -8, duration: 1200.ms, curve: Curves.easeInOut)
          .scaleXY(begin: 1.0, end: 1.03, duration: 1200.ms);
    }

    return character;
  }

  Widget _buildEar({required bool isLeft}) {
    return Transform.rotate(
      angle: isLeft ? -0.15 : 0.15,
      child: Container(
        width: size * 0.24,
        height: size * 0.52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.14),
          border: Border.all(
            color: const Color(0xFFF1F2F6),
            width: 2.5,
          ),
        ),
        child: Center(
          child: Container(
            width: size * 0.12,
            height: size * 0.36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD1DC),
              borderRadius: BorderRadius.circular(size * 0.08),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: size * 0.12,
      height: size * 0.14,
      decoration: const BoxDecoration(
        color: AppColors.textDark,
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: const Alignment(-0.4, -0.4),
        child: Container(
          width: size * 0.045,
          height: size * 0.045,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildCheek() {
    return Container(
      width: size * 0.14,
      height: size * 0.08,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB8B8).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

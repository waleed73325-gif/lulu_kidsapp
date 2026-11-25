import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// بوابة ولي الأمر (Parental Gate) لحماية منطقة الإعدادات والشراء
/// تطابق إرشادات متاجر التطبيقات لحماية الأطفال من التعديل غير المصرح به
class ParentalGate {
  static Future<bool> show(BuildContext context) async {
    final random = Random();
    final num1 = random.nextInt(8) + 2; // 2 to 9
    final num2 = random.nextInt(8) + 2; // 2 to 9
    final correctAnswer = num1 * num2;

    final controller = TextEditingController();
    bool passed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.islandShadow,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'منطقة ولي الأمر',
                        style: AppTypography.titleLarge.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'للتحقق، يرجى من ولي الأمر حل المسألة التالية:',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '$num1 × $num2 = ؟',
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 24,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTypography.titleLarge.copyWith(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: 'اكتب الناتج هنا',
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          errorText: errorMessage,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'إلغاء',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final entered = int.tryParse(controller.text.trim());
                                if (entered == correctAnswer) {
                                  passed = true;
                                  Navigator.pop(dialogCtx);
                                } else {
                                  setState(() {
                                    errorMessage = 'إجابة غير صحيحة، حاول ثانية';
                                    controller.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'دخول',
                                style: AppTypography.buttonText.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return passed;
  }
}

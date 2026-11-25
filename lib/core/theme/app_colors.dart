import 'package:flutter/material.dart';

/// نظام الألوان المعتمد لتطبيق لولو للأطفال
/// مصمم بعناية ليكون دافئاً، مبهجاً، ومحفزاً للأطفال دون إجهاد العين
class AppColors {
  // الألوان الأساسية
  static const Color primary = Color(0xFF6C5CE7); // بنفسجي لولو الدافئ
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // ألوان التفاعل والتشجيع
  static const Color sunshineYellow = Color(0xFFFDCB6E); // أصفر النجوم والشمس
  static const Color goldenStar = Color(0xFFFFA502); // لون النجمة الذهبية
  static const Color playfulCoral = Color(0xFFFF7675); // مرجاني مرح
  static const Color mintGreen = Color(0xFF00B894); // أخضر الإنجاز والإجابات الصحيحة
  static const Color skyBlue = Color(0xFF0984E3); // أزرق سماء هادئ
  static const Color candyPink = Color(0xFFFD79A8); // وردي قصص لولو
  static const Color orangeFun = Color(0xFFE17055); // برتقالي الألعاب

  // خلفيات مسار الطفل
  static const Color background = Color(0xFFF8F9FE); // خلفية بيضاء مزرقة مريحة
  static const Color cardSurface = Colors.white;
  static const Color islandShadow = Color(0x1F2D3436);

  // نصوص وعناصر رمادية
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  static const Color neutralSoft = Color(0xFFDFE6E9);
  static const Color neutralMedium = Color(0xFFB2BEC3);
  static const Color bubblegumPink = Color(0xFFFD79A8);

  // تدرجات لونية لجزر لولو
  static const LinearGradient lettersIslandGradient = LinearGradient(
    colors: [Color(0xFFFF7675), Color(0xFFFD79A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient numbersIslandGradient = LinearGradient(
    colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient colorsIslandGradient = LinearGradient(
    colors: [Color(0xFFFDCB6E), Color(0xFFE17055)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storiesIslandGradient = LinearGradient(
    colors: [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gamesIslandGradient = LinearGradient(
    colors: [Color(0xFF55EFC4), Color(0xFF00B894)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';

/// شاشة البداية والترحيب (Splash & Welcome Screen)
/// مصممة خصيصاً ومطابقة بنسبة 100% للتصميم المرجعي لشخصية وعالم لولو للأطفال
class SplashScreen extends StatelessWidget {
  final bool isTest;

  const SplashScreen({
    super.key,
    this.isTest = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // ضبط أحجام العناصر بمرونة لتناسب كافة مقاسات الشاشات والجوالات والأجهزة اللوحية
    final isCompact = size.height < 680;
    final heroHeight = isCompact ? size.height * 0.38 : size.height * 0.44;

    return Scaffold(
      backgroundColor: const Color(0xFF5BA2F8),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. الخلفية الطبيعية والساحرة (سماء مشمسة، قوس قزح، تلال وأشجار كرتونية وزهور)
          Positioned.fill(
            child: CustomPaint(
              painter: _LuluLandscapePainter(),
            ),
          ),

          // 2. النجوم اللامعة المتطايرة حول الشاشة
          if (!isTest) ...[
            Positioned(
              top: size.height * 0.11,
              left: 28,
              child: const _FourPointStar(size: 26, delayMs: 200),
            ),
            Positioned(
              top: size.height * 0.12,
              right: 32,
              child: const _FourPointStar(size: 30, delayMs: 400),
            ),
            Positioned(
              top: size.height * 0.28,
              left: 18,
              child: const _FourPointStar(size: 22, delayMs: 600),
            ),
            Positioned(
              top: size.height * 0.32,
              right: 22,
              child: const _FourPointStar(size: 24, delayMs: 800),
            ),
          ],

          // 3. المحتوى الرئيسي المقسم رأسياً
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // الشريط العلوي (زر الرجوع / الإغلاق المنسدل)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر السهم العلوي اللطيف الشفاف
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.60),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // شعار "عالم لولو - Lulu Kids" مع التاج الملكي الذهبي 👑
                _buildLuluLogo(),

                const Spacer(),

                // شخصية الأرنب "لولو" الحقيقية بدقة فائقة مع النجمة المضيئة
                _buildLuluHero(heroHeight),

                // بطاقة السحاب السفلية المريحة
                _buildCloudBottomCard(context, isCompact),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// شعار "عالم لولو" ثلاثي الأبعاد مع التاج الذهبي و "Lulu Kids"
  Widget _buildLuluLogo() {
    Widget logoWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // النص ثلاثي الأبعاد "عالم لولو"
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // كلمة "عالم" باللون الأبيض والحد البنفسجي
                _build3DText(
                  text: 'عالم',
                  fillColor: Colors.white,
                  strokeColor: const Color(0xFF2C1466),
                  shadowColor: const Color(0xFF1B0B44),
                  fontSize: 42,
                ),
                const SizedBox(width: 8),
                // كلمة "لولو" باللون الأصفر الذهبي المشمس
                _build3DText(
                  text: 'لولو',
                  fillColor: const Color(0xFFFFD200),
                  strokeColor: const Color(0xFF2C1466),
                  shadowColor: const Color(0xFF1B0B44),
                  fontSize: 44,
                ),
              ],
            ),

            // التاج الملكي الذهبي الصغير فوق حرف اللام
            Positioned(
              top: -16,
              right: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66FFD700),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  '👑',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        // العنوان الإنجليزي بالخط المنحني المرح "Lulu Kids"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Stack(
            children: [
              // حدود داكنة للنص الإنجليزي
              Text(
                'Lulu Kids',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = const Color(0xFF231053),
                ),
              ),
              // التعبئة الداخلية باللون السماوي الفاتح المتوهج
              const Text(
                'Lulu Kids',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFF8CE8FE),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isTest) return logoWidget;

    return logoWidget
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }

  /// ويدجت مساعدة لبناء الخطوط ثلاثية الأبعاد بحدود وظلال بارزة مطابقة للتصميم الكرتوني
  Widget _build3DText({
    required String text,
    required Color fillColor,
    required Color strokeColor,
    required Color shadowColor,
    required double fontSize,
  }) {
    return Stack(
      children: [
        // الظل السفلي ثلاثي الأبعاد
        Transform.translate(
          offset: const Offset(0, 5),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 8
                ..color = shadowColor,
            ),
          ),
        ),
        // الحد الخارجي الملكي الداكن
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..color = strokeColor,
          ),
        ),
        // المتن الداخلي الملون
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: fillColor,
          ),
        ),
      ],
    );
  }

  /// شخصية لولو مع تأثير الحركة العائمة الخفيفة ولمعان النجمة
  Widget _buildLuluHero(double heroHeight) {
    Widget hero = SizedBox(
      height: heroHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // توهج خفيف دافئ خلف لولو ونجمته
          Container(
            width: heroHeight * 0.75,
            height: heroHeight * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFF3B0).withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),

          // صورة لولو المفرغة عالية الدقة
          Image.asset(
            'assets/images/lulu_hero.png',
            height: heroHeight,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // احتياطي في بيئات الاختبار إذا لم يتم تحميل الملف
              return const Center(
                child: Text('🐰', style: TextStyle(fontSize: 100)),
              );
            },
          ),
        ],
      ),
    );

    if (isTest) return hero;

    // حركة طفو وتذبذب ممتعة ولطيفة للأطفال
    return hero
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: -8, duration: 2200.ms, curve: Curves.easeInOut);
  }

  /// بطاقة السحاب السفلية المريحة مع زر "ابدأ الآن" ونقاط التنقل
  Widget _buildCloudBottomCard(BuildContext context, bool isCompact) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38),
          topRight: Radius.circular(38),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F2C1466),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 28,
        vertical: isCompact ? 18 : 26,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // النصوص الترحيبية المركزية
          const Text(
            'مرحباً بكم في',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'عالم لولو التعليمي',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),

          SizedBox(height: isCompact ? 16 : 22),

          // زر "ابدأ الآن >" ثلاثي الأبعاد اللامع
          _buildStartButton(context),

          SizedBox(height: isCompact ? 14 : 20),

          // مؤشر النقاط الثلاث (Pagination Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // النقطة الأولى النشطة (بنفسجي لولو)
              Container(
                width: 22,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 6),
              // النقطة الثانية غير نشطة
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 6),
              // النقطة الثالثة غير نشطة
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// زر الانطلاق "ابدأ الآن" بالتدرج اللوني الذهبي/البرتقالي اللامع
  Widget _buildStartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFD200), // أصفر مشمس لامع في الأعلى
            Color(0xFFFF9F00), // برتقالي دافئ في المنتصف
            Color(0xFFFF7E00), // برتقالي ذهبي عميق في الأسفل
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FF8A00),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x33D35400),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFF3A8),
          width: 1.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ابدأ الآن',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5A2500),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF8C3800),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ويدجت النجمة الكرتونية ذات الأربع نقاط مع تأثير اللمعان
class _FourPointStar extends StatelessWidget {
  final double size;
  final int delayMs;

  const _FourPointStar({
    required this.size,
    required this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x88FFE600),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _StarPainter(),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.15, 1.15),
          delay: Duration(milliseconds: delayMs),
          duration: 1600.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// رسم هندسي للنجمة الكرتونية الذهبية
class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF9A6), Color(0xFFFFD200), Color(0xFFFF9F00)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rOut = size.width / 2;
    final rIn = size.width * 0.22;

    for (int i = 0; i < 4; i++) {
      final angleOut = (i * 90 - 90) * math.pi / 180;
      final angleIn = (i * 90 - 45) * math.pi / 180;

      if (i == 0) {
        path.moveTo(cx + rOut * math.cos(angleOut), cy + rOut * math.sin(angleOut));
      } else {
        path.lineTo(cx + rOut * math.cos(angleOut), cy + rOut * math.sin(angleOut));
      }
      path.lineTo(cx + rIn * math.cos(angleIn), cy + rIn * math.sin(angleIn));
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// رسام المنظر الطبيعي (الخلفية الساحرة، السماء، قوس قزح، التلال والأشجار والزهور)
class _LuluLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. تدرج السماء الساحرة
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4C96F8), // أزرق سماوي صافي ومشرق في الأعلى
          Color(0xFF7CB8FE), // أزرق ألطف في المنتصف
          Color(0xFFC7E2FE), // أزرق فاتح دافئ
          Color(0xFFEAF4FF), // أبيض مزرق فوق السحاب
        ],
        stops: [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. توهج أشعة الشمس في الزاوية العلوية اليمنى
    final sunCenter = Offset(size.width * 0.88, size.height * 0.12);
    final sunGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF9DE).withValues(alpha: 0.65),
          const Color(0xFFFFF9DE).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: size.width * 0.40));

    canvas.drawCircle(sunCenter, size.width * 0.40, sunGlow);

    // 3. قوس قزح الكرتوني المنحني على اليمين 🌈
    final rainbowColors = [
      const Color(0xFFFF6B6B).withValues(alpha: 0.85), // أحمر / وردي
      const Color(0xFFFFA94D).withValues(alpha: 0.85), // برتقالي
      const Color(0xFFFFE066).withValues(alpha: 0.85), // أصفر
      const Color(0xFF69DB7C).withValues(alpha: 0.85), // أخضر
      const Color(0xFF38D9A9).withValues(alpha: 0.85), // تركواز
      const Color(0xFF9775FA).withValues(alpha: 0.85), // بنفسجي
    ];

    final rainbowCenter = Offset(size.width * 0.62, size.height * 0.42);
    double radius = size.width * 0.48;

    for (final color in rainbowColors) {
      final rainbowPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: rainbowCenter, radius: radius),
        -math.pi * 0.65,
        math.pi * 0.55,
        false,
        rainbowPaint,
      );
      radius -= 5.0;
    }

    // 4. غيوم ناعمة عائمة في السماء
    _drawCloud(canvas, Offset(size.width * 0.18, size.height * 0.22), 34);
    _drawCloud(canvas, Offset(size.width * 0.86, size.height * 0.26), 28);

    // 5. التلال الخضراء المتدحرجة في المنتصف
    final hillPaint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8AE14E), Color(0xFF5AB634)],
      ).createShader(Rect.fromLTWH(0, size.height * 0.48, size.width, size.height * 0.3));

    final hillPath1 = Path()
      ..moveTo(-20, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.52,
        size.width * 0.55,
        size.height * 0.60,
      )
      ..lineTo(size.width * 0.55, size.height)
      ..lineTo(-20, size.height)
      ..close();

    canvas.drawPath(hillPath1, hillPaint1);

    final hillPaint2 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF72D038), Color(0xFF49A525)],
      ).createShader(Rect.fromLTWH(0, size.height * 0.48, size.width, size.height * 0.3));

    final hillPath2 = Path()
      ..moveTo(size.width * 0.45, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.50,
        size.width + 30,
        size.height * 0.58,
      )
      ..lineTo(size.width + 30, size.height)
      ..lineTo(size.width * 0.45, size.height)
      ..close();

    canvas.drawPath(hillPath2, hillPaint2);

    // 6. أشجار كرتونية لطيفة على الجوانب
    _drawCartoonTree(canvas, Offset(24, size.height * 0.54), 38);
    _drawCartoonTree(canvas, Offset(size.width - 24, size.height * 0.52), 42);

    // 7. زهور كرتونية ملونة تزين الأطراف
    _drawFlower(canvas, Offset(20, size.height * 0.68), const Color(0xFFFF7675));
    _drawFlower(canvas, Offset(42, size.height * 0.70), const Color(0xFFFFD200));
    _drawFlower(canvas, Offset(size.width - 22, size.height * 0.69), const Color(0xFFFF7675));
    _drawFlower(canvas, Offset(size.width - 44, size.height * 0.71), const Color(0xFFFFA94D));
  }

  /// رسم غيمة كرتونية بيضاء ناعمة
  void _drawCloud(Canvas canvas, Offset center, double baseRadius) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    canvas.drawCircle(center, baseRadius, cloudPaint);
    canvas.drawCircle(Offset(center.dx - baseRadius * 0.7, center.dy + baseRadius * 0.2), baseRadius * 0.65, cloudPaint);
    canvas.drawCircle(Offset(center.dx + baseRadius * 0.7, center.dy + baseRadius * 0.2), baseRadius * 0.65, cloudPaint);
  }

  /// رسم شجرة كرتونية لطيفة
  void _drawCartoonTree(Canvas canvas, Offset base, double radius) {
    // جذع الشجرة
    final trunkPaint = Paint()..color = const Color(0xFF8B5A2B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 5, base.dy, 10, radius * 0.8),
        const Radius.circular(4),
      ),
      trunkPaint,
    );

    // أوراق الشجرة الكروية
    final foliagePaint = Paint()..color = const Color(0xFF51CF66);
    canvas.drawCircle(Offset(base.dx, base.dy - radius * 0.3), radius * 0.8, foliagePaint);
    canvas.drawCircle(Offset(base.dx - radius * 0.4, base.dy - radius * 0.2), radius * 0.55, Paint()..color = const Color(0xFF40C057));
    canvas.drawCircle(Offset(base.dx + radius * 0.4, base.dy - radius * 0.2), radius * 0.55, Paint()..color = const Color(0xFF69DB7C));
  }

  /// رسم زهرة كرتونية صغيرة
  void _drawFlower(Canvas canvas, Offset center, Color petalColor) {
    final petalPaint = Paint()..color = petalColor;
    final centerPaint = Paint()..color = const Color(0xFFFFD200);

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * math.pi / 180;
      final px = center.dx + 5.5 * math.cos(angle);
      final py = center.dy + 5.5 * math.sin(angle);
      canvas.drawCircle(Offset(px, py), 3.5, petalPaint);
    }
    canvas.drawCircle(center, 3.0, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

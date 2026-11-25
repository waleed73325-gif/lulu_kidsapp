import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/progress/progress_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const LuluKidsApp(),
    ),
  );
}

class LuluKidsApp extends StatelessWidget {
  final bool isTest;

  const LuluKidsApp({super.key, this.isTest = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lulu Kids - لولو للأطفال',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // تجربة عربية أصلية بالكامل من اليمين إلى اليسار (RTL)
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: SplashScreen(isTest: isTest),
    );
  }
}

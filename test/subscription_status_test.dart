import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lulu_kids/core/theme/app_theme.dart';
import 'package:lulu_kids/features/auth/auth_provider.dart';
import 'package:lulu_kids/features/parent_portal/parent_portal_screen.dart';
import 'package:lulu_kids/features/parent_portal/subscription_screen.dart';
import 'package:lulu_kids/features/progress/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        home: screen,
      ),
    );
  }

  testWidgets('SubscriptionScreen renders correctly and shows plan cards when unsubscribed',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const SubscriptionScreen()));
    await tester.pumpAndSettle();

    expect(find.text('اشتراك لولو بلس (Lulu+)'), findsOneWidget);
    expect(find.text('باقة 3 أشهر'), findsOneWidget);
    expect(find.text('باقة السنة الكاملة (12 شهراً)'), findsOneWidget);
  });

  testWidgets('ParentPortalScreen renders correctly with live refresh indicator and actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const ParentPortalScreen()));
    await tester.pumpAndSettle();

    expect(find.text('منطقة ولي الأمر'), findsOneWidget);
    expect(find.text('الاشتراك والباقات (Lulu+)'), findsOneWidget);
  });

  testWidgets('SubscriptionScreen shows confirmation dialog with warning on cancel tap and preserves subscription if dismissed',
      (WidgetTester tester) async {
    final progress = ProgressProvider();
    await progress.setSubscribed(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progress),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('ar'),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          home: const SubscriptionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إلغاء الاشتراك في باقة لولو'), findsOneWidget);

    // النقر على زر إلغاء الاشتراك
    await tester.tap(find.text('إلغاء الاشتراك في باقة لولو'));
    await tester.pumpAndSettle();

    // التحقق من ظهور حوار التأكيد والرسالة التحذيرية
    expect(find.text('تأكيد إلغاء الاشتراك'), findsOneWidget);
    expect(find.textContaining('لا يمكن التراجع عند إلغاء الاشتراك'), findsOneWidget);
    expect(find.text('التراجع والاحتفاظ بالاشتراك'), findsOneWidget);
    expect(find.text('نعم، تأكيد الإلغاء'), findsOneWidget);

    // النقر على التراجع
    await tester.tap(find.text('التراجع والاحتفاظ بالاشتراك'));
    await tester.pumpAndSettle();

    // يجب أن يظل الاشتراك مفعل
    expect(progress.isSubscribed, isTrue);
    expect(find.text('اشتراكك مفعل حالياً (باقة لولو المميزة) 🎉'), findsOneWidget);
  });

  testWidgets('SubscriptionScreen cancels subscription when confirming cancellation in dialog',
      (WidgetTester tester) async {
    final progress = ProgressProvider();
    await progress.setSubscribed(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progress),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('ar'),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          home: const SubscriptionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // النقر على زر إلغاء الاشتراك
    await tester.tap(find.text('إلغاء الاشتراك في باقة لولو'));
    await tester.pumpAndSettle();

    // النقر على تأكيد الإلغاء
    await tester.tap(find.text('نعم، تأكيد الإلغاء'));
    await tester.pumpAndSettle();

    // يجب أن يصبح الاشتراك غير مفعل وتظهر باقات الاشتراك مجدداً
    expect(progress.isSubscribed, isFalse);
    expect(find.text('باقة السنة الكاملة (12 شهراً)'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lulu_kids/core/theme/app_theme.dart';
import 'package:lulu_kids/features/auth/auth_provider.dart';
import 'package:lulu_kids/features/parent_portal/manual_payment_screen.dart';
import 'package:lulu_kids/features/parent_portal/subscription_screen.dart';
import 'package:lulu_kids/features/progress/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(Widget child, {Size size = const Size(270, 700)}) {
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
          child: MediaQuery(
            data: MediaQueryData(size: size),
            child: child!,
          ),
        ),
        home: child,
      ),
    );
  }

  testWidgets('SubscriptionScreen does not overflow on narrow screens (267px)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(267, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(const SubscriptionScreen(), size: const Size(267, 800)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('اشتراك لولو بلس (Lulu+)'), findsOneWidget);
  });

  testWidgets('ManualPaymentScreen does not overflow on narrow screens (270px)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(270, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      createTestWidget(
        const ManualPaymentScreen(
          planName: 'باقة السنة الكاملة (12 شهراً)',
          price: '89 ر.س',
        ),
        size: const Size(270, 800),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('إتمام التحويل اليدوي'), findsOneWidget);
  });
}

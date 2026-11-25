import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lulu_kids/core/theme/app_theme.dart';
import 'package:lulu_kids/features/auth/auth_provider.dart';
import 'package:lulu_kids/features/parent_portal/notifications_screen.dart';
import 'package:lulu_kids/features/parent_portal/models/parent_notification_model.dart';
import 'package:lulu_kids/features/parent_portal/parent_portal_screen.dart';
import 'package:lulu_kids/features/progress/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp(Widget screen, {Size size = const Size(270, 700)}) {
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
        home: screen,
      ),
    );
  }

  testWidgets('NotificationsScreen renders correctly on narrow screen without overflows',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(270, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(const NotificationsScreen(), size: const Size(270, 800)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('الإشعارات والتنبيهات 🔔'), findsOneWidget);
    expect(find.text('التعميمات والعروض 📢'), findsOneWidget);
    expect(find.text('الاشتراكات 💳'), findsOneWidget);
  });

  test('ParentNotificationModel correctly handles broadcast types and colors', () {
    final offer = ParentNotificationModel.fromJson({
      'id': 1,
      'title': 'عرض خاص',
      'body': 'خصم 50%',
      'type': 'offer',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(offer.typeLabel, 'عرض خاص 🎁');
    expect(offer.icon, Icons.local_offer_rounded);

    final announcement = ParentNotificationModel.fromJson({
      'id': 2,
      'title': 'تحديث هام',
      'body': 'تمت إضافة دروس جديدة',
      'type': 'announcement',
      'is_read': true,
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(announcement.typeLabel, 'تعميم عام 📢');
    expect(announcement.icon, Icons.campaign_rounded);
  });

  testWidgets('ParentPortalScreen shows notification icon and action tile',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(const ParentPortalScreen(), size: const Size(360, 800)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.text('الإشعارات والتنبيهات 🔔'), findsOneWidget);
  });
}

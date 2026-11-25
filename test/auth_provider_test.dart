import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lulu_kids/features/auth/auth_provider.dart';
import 'package:lulu_kids/features/auth/models/user_model.dart';
import 'package:lulu_kids/features/progress/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ParentUser and ChildModel serialization', () {
    test('ParentUser.fromJson parses properly', () {
      final json = {
        'id': 1,
        'name': 'أحمد علي',
        'email': 'ahmed@test.com',
        'phone': '0512345678',
        'role': 'parent',
        'children': [
          {
            'id': 10,
            'nickname': 'بطل لولو',
            'birth_year': 2021,
            'avatar_id': 'rabbit_lulu',
          }
        ],
      };

      final user = ParentUser.fromJson(json, hasSubscription: true);
      expect(user.id, 1);
      expect(user.name, 'أحمد علي');
      expect(user.email, 'ahmed@test.com');
      expect(user.hasActiveSubscription, true);
      expect(user.children.length, 1);
      expect(user.children.first.nickname, 'بطل لولو');
    });
  });

  group('AuthProvider State Tests', () {
    test('initializes as unauthenticated when no token is stored', () async {
      final auth = AuthProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(auth.isAuthenticated, false);
      expect(auth.currentUser, null);
    });

    test('logout clears user state and resets progress subscription', () async {
      final auth = AuthProvider();
      final progress = ProgressProvider();
      await progress.setSubscribed(true);

      await auth.logout(progress);

      expect(auth.isAuthenticated, false);
      expect(auth.currentUser, null);
      expect(progress.isSubscribed, false);
    });

    test('updateChildNickname updates local user and progress provider immediately', () async {
      final auth = AuthProvider();
      final progress = ProgressProvider();

      // تجهيز مستخدم محلي مع طفل عبر SharedPreferences
      SharedPreferences.setMockInitialValues({
        'lulu_parent_user_json': '{"id":1,"name":"ولي الأمر","email":"parent@test.com","role":"parent","has_active_subscription":false,"children":[{"id":10,"nickname":"اللقب القديم","birth_year":2021,"avatar_id":"rabbit_lulu"}]}'
      });

      await auth.checkAuth(progress);
      expect(auth.currentUser?.children.first.nickname, 'اللقب القديم');

      // تعديل اللقب
      final result = await auth.updateChildNickname('اللقب الجديد المحدث', progress);
      expect(result, true);
      expect(auth.currentUser?.children.first.nickname, 'اللقب الجديد المحدث');
      expect(progress.childNickname, 'اللقب الجديد المحدث');
    });

    test('restoring session with server stars and lessons populates ProgressProvider', () async {
      final auth = AuthProvider();
      final progress = ProgressProvider();

      // محاكاة بيانات مستخدم قادمة من السيرفر وفيها 90 نجمة ودروس متقنة
      SharedPreferences.setMockInitialValues({
        'lulu_parent_user_json': '{"id":5,"name":"أحمد","email":"ahmed@test.com","role":"parent","has_active_subscription":true,"children":[{"id":20,"nickname":"ماجد","birth_year":2020,"avatar_id":"rabbit_lulu","stars_count":90,"completed_lessons":["let_1","let_2","num_1","num_2"]}]}'
      });

      await auth.checkAuth(progress);

      expect(auth.currentUser?.children.first.starsCount, 90);
      expect(auth.currentUser?.children.first.completedLessons.contains('num_2'), true);
      expect(progress.starsCount, 90);
      expect(progress.completedLessonIds.contains('let_2'), true);
      expect(progress.completedLessonIds.contains('num_2'), true);
      expect(progress.childNickname, 'ماجد');
    });

    test('selectActiveChild switches active child scope in ProgressProvider', () async {
      final auth = AuthProvider();
      final progress = ProgressProvider();

      SharedPreferences.setMockInitialValues({
        'lulu_parent_user_json': '{"id":7,"name":"أميرة","email":"amira@test.com","role":"parent","has_active_subscription":false,"children":[{"id":31,"nickname":"سيف","birth_year":2020,"avatar_id":"bear_bobi","stars_count":40,"completed_lessons":["let_1"]},{"id":32,"nickname":"ريما","birth_year":2022,"avatar_id":"cat_mishmish","stars_count":18,"completed_lessons":["num_1"]}]}'
      });

      await auth.checkAuth(progress);
      expect(progress.childNickname, 'سيف');
      expect(progress.starsCount, 40);

      // التبديل للطفل الثاني (ريما)
      final secondChild = auth.currentUser!.children[1];
      await auth.selectActiveChild(secondChild, progress);

      expect(progress.childNickname, 'ريما');
      expect(progress.starsCount, 18);
      expect(progress.activeChildId, 32);
    });
  });
}

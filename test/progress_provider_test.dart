import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lulu_kids/features/lessons/models/lesson_model.dart';
import 'package:lulu_kids/features/progress/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'stars_count': 15,
      'is_subscribed': false,
      'child_nickname': 'أحمد البطل',
      'completed_lessons': ['let_1'],
    });
  });

  group('Lesson and Category Model Tests', () {
    test('LessonCategory.fromJson parses properly', () {
      final json = {
        'id': 1,
        'slug': 'cat_letters',
        'name_ar': 'جزيرة الحروف',
        'subtitle_ar': 'تعلم الحروف العربية',
        'icon': 'sort_by_alpha_rounded',
      };
      final cat = LessonCategory.fromJson(json);
      expect(cat.id, 'cat_letters');
      expect(cat.title, 'جزيرة الحروف');
      expect(cat.type, CategoryType.letters);
    });

    test('Lesson.fromJson parses free and premium lessons', () {
      final jsonFree = {
        'id': 101,
        'category_slug': 'cat_letters',
        'title': 'حرف الجيم',
        'subtitle': 'ج - جمل',
        'content_arabic': 'ج',
        'example_word': 'جمل 🐫',
        'access_level': 'free',
        'stars_reward': 5,
        'primary_color': '#00B894',
      };
      final lesson = Lesson.fromJson(jsonFree);
      expect(lesson.id, '101');
      expect(lesson.title, 'حرف الجيم');
      expect(lesson.accessLevel, AccessLevel.free);
      expect(lesson.starsReward, 5);

      final jsonPremium = {
        'id': 102,
        'category_slug': 'cat_letters',
        'title': 'حرف الحاء',
        'access_level': 'premium',
      };
      final premLesson = Lesson.fromJson(jsonPremium);
      expect(premLesson.accessLevel, AccessLevel.premium);
    });
  });

  group('ProgressProvider Unit Tests', () {
    test('initializes state from mock SharedPreferences', () async {
      final provider = ProgressProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.starsCount, 15);
      expect(provider.childNickname, 'أحمد البطل');
      expect(provider.isSubscribed, false);
      expect(provider.completedLessonIds.contains('let_1'), true);
      expect(provider.categories.isNotEmpty, true);
    });

    test('completing a new lesson increments stars', () async {
      final provider = ProgressProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialStars = provider.starsCount;
      await provider.completeLesson('let_2', 3);

      expect(provider.completedLessonIds.contains('let_2'), true);
      expect(provider.starsCount, initialStars + 3);
    });

    test('setting subscription updates state', () async {
      final provider = ProgressProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.isSubscribed, false);
      await provider.setSubscribed(true);
      expect(provider.isSubscribed, true);
    });

    test('updating child nickname updates state', () async {
      final provider = ProgressProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.updateChildNickname('سارة الذكية');
      expect(provider.childNickname, 'سارة الذكية');
    });

    test('filters lessons for category correctly', () async {
      final provider = ProgressProvider();
      final letterLessons = provider.getLessonsForCategory('cat_letters');
      expect(letterLessons.isNotEmpty, true);
      expect(letterLessons.every((l) => l.categoryId.contains('letters')), true);
    });

    test('switchUserScope isolates progress and stars between different users', () async {
      final provider = ProgressProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // المستخدم الأول لديه 50 نجمة
      await provider.switchUserScope('user_1', defaultNickname: 'طفل المستخدم 1');
      await provider.completeLesson('test_lesson_1', 35);
      expect(provider.starsCount, 47);
      expect(provider.childNickname, 'طفل المستخدم 1');

      // تسجيل خروج وتبديل للمستخدم الثاني (حساب جديد)
      await provider.switchUserScope('user_2', defaultNickname: 'طفل المستخدم 2', initialStars: 12);
      expect(provider.starsCount, 12); // لا يرث نجوم المستخدم الأول!
      expect(provider.childNickname, 'طفل المستخدم 2');
      expect(provider.completedLessonIds.contains('test_lesson_1'), false);

      // العودة للمستخدم الأول يستعيد نجومه بدقة
      await provider.switchUserScope('user_1');
      expect(provider.starsCount, 47);
      expect(provider.childNickname, 'طفل المستخدم 1');
      expect(provider.completedLessonIds.contains('test_lesson_1'), true);
    });

    test('resetProgress resets stars and state to clean defaults', () async {
      final provider = ProgressProvider();
      await provider.completeLesson('some_lesson', 20);
      expect(provider.starsCount > 12, true);

      await provider.resetProgress(newNickname: 'بطل جديد', initialStars: 12);
      expect(provider.starsCount, 12);
      expect(provider.childNickname, 'بطل جديد');
      expect(provider.completedLessonIds, {'let_1', 'num_1'});
    });

    test('switchUserScope restores stars and completed lessons from server after fresh install', () async {
      // محاكاة تثبيت جديد للتطبيق: ذاكرة الهاتف خالية تماماً
      SharedPreferences.setMockInitialValues({});
      final provider = ProgressProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // تسجيل الدخول بحساب سابق كان قد جمع 75 نجمة وأنهى 4 دروس
      await provider.switchUserScope(
        'user_veteran',
        childId: 101,
        defaultNickname: 'سامي البطل',
        initialStars: 75,
        initialCompletedLessons: ['let_1', 'let_2', 'let_3', 'num_1'],
      );

      // يجب استعادة النجوم والدروس بالكامل دون بدء التطبيق من الصفر
      expect(provider.starsCount, 75);
      expect(provider.childNickname, 'سامي البطل');
      expect(provider.completedLessonIds.contains('let_3'), true);
      expect(provider.activeChildId, 101);
    });
  });
}

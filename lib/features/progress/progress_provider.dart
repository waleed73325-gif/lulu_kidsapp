import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/audio_player_service.dart';
import '../lessons/models/lesson_model.dart';
import '../games/models/educational_game_model.dart';

class ProgressProvider extends ChangeNotifier {
  int _starsCount = 12; // رصيد تشجيعي أولي
  final Set<String> _completedLessonIds = {'let_1', 'num_1'};
  bool _isSubscribed = false;
  String _childNickname = 'البطل الصغير';
  bool _isLoadingContent = false;
  String? _activeUserId;
  int? _activeChildId;

  late List<LessonCategory> _categories;
  late List<Lesson> _lessons;
  List<EducationalGame> _games = [];
  final Map<String, int> _gameSavedStageIndex = {};

  int get starsCount => _starsCount;
  Set<String> get completedLessonIds => _completedLessonIds;
  bool get isSubscribed => _isSubscribed;
  String get childNickname => _childNickname;
  bool get isLoadingContent => _isLoadingContent;
  String? get activeUserId => _activeUserId;
  int? get activeChildId => _activeChildId;
  List<LessonCategory> get categories => _categories;
  List<Lesson> get allLessons => _lessons;
  List<EducationalGame> get games => _games.isNotEmpty ? _games : _defaultGames;

  int getSavedStageForGame(String gameId) {
    return _gameSavedStageIndex[gameId] ?? 0;
  }

  String get _scopePrefix {
    if (_activeUserId != null && _activeUserId!.isNotEmpty) {
      if (_activeChildId != null) {
        return 'user_${_activeUserId}_child_${_activeChildId}_';
      }
      return 'user_${_activeUserId}_';
    }
    return 'guest_';
  }

  ProgressProvider() {
    _categories = List.from(_defaultCategories);
    _lessons = List.from(_defaultLessons);
    _games = List.from(_defaultGames);
    _loadState();
  }

  /// تبديل وعزل نطاق التقدم لكل مستخدم (أو الزائر عند تسجيل الخروج) ومزامنة النجوم مع السيرفر
  Future<void> switchUserScope(
    String? userId, {
    int? childId,
    String? defaultNickname,
    int? initialStars,
    List<String>? initialCompletedLessons,
  }) async {
    _activeUserId = userId;
    _activeChildId = childId;
    final prefix = _scopePrefix;
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('${prefix}stars_count')) {
      final localStars = prefs.getInt('${prefix}stars_count') ?? 12;
      final serverStars = initialStars ?? 12;
      // نأخذ القيمة الأكبر لضمان عدم ضياع نجوم جمعها الطفل سواء من السيرفر أو محلياً
      _starsCount = (serverStars > localStars) ? serverStars : localStars;

      _childNickname = prefs.getString('${prefix}child_nickname') ?? (defaultNickname ?? 'البطل الصغير');
      if (defaultNickname != null && defaultNickname.isNotEmpty && defaultNickname != 'البطل الصغير') {
        _childNickname = defaultNickname;
      }

      final completed = prefs.getStringList('${prefix}completed_lessons') ?? ['let_1', 'num_1'];
      _completedLessonIds.clear();
      _completedLessonIds.addAll(completed);
      if (initialCompletedLessons != null && initialCompletedLessons.isNotEmpty) {
        _completedLessonIds.addAll(initialCompletedLessons);
      }
    } else {
      _starsCount = initialStars ?? 12;
      _childNickname = defaultNickname ?? 'البطل الصغير';
      _completedLessonIds.clear();
      _completedLessonIds.addAll(initialCompletedLessons ?? ['let_1', 'num_1']);

      await prefs.setInt('${prefix}stars_count', _starsCount);
      await prefs.setString('${prefix}child_nickname', _childNickname);
      await prefs.setStringList('${prefix}completed_lessons', _completedLessonIds.toList());
    }

    // مزامنة المفاتيح العامة الفعالة
    await prefs.setInt('stars_count', _starsCount);
    await prefs.setString('child_nickname', _childNickname);
    await prefs.setStringList('completed_lessons', _completedLessonIds.toList());

    notifyListeners();
  }

  /// إعادة تعيين وتصفير التقدم بالكامل للحالة النظيفة (عند تسجيل الخروج أو حذف البيانات)
  Future<void> resetProgress({String? newNickname, int initialStars = 12}) async {
    _starsCount = initialStars;
    _completedLessonIds.clear();
    _completedLessonIds.addAll(['let_1', 'num_1']);
    _childNickname = newNickname ?? 'البطل الصغير';
    _isSubscribed = false;
    _gameSavedStageIndex.clear();
    _activeChildId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stars_count', _starsCount);
    await prefs.setString('child_nickname', _childNickname);
    await prefs.setStringList('completed_lessons', _completedLessonIds.toList());
    await prefs.setBool('is_subscribed', false);
    await prefs.remove('game_saved_stages_json');

    final prefix = _scopePrefix;
    await prefs.setInt('${prefix}stars_count', _starsCount);
    await prefs.setString('${prefix}child_nickname', _childNickname);
    await prefs.setStringList('${prefix}completed_lessons', _completedLessonIds.toList());
    await prefs.setBool('${prefix}is_subscribed', false);

    notifyListeners();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_activeUserId != null) {
        return;
      }
      _starsCount = prefs.getInt('stars_count') ?? 12;
      _isSubscribed = prefs.getBool('is_subscribed') ?? false;
      _childNickname = prefs.getString('child_nickname') ?? 'البطل الصغير';
      final completed = prefs.getStringList('completed_lessons') ?? ['let_1', 'num_1'];
      _completedLessonIds.clear();
      _completedLessonIds.addAll(completed);

      // تحميل النسخ المخبأة محلياً إن وجدت
      final cachedCats = prefs.getString('cached_categories_json');
      if (cachedCats != null) {
        final List decoded = jsonDecode(cachedCats);
        if (decoded.isNotEmpty) {
          _categories = decoded.map((c) => LessonCategory.fromJson(c as Map<String, dynamic>)).toList();
        }
      }

      final cachedLessons = prefs.getString('cached_lessons_json');
      if (cachedLessons != null) {
        final List decoded = jsonDecode(cachedLessons);
        if (decoded.isNotEmpty) {
          _lessons = decoded.map((l) => Lesson.fromJson(l as Map<String, dynamic>)).toList();
        }
      }

      final cachedGames = prefs.getString('cached_games_json');
      if (cachedGames != null) {
        final List decoded = jsonDecode(cachedGames);
        if (decoded.isNotEmpty) {
          _games = decoded.map((g) => EducationalGame.fromJson(g as Map<String, dynamic>)).toList();
        }
      }

      final savedProgressJson = prefs.getString('game_saved_stages_json');
      if (savedProgressJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedProgressJson);
        _gameSavedStageIndex.clear();
        decoded.forEach((key, val) {
          if (val is int) {
            _gameSavedStageIndex[key] = val;
          } else if (val is num) {
            _gameSavedStageIndex[key] = val.toInt();
          }
        });
      }

      notifyListeners();

      // مزامنة أحدث الدروس والتصنيفات والألعاب من لوحة تحكم الخادم تلقائياً
      fetchRemoteContent();
    } catch (_) {}
  }

  /// جلب التصنيفات والدروس المحدثة من خادم لولو (Laravel Backend)
  Future<void> fetchRemoteContent([ApiService? apiService]) async {
    final service = apiService ?? ApiService();
    try {
      _isLoadingContent = true;
      notifyListeners();

      final catResponse = await service.getCategories();
      if (catResponse.statusCode == 200 && catResponse.data != null) {
        final rawList = catResponse.data['data'];
        if (rawList is List && rawList.isNotEmpty) {
          _categories = rawList.map((c) => LessonCategory.fromJson(c as Map<String, dynamic>)).toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_categories_json', jsonEncode(rawList));
        }
      }

      final lessonResponse = await service.getLessons();
      if (lessonResponse.statusCode == 200 && lessonResponse.data != null) {
        final rawList = lessonResponse.data['data'];
        if (rawList is List && rawList.isNotEmpty) {
          _lessons = rawList.map((l) => Lesson.fromJson(l as Map<String, dynamic>)).toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_lessons_json', jsonEncode(rawList));
        }
      }

      final gamesResponse = await service.getEducationalGames();
      if (gamesResponse.statusCode == 200 && gamesResponse.data != null) {
        final rawList = gamesResponse.data['data'];
        if (rawList is List && rawList.isNotEmpty) {
          _games = rawList.map((g) => EducationalGame.fromJson(g as Map<String, dynamic>)).toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_games_json', jsonEncode(rawList));
        }
      }

      await AudioPlayerService().loadMotivationalSounds(service);
    } catch (e) {
      debugPrint('Lulu sync info: Offline or local mode active. ($e)');
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  /// مزامنة الرصيد الحالي والدروس مع السيرفر تلقائياً لضمان حفظ تقدم الطفل عند حذف التطبيق أو إعادة التثبيت
  Future<void> syncWithServer({ApiService? apiService, int? childId}) async {
    try {
      final targetChildId = childId ?? _activeChildId;
      final service = apiService ?? ApiService();
      final response = await service.syncProgress(
        childId: targetChildId,
        starsCount: _starsCount,
        completedLessons: _completedLessonIds.toList(),
      );

      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        bool changed = false;

        if (data['stars_count'] is int) {
          final serverStars = data['stars_count'] as int;
          if (serverStars > _starsCount) {
            _starsCount = serverStars;
            changed = true;
          }
        }

        if (data['completed_lessons'] is List) {
          final serverLessons = (data['completed_lessons'] as List).map((e) => e.toString()).toList();
          final prevLen = _completedLessonIds.length;
          _completedLessonIds.addAll(serverLessons);
          if (_completedLessonIds.length != prevLen) {
            changed = true;
          }
        }

        if (changed) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('stars_count', _starsCount);
          await prefs.setStringList('completed_lessons', _completedLessonIds.toList());
          final prefix = _scopePrefix;
          await prefs.setInt('${prefix}stars_count', _starsCount);
          await prefs.setStringList('${prefix}completed_lessons', _completedLessonIds.toList());
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Lulu sync info: Offline or local mode active. ($e)');
    }
  }

  Future<void> completeLesson(String lessonId, int stars, {int? childId, ApiService? apiService}) async {
    if (!_completedLessonIds.contains(lessonId)) {
      _completedLessonIds.add(lessonId);
      _starsCount += stars;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('stars_count', _starsCount);
      await prefs.setStringList('completed_lessons', _completedLessonIds.toList());

      final prefix = _scopePrefix;
      await prefs.setInt('${prefix}stars_count', _starsCount);
      await prefs.setStringList('${prefix}completed_lessons', _completedLessonIds.toList());

      // مزامنة فورية في الخلفية مع الخادم لحفظ النجوم والدروس
      syncWithServer(apiService: apiService, childId: childId);
    }
  }

  Future<void> completeEducationalGame(EducationalGame game, {ApiService? apiService, int? childId}) async {
    _starsCount += game.starsReward;
    await resetGameStage(game.id);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stars_count', _starsCount);
    final prefix = _scopePrefix;
    await prefs.setInt('${prefix}stars_count', _starsCount);

    try {
      final service = apiService ?? ApiService();
      await service.completeGame(game.id);
    } catch (_) {}

    // مزامنة رصيد النجوم المكتسب من اللعبة مع الخادم
    syncWithServer(apiService: apiService, childId: childId);
  }

  Future<void> saveGameStage(String gameId, int stageIndex) async {
    _gameSavedStageIndex[gameId] = stageIndex;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_saved_stages_json', jsonEncode(_gameSavedStageIndex));
  }

  Future<void> resetGameStage(String gameId) async {
    _gameSavedStageIndex[gameId] = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_saved_stages_json', jsonEncode(_gameSavedStageIndex));
  }

  Future<void> setSubscribed(bool value) async {
    _isSubscribed = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_subscribed', value);
    final prefix = _scopePrefix;
    await prefs.setBool('${prefix}is_subscribed', value);
  }

  Future<void> updateChildNickname(String newName) async {
    _childNickname = newName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_nickname', newName);
    final prefix = _scopePrefix;
    await prefs.setString('${prefix}child_nickname', newName);
  }

  List<Lesson> getLessonsForCategory(String categoryId) {
    return _lessons.where((l) {
      return l.categoryId == categoryId ||
          l.categoryId == 'cat_$categoryId' ||
          categoryId == 'cat_${l.categoryId}';
    }).toList();
  }

  // --- البيانات الافتراضية المدمجة في التطبيق للعمل دون اتصال ---
  static const List<LessonCategory> _defaultCategories = [
    LessonCategory(
      id: 'cat_letters',
      title: 'جزيرة الحروف',
      subtitle: 'تعلم نطق وكتابة الحروف العربية مع لولو',
      type: CategoryType.letters,
      icon: Icons.sort_by_alpha_rounded,
      gradient: AppColors.lettersIslandGradient,
    ),
    LessonCategory(
      id: 'cat_numbers',
      title: 'جزيرة الأرقام والعد',
      subtitle: 'هيا نعد النجوم والألعاب سوياً',
      type: CategoryType.numbers,
      icon: Icons.pin_outlined,
      gradient: AppColors.numbersIslandGradient,
    ),
    LessonCategory(
      id: 'cat_colors',
      title: 'جزيرة الألوان والأشكال',
      subtitle: 'اكتشف عالم الألوان المبهج',
      type: CategoryType.colorsShapes,
      icon: Icons.palette_outlined,
      gradient: AppColors.colorsIslandGradient,
    ),
    LessonCategory(
      id: 'cat_stories',
      title: 'خيمة حكايات لولو',
      subtitle: 'قصص مرحة ومغامرات تعليمية جميلة',
      type: CategoryType.stories,
      icon: Icons.menu_book_rounded,
      gradient: AppColors.storiesIslandGradient,
    ),
    LessonCategory(
      id: 'cat_games',
      title: 'حديقة ألعاب لولو',
      subtitle: 'أنشطة مطابقة واختيار ذكية وممتعة',
      type: CategoryType.games,
      icon: Icons.videogame_asset_outlined,
      gradient: AppColors.gamesIslandGradient,
    ),
  ];

  static const List<Lesson> _defaultLessons = [
    // الحروف العربية
    Lesson(
      id: 'let_1',
      categoryId: 'cat_letters',
      title: 'حرف الألف (أ)',
      subtitle: 'أ - أرنب',
      contentArabic: 'أ',
      exampleWord: 'أرنب 🐰',
      displayIcon: Icons.pets_rounded,
      accessLevel: AccessLevel.free,
      primaryColor: Color(0xFFFF7675),
      narrationText: 'يا هلا والله بالبطل! أنا أرنوبك لولو.. وأول حرف باسمي هو حرف الألف.. أ، أ، أرنب يطامر بمرح! يلا يا شاطر قول معي: أَلِفْ!',
    ),
    Lesson(
      id: 'let_2',
      categoryId: 'cat_letters',
      title: 'حرف الباء (ب)',
      subtitle: 'ب - بطة',
      contentArabic: 'ب',
      exampleWord: 'بطة 🦆',
      displayIcon: Icons.flutter_dash_rounded,
      accessLevel: AccessLevel.free,
      primaryColor: Color(0xFF00CEC9),
      narrationText: 'كفو يا بطل! حرف الباء تحته نقطة وحدة حلوة.. ب، ب، بطة تسبح في الماي! شاطر والله!',
    ),
    Lesson(
      id: 'let_3',
      categoryId: 'cat_letters',
      title: 'حرف التاء (ت)',
      subtitle: 'ت - تفاحة',
      contentArabic: 'ت',
      exampleWord: 'تفاحة 🍎',
      displayIcon: Icons.eco_rounded,
      accessLevel: AccessLevel.free,
      primaryColor: Color(0xFFE17055),
      narrationText: 'يا هلا يا عسل! حرف التاء فوقه نقطتين حلوين زي العيون المبتسمة.. ت، ت، تفاحة لذيذة ومفيدة!',
    ),
    Lesson(
      id: 'let_4',
      categoryId: 'cat_letters',
      title: 'حرف الثاء (ث)',
      subtitle: 'ث - ثعلب',
      contentArabic: 'ث',
      exampleWord: 'ثعلب 🦊',
      displayIcon: Icons.cruelty_free_rounded,
      accessLevel: AccessLevel.premium,
      primaryColor: Color(0xFF6C5CE7),
      narrationText: 'شاطر يا بطل! طلّع طرف لسانك بشويش عند نطق الثاء.. ث، ث، ثعلب ذكي وسريع! كفو عليك!',
    ),

    // الأرقام والعد
    Lesson(
      id: 'num_1',
      categoryId: 'cat_numbers',
      title: 'الرقم واحد (١)',
      subtitle: '١ - قمر واحد',
      contentArabic: '١',
      exampleWord: 'قمر واحد في السماء 🌙',
      displayIcon: Icons.brightness_3_rounded,
      accessLevel: AccessLevel.free,
      primaryColor: Color(0xFF0984E3),
      narrationText: 'الرقم واحد واقف لحاله زي البطل! مثل قمر واحد ينور ليلنا بالسما.',
    ),
    Lesson(
      id: 'num_2',
      categoryId: 'cat_numbers',
      title: 'الرقم اثنان (٢)',
      subtitle: '٢ - عينان نرى بهما',
      contentArabic: '٢',
      exampleWord: 'عينان جميلتان 👀',
      displayIcon: Icons.visibility_rounded,
      accessLevel: AccessLevel.free,
      primaryColor: Color(0xFF00B894),
      narrationText: 'الرقم اثنان يبتسم للواحد بحب.. عينين اثنتين نشوف فيها كل شي حلو ومبهج!',
    ),
    Lesson(
      id: 'num_3',
      categoryId: 'cat_numbers',
      title: 'الرقم ثلاثة (٣)',
      subtitle: '٣ - ثلاث سمكات',
      contentArabic: '٣',
      exampleWord: 'ثلاث سمكات تسبح 🐟🐟🐟',
      displayIcon: Icons.water_rounded,
      accessLevel: AccessLevel.premium,
      primaryColor: Color(0xFFFDCB6E),
      narrationText: 'الرقم ثلاثة يبتسم لك بأسنانه الحلوة.. يلا نعد سوا يا بطل: واحد، اثنين، ثلاثة! ما شاء الله عليك!',
    ),

    // الألوان والأشكال
    Lesson(
      id: 'col_1',
      categoryId: 'cat_colors',
      title: 'اللون الأحمر',
      subtitle: 'أحمر كالورد والفراولة',
      contentArabic: 'أحمر',
      exampleWord: 'فراولة حمراء 🍓',
      displayIcon: Icons.favorite_rounded,
      accessLevel: AccessLevel.free,
      primaryColor: Color(0xFFD63031),
      narrationText: 'يا سلام على اللون الأحمر! زي الفراولة الشهية اللذيذة والورد الجميل.',
    ),
    Lesson(
      id: 'col_2',
      categoryId: 'cat_colors',
      title: 'الدائرة الصفراء',
      subtitle: 'شكل دائري كقرص الشمس',
      contentArabic: 'دائرة',
      exampleWord: 'شمس مشرقة ☀️',
      displayIcon: Icons.circle,
      accessLevel: AccessLevel.premium,
      primaryColor: Color(0xFFFDCB6E),
      narrationText: 'الدائرة تلف وتدور مافيها أي زوايا.. تماماً زي قرص الشمس الصافي والدفيان!',
    ),

    // قصص لولو
    Lesson(
      id: 'sto_1',
      categoryId: 'cat_stories',
      title: 'لولو والجزرة المفقودة',
      subtitle: 'قصة قصيرة عن الصدق ومساعدة الأصدقاء',
      contentArabic: 'قصة',
      exampleWord: 'لولو والأصدقاء',
      displayIcon: Icons.auto_stories_rounded,
      accessLevel: AccessLevel.free,
      primaryColor: Color(0xFF6C5CE7),
      narrationText: 'في يوم حلو ومشمس، طلع أرنوبنا لولو يدور على جزرته البرتقالية.. وتعلم وش كثر الصدق والتعاون حلوين مع الأصحاب!',
    ),
  ];

  static const List<EducationalGame> _defaultGames = [
    EducationalGame(
      id: '1',
      title: 'لعبة مطابقة الحروف والكلمات',
      slug: 'letter-matching-game',
      description: 'طابق الحرف والكلمة مع الصورة المناسبة واكسب النجوم البراقة!',
      gameType: GameType.letterMatching,
      icon: Icons.extension_rounded,
      primaryColor: Color(0xFF6C5CE7),
      isFree: true,
      starsReward: 5,
      questionsCount: 4,
      questions: [
        GameQuestion(
          id: '1',
          title: 'المرحلة 1: حرف الألف (أ)',
          prompt: 'أي بطاقة تبدأ بحرف الألف (أ)؟ 🐰',
          hint: 'حيوان أليف يحب الجزر ولديه أذنان طويلتان',
          questionOrder: 1,
          isActive: true,
          payload: {
            'target_letter': 'أ',
            'target_word': 'أرنب',
            'target_emoji': '🐰',
            'options': [
              {'id': '1', 'text': 'أ', 'subtext': 'أرنب', 'emoji': '🐰', 'is_correct': true},
              {'id': '2', 'text': 'ب', 'subtext': 'بطة', 'emoji': '🦆', 'is_correct': false},
              {'id': '3', 'text': 'ت', 'subtext': 'تمساح', 'emoji': '🐊', 'is_correct': false},
            ],
          },
        ),
        GameQuestion(
          id: '2',
          title: 'المرحلة 2: حرف الباء (ب)',
          prompt: 'طابق حرف الباء (ب) مع الصورة اللطيفة! 🦆',
          hint: 'طائر جميل يسبح في الماء ويقول واك واك',
          questionOrder: 2,
          isActive: true,
          payload: {
            'target_letter': 'ب',
            'target_word': 'بطة',
            'target_emoji': '🦆',
            'options': [
              {'id': '1', 'text': 'س', 'subtext': 'سيارة', 'emoji': '🚗', 'is_correct': false},
              {'id': '2', 'text': 'ب', 'subtext': 'بطة', 'emoji': '🦆', 'is_correct': true},
              {'id': '3', 'text': 'ج', 'subtext': 'جمل', 'emoji': '🐪', 'is_correct': false},
            ],
          },
        ),
        GameQuestion(
          id: '3',
          title: 'المرحلة 3: حرف التاء (ت)',
          prompt: 'اختر الحرف المطابق لفاكهة التفاح الشهية! 🍎',
          hint: 'فاكهة لذيذة ومفيدة تحب أكلها صباحاً',
          questionOrder: 3,
          isActive: true,
          payload: {
            'target_letter': 'ت',
            'target_word': 'تفاح',
            'target_emoji': '🍎',
            'options': [
              {'id': '1', 'text': 'د', 'subtext': 'دب', 'emoji': '🐻', 'is_correct': false},
              {'id': '2', 'text': 'ز', 'subtext': 'زرافة', 'emoji': '🦒', 'is_correct': false},
              {'id': '3', 'text': 'ت', 'subtext': 'تفاح', 'emoji': '🍎', 'is_correct': true},
            ],
          },
        ),
        GameQuestion(
          id: '4',
          title: 'المرحلة 4: حرف الجيم (ج)',
          prompt: 'أين بطاقة سفينة الصحراء الجمل بحرف الجيم؟ 🐪',
          hint: 'يتحمل العطش ويمشي في رمال الصحراء',
          questionOrder: 4,
          isActive: true,
          payload: {
            'target_letter': 'ج',
            'target_word': 'جمل',
            'target_emoji': '🐪',
            'options': [
              {'id': '1', 'text': 'ج', 'subtext': 'جمل', 'emoji': '🐪', 'is_correct': true},
              {'id': '2', 'text': 'ف', 'subtext': 'فيل', 'emoji': '🐘', 'is_correct': false},
              {'id': '3', 'text': 'ش', 'subtext': 'شجرة', 'emoji': '🌳', 'is_correct': false},
            ],
          },
        ),
      ],
    ),
    EducationalGame(
      id: '2',
      title: 'لعبة ترتيب حروف الكلمات',
      slug: 'letter-ordering-game',
      description: 'رتّب الحروف المبعثرة بالترتيب الصحيح لتكوين الكلمة المفيدة!',
      gameType: GameType.letterOrdering,
      icon: Icons.sort_by_alpha_rounded,
      primaryColor: Color(0xFF00B894),
      isFree: true,
      starsReward: 5,
      questionsCount: 4,
      questions: [
        GameQuestion(
          id: '1',
          title: 'المرحلة 1: كلمة أرنب',
          prompt: 'رتّب حروف كلمة (أَرْنَب) يا بطل 🐰',
          hint: 'ابدأ بحرف الألف ثم الراء ثم النون ثم الباء',
          questionOrder: 1,
          isActive: true,
          payload: {
            'target_word': 'أرنب',
            'hint_emoji': '🐰',
            'scrambled_letters': ['ن', 'أ', 'ب', 'ر'],
            'correct_order': ['أ', 'ر', 'ن', 'ب'],
          },
        ),
        GameQuestion(
          id: '2',
          title: 'المرحلة 2: كلمة قَلَم',
          prompt: 'رتّب حروف كلمة (قَلَم) التي نكتب ونرسم بها ✏️',
          hint: 'قاف ثم لام ثم ميم',
          questionOrder: 2,
          isActive: true,
          payload: {
            'target_word': 'قلم',
            'hint_emoji': '✏️',
            'scrambled_letters': ['م', 'ق', 'ل'],
            'correct_order': ['ق', 'ل', 'م'],
          },
        ),
        GameQuestion(
          id: '3',
          title: 'المرحلة 3: كلمة شَمْس',
          prompt: 'رتّب حروف كلمة (شَمْس) المشرقة والدافئة ☀️',
          hint: 'شين ثم ميم ثم سين',
          questionOrder: 3,
          isActive: true,
          payload: {
            'target_word': 'شمس',
            'hint_emoji': '☀️',
            'scrambled_letters': ['س', 'ش', 'م'],
            'correct_order': ['ش', 'م', 'س'],
          },
        ),
        GameQuestion(
          id: '4',
          title: 'المرحلة 4: كلمة نَجْم',
          prompt: 'رتّب حروف كلمة (نَجْم) الساطعة في السماء ⭐',
          hint: 'نون ثم جيم ثم ميم',
          questionOrder: 4,
          isActive: true,
          payload: {
            'target_word': 'نجم',
            'hint_emoji': '⭐',
            'scrambled_letters': ['م', 'ج', 'ن'],
            'correct_order': ['ن', 'ج', 'م'],
          },
        ),
      ],
    ),
  ];
}

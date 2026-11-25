import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة الاتصال بـ API خادم لولو (Laravel Backend)
/// تدعم التخزين المؤقت، والمصادقة برمز Sanctum، والعمل دون اتصال، والاكتشاف التلقائي للخادم
class ApiService {
  late final Dio _dio;
  final String? explicitBaseUrl;

  static const String _tokenKey = 'lulu_auth_token';
  static const String customUrlKey = 'lulu_custom_server_url';

  // عناوين IP للربط مع بيئات التشغيل المختلفة
  static const String defaultLanIp = '192.168.1.101';
  static const String emulatorIp = '10.0.2.2';
  static const String localhostIp = 'localhost';
  static const String loopbackIp = '127.0.0.1';

  static String? _configuredBaseUrl;

  /// تهيئة إعدادات العنوان المخزن عند بدء تشغيل التطبيق
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(customUrlKey);
      if (saved != null && saved.isNotEmpty && !saved.contains('192.168.8.197')) {
        _configuredBaseUrl = saved;
      } else {
        _configuredBaseUrl = defaultBaseUrl;
      }
    } catch (_) {}
  }

  /// العنوان الافتراضي الذكي بحسب بيئة التشغيل الحالية
  static String get defaultBaseUrl {
    if (_configuredBaseUrl != null && _configuredBaseUrl!.isNotEmpty) {
      return _configuredBaseUrl!;
    }
    // للويب ومنصات سطح المكتب (Windows / macOS / Linux) حيث الخادم يعمل محلياً
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'http://$loopbackIp:8000/api/v1';
    }
    // للأجهزة المحمولة عبر شبكة Wi-Fi
    return 'http://$defaultLanIp:8000/api/v1';
  }

  /// قائمة العناوين المحتملة للاتصال بالخادم
  static List<String> get candidateBaseUrls => [
        'http://$loopbackIp:8000/api/v1',
        'http://$defaultLanIp:8000/api/v1',
        'http://$emulatorIp:8000/api/v1',
        'http://$localhostIp:8000/api/v1',
      ];

  String get baseUrl => _dio.options.baseUrl;

  static void setBaseUrl(String url) {
    _configuredBaseUrl = url;
  }

  static Future<void> resetBaseUrl() async {
    _configuredBaseUrl = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(customUrlKey);
  }

  /// اختبار عنوان محدد مباشرة مع مهلة محددة
  static Future<bool> testUrl(String url, {Duration timeout = const Duration(milliseconds: 2500)}) async {
    try {
      final testDio = Dio(
        BaseOptions(
          baseUrl: url.trim(),
          connectTimeout: timeout,
          receiveTimeout: timeout,
          headers: {'Accept': 'application/json'},
        ),
      );
      final res = await testDio.get('/categories');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// كشف تلقائي ذكي عن عنوان الخادم الشغال واختياره وحفظه
  static Future<String?> autoDetectWorkingBaseUrl({Duration timeout = const Duration(milliseconds: 2500)}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(customUrlKey);

    final candidates = {
      if (saved != null && saved.isNotEmpty) saved,
      defaultBaseUrl,
      ...candidateBaseUrls,
    }.toList();

    for (final candidate in candidates) {
      final isUp = await testUrl(candidate, timeout: timeout);
      if (isUp) {
        setBaseUrl(candidate);
        await prefs.setString(customUrlKey, candidate);
        return candidate;
      }
    }
    return null;
  }

  ApiService({String? baseUrl}) : explicitBaseUrl = baseUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? defaultBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // إضافة Interceptor لتمرير رمز المصادقة وتحميل الرابط المحفوظ تلقائياً
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // في حال لم يتم تمرير baseUrl مخصص صراحة في المشيّد، نقرأ العنوان المحفوظ
          if (explicitBaseUrl == null) {
            final prefs = await SharedPreferences.getInstance();
            var savedUrl = prefs.getString(customUrlKey);

            // ترقية تلقائية في حال كان الرابط المحفوظ يشير للعنوان القديم غير الفعال
            if (savedUrl != null && (savedUrl.contains('192.168.8.197') || savedUrl.isEmpty)) {
              savedUrl = defaultBaseUrl;
              await prefs.setString(customUrlKey, defaultBaseUrl);
            }

            if (savedUrl != null && savedUrl.isNotEmpty) {
              options.baseUrl = savedUrl;
            }
          }

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// اختبار الاتصال بالخادم
  Future<bool> testConnection({Duration timeout = const Duration(seconds: 4)}) async {
    try {
      final res = await _dio.get(
        '/categories',
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // --- المصادقة وحساب ولي الأمر ---
  Future<Response> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? childNickname,
  }) async {
    return _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'child_nickname': childNickname,
    });
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getProfile() async {
    return _dio.get('/auth/me');
  }

  Future<Response> updateChildNickname({int? childId, required String nickname, String? avatarId}) async {
    return _dio.post('/children/update', data: {
      if (childId != null) 'child_id': childId,
      'nickname': nickname.trim(),
      if (avatarId != null) 'avatar_id': avatarId,
    });
  }

  Future<Response> addChild({
    required String nickname,
    int? birthYear,
    String? avatarId,
  }) async {
    return _dio.post('/children/add', data: {
      'nickname': nickname.trim(),
      if (birthYear != null) 'birth_year': birthYear,
      if (avatarId != null) 'avatar_id': avatarId,
    });
  }

  // --- المحتوى والدروس ---
  Future<Response> getCategories() async {
    return _dio.get('/categories');
  }

  Future<Response> getLessons({int? categoryId}) async {
    return _dio.get(
      '/lessons',
      queryParameters: categoryId != null ? {'category_id': categoryId} : null,
    );
  }

  Future<Response> getLessonDetails(int lessonId) async {
    return _dio.get('/lessons/$lessonId');
  }

  Future<Response> getMotivationalSounds() async {
    return _dio.get('/motivational-sounds');
  }

  // --- الاشتراكات والطلبات ---
  Future<Response> getPlans() async {
    return _dio.get('/plans');
  }

  Future<Response> getSubscriptionStatus() async {
    return _dio.get('/subscription/status');
  }

  Future<Response> cancelSubscription() async {
    return _dio.post('/subscription/cancel');
  }

  Future<Response> createOrder(int planId) async {
    return _dio.post('/orders', data: {'plan_id': planId});
  }

  Future<Response> submitManualPayment({
    required int orderId,
    String? transferReference,
    String? filePath,
  }) async {
    dynamic bodyData;
    if (filePath != null && filePath.isNotEmpty) {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      bodyData = FormData.fromMap({
        if (transferReference != null && transferReference.isNotEmpty)
          'transfer_reference': transferReference,
        'proof': await MultipartFile.fromFile(filePath, filename: fileName),
      });
    } else {
      bodyData = FormData.fromMap({
        if (transferReference != null && transferReference.isNotEmpty)
          'transfer_reference': transferReference,
      });
    }

    return _dio.post(
      '/orders/$orderId/payments',
      data: bodyData,
    );
  }

  // --- مزامنة التقدم والنجوم مع الخادم ---
  Future<Response> syncProgress({
    int? childId,
    int? starsCount,
    List<String>? completedLessons,
    List<Map<String, dynamic>>? progress,
  }) async {
    return _dio.post('/progress/sync', data: {
      if (childId != null) 'child_id': childId,
      if (starsCount != null) 'stars_count': starsCount,
      if (completedLessons != null) 'completed_lessons': completedLessons,
      if (progress != null) 'progress': progress,
    });
  }

  Future<Response> getChildProgress([int? childId]) async {
    return _dio.get(
      '/progress',
      queryParameters: {
        if (childId != null) 'child_id': childId,
      },
    );
  }

  // --- إشعارات وتنبيهات ولي الأمر ---
  Future<Response> getNotifications() async {
    return _dio.get('/notifications');
  }

  Future<Response> markNotificationAsRead(int notificationId) async {
    return _dio.post('/notifications/$notificationId/read');
  }

  Future<Response> markAllNotificationsAsRead() async {
    return _dio.post('/notifications/read-all');
  }

  // --- الألعاب التعليمية ---
  Future<Response> getEducationalGames({String? categoryId, String? gameType}) async {
    return _dio.get('/games', queryParameters: {
      if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
      if (gameType != null && gameType.isNotEmpty) 'game_type': gameType,
    });
  }

  Future<Response> getGameDetails(String gameId) async {
    return _dio.get('/games/$gameId');
  }

  Future<Response> completeGame(String gameId) async {
    return _dio.post('/games/$gameId/complete');
  }
}

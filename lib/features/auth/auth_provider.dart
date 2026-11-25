import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_service.dart';
import '../progress/progress_provider.dart';
import 'models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  ParentUser? _currentUser;
  Map<String, dynamic>? _latestPayment;
  int _unreadNotificationsCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService;

  ParentUser? get currentUser => _currentUser;
  Map<String, dynamic>? get latestPayment => _latestPayment;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setUnreadNotificationsCount(int count) {
    if (_unreadNotificationsCount != count) {
      _unreadNotificationsCount = count;
      notifyListeners();
    }
  }

  /// تحديث عدد الإشعارات غير المقروءة من الخادم
  Future<void> refreshNotificationsCount() async {
    if (!isAuthenticated) {
      if (_unreadNotificationsCount != 0) {
        _unreadNotificationsCount = 0;
        notifyListeners();
      }
      return;
    }
    try {
      final response = await _apiService.getNotifications();
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final count = response.data['data']['unread_count'];
        if (count is int) {
          _unreadNotificationsCount = count;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  AuthProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    checkAuth();
  }

  /// التحقق الأولي من وجود جلسة دخول محفوظة لولي الأمر
  Future<void> checkAuth([ProgressProvider? progress]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUser = prefs.getString('lulu_parent_user_json');
      if (cachedUser != null) {
        _currentUser = ParentUser.fromJson(jsonDecode(cachedUser));
        if (progress != null) {
          progress.setSubscribed(_currentUser!.hasActiveSubscription);
          String childName = 'البطل الصغير';
          int childStars = 12;
          List<String> childLessons = ['let_1', 'num_1'];
          int? childId;
          if (_currentUser!.children.isNotEmpty) {
            final child = _currentUser!.children.first;
            childName = child.nickname;
            childStars = child.starsCount;
            childLessons = child.completedLessons;
            childId = child.id;
          }
          await progress.switchUserScope(
            _currentUser!.id.toString(),
            childId: childId,
            defaultNickname: childName,
            initialStars: childStars,
            initialCompletedLessons: childLessons,
          );
        }
        notifyListeners();
      }

      // محاولة تحديث البيانات من الخادم إن وجد إنترنت
      final response = await _apiService.getProfile();
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final hasSub = data['has_active_subscription'] == true;
        if (data['latest_payment'] is Map) {
          _latestPayment = Map<String, dynamic>.from(data['latest_payment']);
        }
        if (data['unread_notifications_count'] is int) {
          _unreadNotificationsCount = data['unread_notifications_count'];
        }
        _currentUser = ParentUser.fromJson(data['user'], hasSubscription: hasSub);
        await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));

        if (progress != null) {
          progress.setSubscribed(hasSub);
          String childName = 'البطل الصغير';
          int childStars = 12;
          List<String> childLessons = ['let_1', 'num_1'];
          int? childId;
          if (_currentUser!.children.isNotEmpty) {
            final child = _currentUser!.children.first;
            childName = child.nickname;
            childStars = child.starsCount;
            childLessons = child.completedLessons;
            childId = child.id;
          }
          await progress.switchUserScope(
            _currentUser!.id.toString(),
            childId: childId,
            defaultNickname: childName,
            initialStars: childStars,
            initialCompletedLessons: childLessons,
          );
          progress.syncWithServer(childId: childId);
        }
        notifyListeners();
      }
    } catch (_) {
      // وضع عدم الاتصال
    }
  }

  /// تحديث حالة الاشتراك والمدفوعات فورياً من الخادم ومزامنتها في كل أرجاء التطبيق دون الحاجة لتسجيل الخروج
  Future<bool> refreshSubscriptionStatus([ProgressProvider? progress]) async {
    try {
      final response = await _apiService.getSubscriptionStatus();
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final hasSub = data['has_active_subscription'] == true;
        if (data['latest_payment'] is Map) {
          _latestPayment = Map<String, dynamic>.from(data['latest_payment']);
        }
        if (data['unread_notifications_count'] is int) {
          _unreadNotificationsCount = data['unread_notifications_count'];
        }

        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(hasActiveSubscription: hasSub);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));
        }

        if (progress != null) {
          progress.setSubscribed(hasSub);
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing subscription status: $e');
    }
    return false;
  }

  /// إلغاء اشتراك ولي الأمر من الخادم وتحديث الحالة في كل أرجاء التطبيق
  Future<bool> cancelSubscription([ProgressProvider? progress]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.cancelSubscription();
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(hasActiveSubscription: false);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));
        }

        if (response.data['data'] != null && response.data['data']['unread_notifications_count'] is int) {
          _unreadNotificationsCount = response.data['data']['unread_notifications_count'];
        }

        if (progress != null) {
          progress.setSubscribed(false);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message']?.toString() ?? 'فشل إلغاء الاشتراك من الخادم';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      // في حال كان المستخدم في وضع غير متصل أو اشتراك تجريبي محلي، نلغي الحالة محلياً
      if (progress != null) {
        progress.setSubscribed(false);
      }
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(hasActiveSubscription: false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));
      }
      _errorMessage = _formatDioError(dioErr);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (progress != null) {
        progress.setSubscribed(false);
      }
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(hasActiveSubscription: false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));
      }
      _errorMessage = 'حدث خطأ أثناء إلغاء الاشتراك: $e';
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// تسجيل دخول ولي الأمر
  Future<bool> login({
    required String email,
    required String password,
    ProgressProvider? progress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final token = data['token']?.toString() ?? '';
        final hasSub = data['has_active_subscription'] == true;

        await _apiService.saveToken(token);

        if (data['unread_notifications_count'] is int) {
          _unreadNotificationsCount = data['unread_notifications_count'];
        }

        _currentUser = ParentUser.fromJson(data['user'], hasSubscription: hasSub);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));

        if (progress != null) {
          progress.setSubscribed(hasSub);
          String childName = 'البطل الصغير';
          int childStars = 12;
          List<String> childLessons = ['let_1', 'num_1'];
          int? childId;
          if (_currentUser!.children.isNotEmpty) {
            final child = _currentUser!.children.first;
            childName = child.nickname;
            childStars = child.starsCount;
            childLessons = child.completedLessons;
            childId = child.id;
          }
          await progress.switchUserScope(
            _currentUser!.id.toString(),
            childId: childId,
            defaultNickname: childName,
            initialStars: childStars,
            initialCompletedLessons: childLessons,
          );
          progress.syncWithServer(childId: childId);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message']?.toString() ?? 'فشل تسجيل الدخول';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      if (dioErr.response?.data != null && dioErr.response?.data['message'] != null) {
        _errorMessage = dioErr.response?.data['message'].toString();
      } else {
        _errorMessage = _formatDioError(dioErr);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _formatDioError(DioException dioErr) {
    switch (dioErr.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'تعذر الاتصال بالخادم (انتهت مهلة الانتظار). تأكد من تشغيل الخادم بالأمر: php artisan serve --host=0.0.0.0';
      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالخادم على العنوان الحالي. تأكد من تشغيل الخادم وتطابق عنوان IP أو تفعيل توصيل USB (adb reverse).';
      case DioExceptionType.badResponse:
        final status = dioErr.response?.statusCode;
        if (status == 401) {
          return 'بيانات الدخول غير صحيحة، يرجى التحقق من البريد وكلمة المرور.';
        } else if (status == 422) {
          final msg = dioErr.response?.data?['message'];
          return msg?.toString() ?? 'البيانات المدخلة غير صحيحة، يرجى المراجعة.';
        } else if (status == 500) {
          return 'حدث خطأ داخلي في الخادم (500). يرجى مراجعة سجلات خادم Laravel.';
        }
        return 'استجاب الخادم برمز خطأ ($status).';
      case DioExceptionType.cancel:
        return 'تم إلغاء طلب الاتصال بالخادم.';
      case DioExceptionType.badCertificate:
        return 'خطأ في شهادة أمان الاتصال بالخادم.';
      case DioExceptionType.unknown:
      default:
        return 'تعذر الاتصال بالخادم، يرجى التأكد من تشغيل الخادم والاتصال بالشبكة.';
    }
  }

  /// تسجيل حساب جديد لولي الأمر
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? childNickname,
    ProgressProvider? progress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name.trim(),
        email: email.trim(),
        password: password.trim(),
        phone: phone?.trim(),
        childNickname: childNickname?.trim(),
      );

      if (response.statusCode == 201 && response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final token = data['token']?.toString() ?? '';

        await _apiService.saveToken(token);

        _currentUser = ParentUser.fromJson(data['user'], hasSubscription: false);
        _unreadNotificationsCount = data['unread_notifications_count'] is int ? data['unread_notifications_count'] : 1;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));

        if (progress != null) {
          progress.setSubscribed(false);
          final nickname = (childNickname != null && childNickname.trim().isNotEmpty)
              ? childNickname.trim()
              : 'البطل الصغير';
          int? childId;
          if (_currentUser!.children.isNotEmpty) {
            childId = _currentUser!.children.first.id;
          }
          await progress.resetProgress(newNickname: nickname, initialStars: 12);
          await progress.switchUserScope(
            _currentUser!.id.toString(),
            childId: childId,
            defaultNickname: nickname,
            initialStars: 12,
            initialCompletedLessons: const ['let_1', 'num_1'],
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message']?.toString() ?? 'فشل إنشاء الحساب';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      if (dioErr.response?.data != null && dioErr.response?.data['message'] != null) {
        _errorMessage = dioErr.response?.data['message'].toString();
      } else {
        _errorMessage = _formatDioError(dioErr);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث لقب الطفل أو الأفاتار لولي الأمر على الخادم ومزامنته محلياً وفي كائن المستخدم
  Future<bool> updateChildNickname(String newNickname, [ProgressProvider? progress, String? newAvatarId, int? targetChildId]) async {
    final cleanName = newNickname.trim();
    if (cleanName.isEmpty) return false;

    // 1. تحديث محلي فوري
    if (progress != null) {
      await progress.updateChildNickname(cleanName);
    }

    if (_currentUser != null) {
      int? childId = targetChildId;
      List<ChildModel> updatedChildren;
      if (_currentUser!.children.isNotEmpty) {
        final currentChild = (targetChildId != null)
            ? _currentUser!.children.firstWhere((c) => c.id == targetChildId, orElse: () => _currentUser!.children.first)
            : _currentUser!.children.first;
        childId = currentChild.id;
        final updatedChild = ChildModel(
          id: currentChild.id,
          nickname: cleanName,
          birthYear: currentChild.birthYear,
          avatarId: newAvatarId ?? currentChild.avatarId,
          starsCount: currentChild.starsCount,
          completedLessons: currentChild.completedLessons,
        );
        updatedChildren = _currentUser!.children.map((c) => c.id == childId ? updatedChild : c).toList();
      } else {
        updatedChildren = [
          ChildModel(
            id: 1,
            nickname: cleanName,
            birthYear: 2021,
            avatarId: newAvatarId ?? 'rabbit_lulu',
          ),
        ];
      }

      _currentUser = _currentUser!.copyWith(children: updatedChildren);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));
      notifyListeners();

      // 2. مزامنة التحديث مع خادم Laravel لحفظه في قاعدة البيانات بشكل دائم
      try {
        final res = await _apiService.updateChildNickname(
          childId: childId,
          nickname: cleanName,
          avatarId: newAvatarId,
        );
        if (res.statusCode == 200 && res.data != null && res.data['data'] != null) {
          final resUser = res.data['data']['user'];
          if (resUser != null) {
            _currentUser = ParentUser.fromJson(resUser, hasSubscription: _currentUser!.hasActiveSubscription);
            await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));
            notifyListeners();
          }
        }
        return true;
      } catch (e) {
        debugPrint('⚠️ [AuthProvider] تعذر تحديث بيانات الطفل على الخادم: $e');
        return true; // تم التحديث محلياً بنجاح
      }
    }
    return true;
  }

  /// إضافة طفل جديد لحساب ولي الأمر ومزامنته سحابياً
  Future<bool> addChild({
    required String nickname,
    int? birthYear,
    String? avatarId,
    ProgressProvider? progress,
  }) async {
    final cleanName = nickname.trim();
    if (cleanName.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.addChild(
        nickname: cleanName,
        birthYear: birthYear,
        avatarId: avatarId,
      );

      if (res.statusCode == 201 && res.data != null && res.data['data'] != null) {
        final resUser = res.data['data']['user'];
        if (resUser != null) {
          _currentUser = ParentUser.fromJson(resUser, hasSubscription: _currentUser?.hasActiveSubscription ?? false);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lulu_parent_user_json', jsonEncode(_currentUser!.toJson()));
        }

        final newChildData = res.data['data']['child'];
        if (newChildData != null && progress != null) {
          final newChild = ChildModel.fromJson(newChildData);
          await progress.switchUserScope(
            _currentUser!.id.toString(),
            childId: newChild.id,
            defaultNickname: newChild.nickname,
            initialStars: newChild.starsCount,
            initialCompletedLessons: newChild.completedLessons,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data?['message']?.toString() ?? 'فشل إضافة الطفل';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      if (dioErr.response?.data != null && dioErr.response?.data['message'] != null) {
        _errorMessage = dioErr.response?.data['message'].toString();
      } else {
        _errorMessage = _formatDioError(dioErr);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// اختيار وتبديل ملف الطفل النشط حالياً
  Future<void> selectActiveChild(ChildModel child, ProgressProvider progress) async {
    if (_currentUser == null) return;
    await progress.switchUserScope(
      _currentUser!.id.toString(),
      childId: child.id,
      defaultNickname: child.nickname,
      initialStars: child.starsCount,
      initialCompletedLessons: child.completedLessons,
    );
    notifyListeners();
  }

  /// تسجيل الخروج
  Future<void> logout([ProgressProvider? progress]) async {
    try {
      await _apiService.clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lulu_parent_user_json');
      _currentUser = null;
      _latestPayment = null;
      _unreadNotificationsCount = 0;
      _errorMessage = null;
      if (progress != null) {
        await progress.switchUserScope(null);
        progress.setSubscribed(false);
      }
      notifyListeners();
    } catch (_) {}
  }
}

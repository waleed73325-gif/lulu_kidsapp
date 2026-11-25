import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_provider.dart';
import 'models/parent_notification_model.dart';
import 'subscription_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  List<ParentNotificationModel> _notifications = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, unread, subscriptions

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getNotifications();
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final List raw = response.data['data']['notifications'] ?? [];
        final parsed = raw.map((n) => ParentNotificationModel.fromJson(n as Map<String, dynamic>)).toList();
        final unreadCount = parsed.where((n) => !n.isRead).length;
        if (mounted) {
          context.read<AuthProvider>().setUnreadNotificationsCount(unreadCount);
          setState(() {
            _notifications = parsed;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(ParentNotificationModel notif) async {
    if (notif.isRead) return;

    // تحديث الواجهة فورياً
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == notif.id);
      if (idx != -1) {
        _notifications[idx] = notif.copyWith(isRead: true, readAt: DateTime.now());
      }
    });

    final remainingUnread = _notifications.where((n) => !n.isRead).length;
    if (mounted) {
      context.read<AuthProvider>().setUnreadNotificationsCount(remainingUnread);
    }

    try {
      await _apiService.markNotificationAsRead(notif.id);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    if (unreadCount == 0) return;

    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList();
    });

    if (mounted) {
      context.read<AuthProvider>().setUnreadNotificationsCount(0);
    }

    try {
      await _apiService.markAllNotificationsAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديد جميع الإشعارات كمقروءة ✨'),
            backgroundColor: AppColors.mintGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  List<ParentNotificationModel> get _filteredNotifications {
    if (_filter == 'unread') {
      return _notifications.where((n) => !n.isRead).toList();
    } else if (_filter == 'subscriptions') {
      return _notifications.where((n) =>
          n.type == 'subscription_approved' ||
          n.type == 'subscription_rejected' ||
          n.type == 'payment_pending').toList();
    } else if (_filter == 'announcements') {
      return _notifications.where((n) =>
          n.type == 'announcement' ||
          n.type == 'offer' ||
          n.type == 'update' ||
          n.type == 'alert' ||
          n.type == 'general' ||
          n.type == 'welcome').toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الإشعارات والتنبيهات 🔔', style: AppTypography.titleLarge),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
              label: Text(
                'قراءة الكل',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // شريط تصفية الإشعارات
            _buildFilterBar(unreadCount),

            // قائمة الإشعارات
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, idx) => _buildNotificationCard(filtered[idx]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(int unreadCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('all', 'الكل (${_notifications.length})'),
          const SizedBox(width: 8),
          _buildFilterChip('unread', 'غير المقروءة ($unreadCount)'),
          const SizedBox(width: 8),
          _buildFilterChip('announcements', 'التعميمات والعروض 📢'),
          const SizedBox(width: 8),
          _buildFilterChip('subscriptions', 'الاشتراكات 💳'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textMedium,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(ParentNotificationModel notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: notif.isRead ? const Color(0xFFE2E8F0) : notif.color.withValues(alpha: 0.4),
          width: notif.isRead ? 1 : 1.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.islandShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _markAsRead(notif),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الرأس: الأيقونة + العنوان + الوقت
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notif.bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(notif.icon, color: notif.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: notif.bgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notif.typeLabel,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: notif.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              notif.timeAgo,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textLight,
                                fontSize: 11,
                              ),
                            ),
                            if (!notif.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.playfulCoral,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notif.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: notif.isRead ? AppColors.textDark : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // نص الرسالة
              Padding(
                padding: const EdgeInsets.only(right: 46),
                child: Text(
                  notif.body,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),

              // زر تفاعلي مخصص حسب نوع الإشعار
              if (notif.type == 'subscription_approved' ||
                  notif.type == 'subscription_rejected' ||
                  notif.type == 'payment_pending' ||
                  notif.type == 'offer') ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 46),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildActionButtonForType(notif),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonForType(ParentNotificationModel notif) {
    if (notif.type == 'subscription_approved') {
      return TextButton.icon(
        onPressed: () {
          _markAsRead(notif);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
          );
        },
        icon: const Icon(Icons.stars_rounded, size: 16, color: AppColors.mintGreen),
        label: Text(
          'عرض تفاصيل الباقة والدروس ✨',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mintGreen, fontWeight: FontWeight.w800, fontSize: 12),
        ),
      );
    } else if (notif.type == 'subscription_rejected') {
      return ElevatedButton.icon(
        onPressed: () {
          _markAsRead(notif);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubscriptionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.replay_rounded, size: 16),
        label: const Text('اختيار باقة وإعادة التحويل 📝'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC0392B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
      );
    } else if (notif.type == 'offer') {
      return TextButton.icon(
        onPressed: () {
          _markAsRead(notif);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
          );
        },
        icon: const Icon(Icons.local_offer_rounded, size: 16, color: AppColors.goldenStar),
        label: Text(
          'استكشف العروض والباقات 🎁',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.goldenStar, fontWeight: FontWeight.w800, fontSize: 12),
        ),
      );
    } else {
      return TextButton.icon(
        onPressed: () {
          _markAsRead(notif);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
          );
        },
        icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFE67E22)),
        label: Text(
          'متابعة حالة الطلب ⏳',
          style: AppTypography.bodyMedium.copyWith(color: const Color(0xFFE67E22), fontWeight: FontWeight.w800, fontSize: 12),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد إشعارات حالياً',
              style: AppTypography.titleLarge.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'ستصلك هنا رسائل اعتماد الاشتراكات وتأكيدات التحويل البنكي والتنبيهات الخاصة ببطلك الصغير.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedium),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_provider.dart';
import '../auth/screens/parent_login_screen.dart';
import '../progress/progress_provider.dart';
import 'notifications_screen.dart';
import 'subscription_screen.dart';

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;
    final progress = context.read<ProgressProvider>();
    await Future.wait([
      auth.refreshSubscriptionStatus(progress),
      auth.refreshNotificationsCount(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final auth = context.watch<AuthProvider>();
    final latestPayment = auth.latestPayment;

    String subSubtitle = 'ترقية الحساب وفتح كل الدروس بالتحويل اليدوي';
    Widget? subTrailing;
    if (progress.isSubscribed) {
      subSubtitle = 'الاشتراك مفعل - إدارة الباقة';
      subTrailing = const Text('مفعل ✅', style: TextStyle(color: AppColors.mintGreen, fontWeight: FontWeight.bold));
    } else if (latestPayment != null) {
      if (latestPayment['status'] == 'pending') {
        subSubtitle = 'طلبك قيد المراجعة والتدقيق من الإدارة ⏳';
        subTrailing = const Text('قيد المراجعة ⏳', style: TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold));
      } else if (latestPayment['status'] == 'rejected') {
        subSubtitle = 'تم رفض الإيصال: ${latestPayment['rejection_reason'] ?? ''}';
        subTrailing = const Text('مرفوض ⚠️', style: TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.bold));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('منطقة ولي الأمر', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: auth.unreadNotificationsCount > 0,
              label: Text(
                '${auth.unreadNotificationsCount}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFFE74C3C),
              textColor: Colors.white,
              child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            ),
            tooltip: 'الإشعارات والتنبيهات',
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
              if (mounted) {
                auth.refreshNotificationsCount();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'تحديث البيانات',
            onPressed: _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // بطاقة حساب ولي الأمر (تسجيل الدخول / الملف الشخصي)
              _buildParentAccountCard(context, auth, progress),
              const SizedBox(height: 16),

              // بطاقة إشعار حالة الاشتراك الفوري
              if (latestPayment != null && !progress.isSubscribed) ...[
                if (latestPayment['status'] == 'pending')
                  _buildStatusBanner(
                    context,
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFE67E22),
                    bgColor: const Color(0xFFFFF9E6),
                    borderColor: const Color(0xFFF39C12),
                    title: 'طلب الاشتراك قيد المراجعة والتدقيق ⏳',
                    subtitle: 'إشعار التحويل البنكي بانتظار اعتماد الإدارة - اضغط لمعاينة وتحديث الحالة',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                  )
                else if (latestPayment['status'] == 'rejected')
                  _buildStatusBanner(
                    context,
                    icon: Icons.error_outline_rounded,
                    color: const Color(0xFFC0392B),
                    bgColor: const Color(0xFFFFF0F0),
                    borderColor: const Color(0xFFE74C3C),
                    title: 'تنبيه: تم رفض إشعار التحويل الأخير ❌',
                    subtitle: 'سبب الرفض: ${latestPayment['rejection_reason'] ?? 'يرجى مراجعة الإدارة'} - اضغط لإعادة الإرسال',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                  ),
                const SizedBox(height: 16),
              ] else if (progress.isSubscribed) ...[
                _buildStatusBanner(
                  context,
                  icon: Icons.verified_rounded,
                  color: AppColors.mintGreen,
                  bgColor: AppColors.mintGreen.withValues(alpha: 0.12),
                  borderColor: AppColors.mintGreen,
                  title: 'اشتراك لولو بلس مفعل ومؤكد 🎉',
                  subtitle: 'جميع الدروس والأنشطة متاحة بدون أي قيود لطفلك',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                ),
                const SizedBox(height: 16),
              ],

              // بطاقة ملف الطفل
              _buildChildProfileSection(context, auth, progress),
              const SizedBox(height: 20),

              // خيارات الإدارة
              _buildActionTile(
                context,
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFFF39C12),
                title: 'الإشعارات والتنبيهات 🔔',
                subtitle: auth.unreadNotificationsCount > 0
                    ? 'لديك ${auth.unreadNotificationsCount} إشعار جديد غير مقروء'
                    : 'متابعة قرارات التحويلات وتحديثات الإدارة',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (auth.unreadNotificationsCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${auth.unreadNotificationsCount} جديد',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
                onTap: () async {
                  final auth = context.read<AuthProvider>();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                  if (mounted) {
                    auth.refreshNotificationsCount();
                  }
                },
              ),

              _buildActionTile(
                context,
                icon: Icons.card_membership_rounded,
                iconColor: AppColors.primary,
                title: 'الاشتراك والباقات (Lulu+)',
                subtitle: subSubtitle,
                trailing: subTrailing,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  );
                },
              ),

            _buildActionTile(
              context,
              icon: Icons.download_done_rounded,
              iconColor: AppColors.skyBlue,
              title: 'إدارة المحتوى دون إنترنت (Offline)',
              subtitle: 'الدروس محملة تلقائياً للاستخدام في أي وقت',
              onTap: () => _showOfflineManagerDialog(context, progress),
            ),

            _buildActionTile(
              context,
              icon: Icons.verified_user_outlined,
              iconColor: AppColors.mintGreen,
              title: 'سياسة الخصوصية وأمان الأطفال',
              subtitle: 'نلتزم بعدم جمع أي بيانات شخصية أو تتبع سلوكي للطفل',
              onTap: () => _showPrivacyDialog(context),
            ),

            _buildActionTile(
              context,
              icon: Icons.delete_forever_rounded,
              iconColor: const Color(0xFFD63031),
              title: 'إعادة تعيين رصيد الإنجاز',
              subtitle: 'مسح سجل النجوم المحفوظة على هذا الجهاز',
              onTap: () => _showDeleteDataDialog(context, progress),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildParentAccountCard(
    BuildContext context,
    AuthProvider auth,
    ProgressProvider progress,
  ) {
    if (auth.isAuthenticated) {
      final user = auth.currentUser!;
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.islandShadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 22,
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTypography.titleMedium),
                      Text(
                        user.email,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedium, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.hasActiveSubscription
                        ? AppColors.mintGreen.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.hasActiveSubscription ? 'مشترك بلس 🌟' : 'حساب عادي',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.hasActiveSubscription ? AppColors.mintGreen : AppColors.textMedium,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('جلسة الحساب سحابية نشطة', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                TextButton.icon(
                  onPressed: () => _confirmLogout(context, auth, progress),
                  icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFD63031)),
                  label: const Text('تسجيل خروج', style: TextStyle(color: Color(0xFFD63031), fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: AppColors.islandShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  'حساب ولي الأمر (غير مسجل)',
                  style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'سجّل دخولك لحفظ مسيرة طفلك السحابية وتفعيل الاشتراكات والوصول لجميع الأجهزة.',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
                );
              },
              icon: const Icon(Icons.login_rounded, color: AppColors.primary),
              label: const Text(
                'تسجيل الدخول / إنشاء حساب جديد',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _confirmLogout(BuildContext context, AuthProvider auth, ProgressProvider progress) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل ترغب في تسجيل الخروج من حساب ولي الأمر على هذا الجهاز؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD63031)),
            onPressed: () {
              auth.logout(progress);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
              );
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.islandShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        title: Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 16)),
        subtitle: Text(subtitle, style: AppTypography.bodyMedium.copyWith(fontSize: 13)),
        trailing: trailing ?? const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  static String _avatarEmoji(String? avatarId) {
    switch (avatarId) {
      case 'bear_bobi':
        return '🐻';
      case 'fox_fofo':
        return '🦊';
      case 'cat_mishmish':
        return '🐱';
      case 'lion_laith':
        return '🦁';
      case 'bird_koky':
        return '🦜';
      case 'panda_bando':
        return '🐼';
      case 'rabbit_lulu':
      default:
        return '🐰';
    }
  }

  static const List<Map<String, String>> _availableAvatars = [
    {'id': 'rabbit_lulu', 'emoji': '🐰', 'name': 'لولو'},
    {'id': 'bear_bobi', 'emoji': '🐻', 'name': 'بوبي'},
    {'id': 'fox_fofo', 'emoji': '🦊', 'name': 'فوفو'},
    {'id': 'cat_mishmish', 'emoji': '🐱', 'name': 'مشمش'},
    {'id': 'lion_laith', 'emoji': '🦁', 'name': 'ليث'},
    {'id': 'bird_koky', 'emoji': '🦜', 'name': 'كوكي'},
    {'id': 'panda_bando', 'emoji': '🐼', 'name': 'باندو'},
  ];

  Widget _buildChildProfileSection(BuildContext context, AuthProvider auth, ProgressProvider progress) {
    final currentAvatarId = (auth.currentUser?.children.isNotEmpty == true)
        ? auth.currentUser!.children.firstWhere(
            (c) => c.nickname == progress.childNickname || c.id == progress.activeChildId,
            orElse: () => auth.currentUser!.children.first,
          ).avatarId
        : 'rabbit_lulu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (auth.isAuthenticated && (auth.currentUser?.children.length ?? 0) > 1) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: auth.currentUser!.children.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  if (i == auth.currentUser!.children.length) {
                    return ActionChip(
                      avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
                      label: const Text('طفل جديد', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () => _showAddChildDialog(context, auth, progress),
                    );
                  }
                  final ch = auth.currentUser!.children[i];
                  final isSelected = (progress.activeChildId == ch.id) || (progress.childNickname == ch.nickname);
                  return ChoiceChip(
                    avatar: Text(_avatarEmoji(ch.avatarId), style: const TextStyle(fontSize: 14)),
                    label: Text(ch.nickname, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    onSelected: (_) {
                      auth.selectActiveChild(ch, progress);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                },
              ),
            ),
          ),
        ],

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.islandShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showEditNicknameDialog(context, progress, auth),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(_avatarEmoji(currentAvatarId), style: const TextStyle(fontSize: 34)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(progress.childNickname, style: AppTypography.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'رصيد الإنجاز: ${progress.starsCount} نجمة 🌟',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.goldenStar, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'تعديل الاسم والشخصية',
                onPressed: () => _showEditNicknameDialog(context, progress, auth),
              ),
              if (auth.isAuthenticated && (auth.currentUser?.children.length ?? 0) < 5)
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.mintGreen),
                  tooltip: 'إضافة طفل جديد',
                  onPressed: () => _showAddChildDialog(context, auth, progress),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditNicknameDialog(BuildContext context, ProgressProvider progress, [AuthProvider? authProvider]) {
    final auth = authProvider ?? context.read<AuthProvider>();
    final controller = TextEditingController(text: progress.childNickname);
    String selectedAvatar = 'rabbit_lulu';

    if (auth.currentUser?.children.isNotEmpty == true) {
      final currentChild = auth.currentUser!.children.firstWhere(
        (c) => c.nickname == progress.childNickname || c.id == progress.activeChildId,
        orElse: () => auth.currentUser!.children.first,
      );
      selectedAvatar = currentChild.avatarId;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('تعديل ملف وشخصية الطفل', style: AppTypography.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'الاسم المستعار للطفل',
                    hintText: 'مثال: البطل أحمد',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('اختر شخصية الطفل المفضلة (الأفاتار):', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _availableAvatars.map((av) {
                    final isSel = selectedAvatar == av['id'];
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedAvatar = av['id']!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary.withValues(alpha: 0.15) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.grey.shade300,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(av['emoji']!, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 2),
                            Text(av['name']!, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await auth.updateChildNickname(newName, progress, selectedAvatar);
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ وتحديث', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChildDialog(BuildContext context, AuthProvider auth, ProgressProvider progress) {
    final nameController = TextEditingController();
    String selectedAvatar = 'rabbit_lulu';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('إضافة بطل جديد للعائلة 🌟', style: AppTypography.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم المستعار للطفل الجديد',
                    hintText: 'مثال: سارة أو البطل خالد',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('اختر شخصية الطفل:', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _availableAvatars.map((av) {
                    final isSel = selectedAvatar == av['id'];
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedAvatar = av['id']!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary.withValues(alpha: 0.15) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.grey.shade300,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(av['emoji']!, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 2),
                            Text(av['name']!, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mintGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final ok = await auth.addChild(
                    nickname: name,
                    avatarId: selectedAvatar,
                    progress: progress,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تمت إضافة البطل "$name" بنجاح! 🎉'),
                          backgroundColor: AppColors.mintGreen,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('إضافة الطفل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflineManagerDialog(BuildContext context, ProgressProvider progress) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_done_rounded, color: AppColors.skyBlue, size: 24),
            ),
            const SizedBox(width: 10),
            Text('المحتوى والتخزين دون إنترنت', style: AppTypography.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الجزر والتصنيفات المخزنة:'),
                      Text('${progress.categories.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الدروس والأنشطة الجاهزة:'),
                      Text('${progress.allLessons.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الألعاب التعليمية:'),
                      Text('${progress.games.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'جميع هذه المواد مخزنة محلياً في ذاكرة التطبيق وتعمل بكفاءة تامة دون الحاجة لأي اتصال بالإنترنت أثناء السفر أو في السيارة.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMedium, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await progress.fetchRemoteContent();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تمت مزامنة وتحديث المحتوى المحلي بنجاح ✨'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            icon: const Icon(Icons.sync_rounded, size: 18, color: Colors.white),
            label: const Text('تحديث المحتوى الآن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('التزام لولو بالخصوصية', style: AppTypography.titleLarge),
        content: SingleChildScrollView(
          child: Text(
            'تطبيق لولو للأطفال صُمم ليكون مساحة آمنة وموثوقة:\n\n'
            '1. لا نقوم بجمع الاسم الحقيقي الكامل أو رقم هاتف الطفل.\n'
            '2. لا توجد أي إعلانات تجارية أو تتبع سلوكي.\n'
            '3. لا نطلب الصلاحيات الحساسة كالموقع الجغرافي أو الكاميرا دون إذن مباشر.\n'
            '4. يتم تشفير كافة الاتصالات مع الخادم عبر بروتوكول HTTPS الآمن.',
            style: AppTypography.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً، فهمت'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context, ProgressProvider progress) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد مسح البيانات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف بيانات تقدم الطفل والعودة للوضع الافتراضي؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD63031),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await progress.resetProgress();
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم مسح البيانات وإعادة تعيين النجوم والتقدم بنجاح')),
                );
              }
            },
            child: const Text('مسح البيانات', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

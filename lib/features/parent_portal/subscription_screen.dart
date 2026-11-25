import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/lulu_button.dart';
import '../auth/auth_provider.dart';
import '../auth/screens/parent_login_screen.dart';
import '../progress/progress_provider.dart';
import 'manual_payment_screen.dart';
import 'models/subscription_plan_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isChecking = false;
  bool _isCancelling = false;
  List<SubscriptionPlan> _plans = [];
  bool _isLoadingPlans = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStatus(silent: true);
      _fetchPlans();
    });
  }

  Future<void> _fetchPlans() async {
    setState(() => _isLoadingPlans = true);
    try {
      final res = await ApiService().getPlans();
      if (res.statusCode == 200 && res.data != null && res.data['data'] is List) {
        final list = (res.data['data'] as List)
            .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
            .where((p) => p.isActive)
            .toList();
        if (list.isNotEmpty && mounted) {
          setState(() {
            _plans = list;
          });
        }
      }
    } catch (_) {
      // وضع عدم الاتصال
    } finally {
      if (mounted) setState(() => _isLoadingPlans = false);
    }
  }

  List<SubscriptionPlan> get _displayPlans => _plans.isNotEmpty
      ? _plans
      : const [
          SubscriptionPlan(
            id: 1,
            name: 'باقة 3 أشهر',
            slug: 'starter-3m',
            durationDays: 90,
            price: 29.0,
            description: 'مناسبة لتجربة المحتوى التعليمي',
          ),
          SubscriptionPlan(
            id: 2,
            name: 'باقة السنة الكاملة (12 شهراً)',
            slug: 'full-1y',
            durationDays: 365,
            price: 89.0,
            description: 'أفضل توفير - سنة كاملة من المرح والتعلم',
          ),
        ];

  Future<void> _confirmCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEAEA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD63031),
                size: 26,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تأكيد إلغاء الاشتراك',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'هل أنت متأكد من رغبتك في إلغاء الاشتراك في باقة لولو؟',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFB74D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFE65100), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تنبيه مهم: لا يمكن التراجع عند إلغاء الاشتراك. سيتم إيقاف الميزات المدفوعة والدروس والألعاب المقفلة فوراً وتحويل الحساب للوضع المجاني.',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'التراجع والاحتفاظ بالاشتراك',
              style: TextStyle(
                color: AppColors.textMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD63031),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، تأكيد الإلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _executeCancelSubscription();
    }
  }

  Future<void> _executeCancelSubscription() async {
    setState(() => _isCancelling = true);

    final auth = context.read<AuthProvider>();
    final progress = context.read<ProgressProvider>();

    final success = await auth.cancelSubscription(progress);

    if (mounted) {
      setState(() => _isCancelling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? 'تم إلغاء الاشتراك بنجاح. تم تحويل الحساب للوضع المجاني.'
                      : (auth.errorMessage ?? 'تعذر إلغاء الاشتراك من الخادم، يرجى المحاولة لاحقاً.'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.playfulCoral : const Color(0xFFD63031),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  Future<void> _refreshStatus({bool silent = false}) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    if (!silent) {
      setState(() => _isChecking = true);
    }

    final progress = context.read<ProgressProvider>();
    final success = await auth.refreshSubscriptionStatus(progress);

    if (mounted) {
      if (!silent) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              progress.isSubscribed
                  ? 'تم تفعيل وتأكيد اشتراكك بنجاح! 🎉'
                  : (success ? 'تم تحديث حالة الاشتراك بنجاح ✨' : 'تعذر تحديث الحالة، تأكد من اتصال الإنترنت'),
            ),
            backgroundColor: progress.isSubscribed ? AppColors.mintGreen : AppColors.primary,
          ),
        );
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final auth = context.watch<AuthProvider>();
    final latestPayment = auth.latestPayment;
    final isPending = !progress.isSubscribed && latestPayment != null && latestPayment['status'] == 'pending';
    final isRejected = !progress.isSubscribed && latestPayment != null && latestPayment['status'] == 'rejected';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('اشتراك لولو بلس (Lulu+)', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'تحديث حالة الاشتراك',
            onPressed: _isChecking ? null : () => _refreshStatus(silent: false),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshStatus(silent: false),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة الرأسية الترويجية
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x336C5CE7),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.sunshineYellow, size: 54),
                      const SizedBox(height: 12),
                      Text(
                        'افتح كل جزر التعلم والمغامرات',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'محتوى عربي أصيل، آمن 100% وخالي من أي إعلانات',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. بطاقة إشعار التفعيل المباشر (عند موافقة الإدارة)
                if (progress.isSubscribed) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.mintGreen, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.mintGreen, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'اشتراكك مفعل حالياً (باقة لولو المميزة) 🎉',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.mintGreen,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'تم اعتماد وتفعيل اشتراكك بنجاح. جميع الدروس والأنشطة مفتوحة لك ولأطفالك الآن!',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _refreshStatus(silent: false),
                          icon: const Icon(Icons.sync_rounded, size: 18),
                          label: const Text('مزامنة أحدث بيانات الاشتراك'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.mintGreen,
                            side: const BorderSide(color: AppColors.mintGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  LuluButton(
                    label: _isCancelling ? 'جارٍ إلغاء الاشتراك...' : 'إلغاء الاشتراك في باقة لولو',
                    backgroundColor: const Color(0xFFD63031),
                    shadowColor: const Color(0xFFB71C1C),
                    icon: Icons.cancel_outlined,
                    isSecondary: true,
                    onPressed: _isCancelling ? () {} : _confirmCancelSubscription,
                  ),
                ],

                // 2. بطاقة الطلب قيد المراجعة والتدقيق
                if (isPending) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF39C12), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF39C12).withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF39C12).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFE67E22), size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'طلب الاشتراك قيد المراجعة ⏳',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: const Color(0xFFD35400),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'تم استلام إشعار التحويل البنكي وهو قيد المراجعة من قِبل إدارة لولو لتفعيله مباشرة.',
                                    style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFEAA7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (latestPayment['transfer_reference'] != null)
                                Text('• رقم المرجع: ${latestPayment['transfer_reference']}', style: AppTypography.bodyMedium),
                              if (latestPayment['plan_name'] != null)
                                Text('• الباقة: ${latestPayment['plan_name']}', style: AppTypography.bodyMedium),
                              if (latestPayment['amount'] != null)
                                Text('• المبلغ: ${latestPayment['amount']} ${latestPayment['currency'] ?? 'ر.س'}', style: AppTypography.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: _isChecking ? null : () => _refreshStatus(silent: false),
                          icon: _isChecking
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text('تحديث حالة الاعتماد الآن 🔄'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE67E22),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 3. بطاقة رفض الإشعار مع إيضاح السبب
                if (isRejected) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE74C3C), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFC0392B), size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تم رفض إشعار التحويل البنكي الأخير ❌',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: const Color(0xFFC0392B),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'لم تتمكن الإدارة من اعتماد التحويل للسبب الموضح أدناه:',
                                    style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // صندوق سبب الرفض
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFD1D1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFFC0392B), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  latestPayment['rejection_reason'] ?? 'بيانات التحويل غير مطابقة مع كشف الحساب أو لم يصل المبلغ.',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFFC0392B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ManualPaymentScreen(
                                  planId: 2,
                                  planName: 'باقة السنة الكاملة (12 شهراً)',
                                  price: '89 ر.س',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.replay_rounded, size: 20),
                          label: const Text('إعادة إرسال إشعار تحويل صحيح 📝'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC0392B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // مميزات الاشتراك
                _buildFeatureRow(Icons.offline_pin_rounded, 'تنزيل الدروس للمشاهدة بدون إنترنت أثناء السفر'),
                _buildFeatureRow(Icons.auto_stories_rounded, 'الوصول الكامل إلى جميع الحكايات والألعاب المغلقة'),
                _buildFeatureRow(Icons.family_restroom_rounded, 'دعم ما يصل إلى 3 ملفات أطفال في حساب العائلة'),
                _buildFeatureRow(Icons.security_rounded, 'حماية بيانات الطفل وفق أعلى معايير الخصوصية'),
                const SizedBox(height: 24),

                // خطط الاشتراك المتاحة
                if (!progress.isSubscribed) ...[
                  if (_isLoadingPlans && _plans.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ..._displayPlans.map((plan) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildPlanCard(
                          context,
                          plan: plan,
                        ),
                      );
                    }),
                  const SizedBox(height: 10),

                  // زر تفعيل وضع الاختبار السريع
                  TextButton.icon(
                    onPressed: () {
                      progress.setSubscribed(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تفعيل الاشتراك تجريبياً بنجاح! جميع الدروس مفتوحة الآن ✨'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.developer_mode_rounded, color: AppColors.primary),
                    label: Text(
                      'تفعيل الاشتراك فورياً (وضع التطوير والاختبار)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.mintGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.mintGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required SubscriptionPlan plan,
  }) {
    final title = plan.name;
    final price = plan.formattedPrice;
    final subtitle = plan.description ?? 'وصول كامل لجميع جزر وألعاب لولو التعليمية';
    final isBestValue = plan.isBestValue;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBestValue ? AppColors.sunshineYellow : const Color(0xFFDFE6E9),
          width: isBestValue ? 2.5 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.islandShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isBestValue)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.sunshineYellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'الأكثر طلباً وتوفيراً ⭐',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleLarge.copyWith(fontSize: 18)),
                    Text(subtitle, style: AppTypography.bodyMedium.copyWith(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                price,
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LuluButton(
            label: 'الدفع عبر التحويل البنكي اليدوي',
            height: 48,
            backgroundColor: isBestValue ? AppColors.primary : AppColors.playfulCoral,
            shadowColor: isBestValue ? AppColors.primaryDark : const Color(0xFFD63031),
            icon: Icons.receipt_long_rounded,
            onPressed: () {
              final auth = context.read<AuthProvider>();
              if (!auth.isAuthenticated) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تسجيل الدخول مطلوب'),
                    content: const Text(
                      'يرجى تسجيل الدخول أو إنشاء حساب ولي الأمر أولاً لربط باقة الاشتراك بحسابك.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ParentLoginScreen(
                                onLoginSuccess: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ManualPaymentScreen(planId: plan.id, planName: title, price: price),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text('تسجيل الدخول الآن'),
                      ),
                    ],
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManualPaymentScreen(planId: plan.id, planName: title, price: price),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/lulu_button.dart';
import '../../../core/widgets/server_config_dialog.dart';
import '../../progress/progress_provider.dart';
import '../auth_provider.dart';
import 'parent_register_screen.dart';

class ParentLoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const ParentLoginScreen({super.key, this.onLoginSuccess});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount() {
    _emailController.text = 'parent@lulukids.com';
    _passwordController.text = 'password123';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final progress = context.read<ProgressProvider>();

    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      progress: progress,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('مرحباً بك مجدداً! تم تسجيل دخولك بنجاح 🎉'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تسجيل دخول ولي الأمر', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary),
            tooltip: 'فحص وإعدادات الخادم',
            onPressed: () => ServerConfigDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // أيقونة ورأس الصفحة
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 54,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'أهلاً بك في منصة لولو',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'سجّل دخولك لمتابعة إنجازات طفلك وتفعيل باقات الاشتراك السحابية',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedium),
                ),
                const SizedBox(height: 24),

                // رسالة الخطأ إن وجدت
                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEAEA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFF7675)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFD63031)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: const Color(0xFFD63031),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (auth.errorMessage!.contains('الخادم') ||
                            auth.errorMessage!.contains('الاتصال') ||
                            auth.errorMessage!.contains('الإنترنت')) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD63031),
                              side: const BorderSide(color: Color(0xFFFF7675)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            ),
                            onPressed: () => ServerConfigDialog.show(context),
                            icon: const Icon(Icons.wifi_tethering_rounded, size: 18),
                            label: const Text(
                              'فحص وتحديث عنوان IP للخادم',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // حقل البريد الإلكتروني
                Text('البريد الإلكتروني:', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // حقل كلمة المرور
                Text('كلمة المرور:', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMedium,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // زر تسجيل الدخول
                if (auth.isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary))
                else
                  LuluButton(
                    label: 'تسجيل الدخول',
                    icon: Icons.login_rounded,
                    backgroundColor: AppColors.primary,
                    shadowColor: AppColors.primaryDark,
                    onPressed: _handleLogin,
                  ),

                const SizedBox(height: 16),

                // زر الحساب التجريبي السريع
                OutlinedButton.icon(
                  onPressed: _fillDemoAccount,
                  icon: const Icon(Icons.flash_on_rounded, color: AppColors.sunshineYellow),
                  label: Text(
                    'تعبئة حساب تجريبي سريع (parent@lulukids.com)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                // رابط إنشاء حساب جديد
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب بعد؟ ', style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ParentRegisterScreen()),
                        );
                      },
                      child: Text(
                        'أنشئ حساباً جديداً',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

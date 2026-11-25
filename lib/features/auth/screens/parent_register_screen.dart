import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/lulu_button.dart';
import '../../../core/widgets/server_config_dialog.dart';
import '../../progress/progress_provider.dart';
import '../auth_provider.dart';
import 'parent_login_screen.dart';

class ParentRegisterScreen extends StatefulWidget {
  const ParentRegisterScreen({super.key});

  @override
  State<ParentRegisterScreen> createState() => _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<ParentRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _childNicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _childNicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final progress = context.read<ProgressProvider>();

    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      childNickname: _childNicknameController.text.trim().isNotEmpty
          ? _childNicknameController.text.trim()
          : null,
      progress: progress,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء حسابك بنجاح! أهلاً بك في عائلة لولو 🌟'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إنشاء حساب ولي الأمر', style: AppTypography.titleLarge),
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
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 48,
                      color: AppColors.mintGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'انضم إلى عالم لولو التعليمي',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'أنشئ حسابك لحفظ مسيرة طفلك التعليمية ومزامنة إنجازاته',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedium),
                ),
                const SizedBox(height: 20),

                // رسالة الخطأ
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
                            auth.errorMessage!.contains('البيانات')) ...[
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

                // اسم ولي الأمر
                Text('الاسم الكامل لولي الأمر:', style: AppTypography.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'مثال: عبدالله محمد',
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'يرجى كتابة الاسم' : null,
                ),
                const SizedBox(height: 14),

                // البريد الإلكتروني
                Text('البريد الإلكتروني:', style: AppTypography.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'parent@example.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                    if (!value.contains('@')) return 'صيغة البريد الإلكتروني غير صحيحة';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // رقم الهاتف
                Text('رقم الهاتف (اختياري للتحويل البنكي):', style: AppTypography.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '05xxxxxxxx',
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // لقب الطفل
                Text('اسم طفلك / لقبه المفضل:', style: AppTypography.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _childNicknameController,
                  decoration: InputDecoration(
                    hintText: 'مثال: سارة، كرم، البطل الصغير',
                    prefixIcon: const Icon(Icons.child_care_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // كلمة المرور
                Text('كلمة المرور (6 خانات على الأقل):', style: AppTypography.titleMedium),
                const SizedBox(height: 6),
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
                    if (value == null || value.trim().length < 6) {
                      return 'كلمة المرور يجب ألا تقل عن 6 خانات';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // زر إنشاء الحساب
                if (auth.isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.mintGreen))
                else
                  LuluButton(
                    label: 'إنشاء الحساب والمتابعة',
                    icon: Icons.check_circle_outline_rounded,
                    backgroundColor: AppColors.mintGreen,
                    shadowColor: const Color(0xFF00947A),
                    onPressed: _handleRegister,
                  ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // رابط العودة لتسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('لديك حساب بالفعل؟ ', style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
                        );
                      },
                      child: Text(
                        'تسجيل الدخول',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

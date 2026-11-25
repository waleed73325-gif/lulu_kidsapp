import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/lulu_button.dart';

class ManualPaymentScreen extends StatefulWidget {
  final int planId;
  final String planName;
  final String price;

  const ManualPaymentScreen({
    super.key,
    this.planId = 1,
    required this.planName,
    required this.price,
  });

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final _refController = TextEditingController();
  final _picker = ImagePicker();
  File? _receiptImage;
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _receiptImage = File(picked.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرفاق صورة إشعار التحويل بنجاح 📸'),
              backgroundColor: AppColors.mintGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر اختيار الصورة: $e'),
            backgroundColor: const Color(0xFFD63031),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إرفاق إشعار التحويل البنكي', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: Text('اختيار من معرض الصور', style: AppTypography.titleMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.mintGreen),
                ),
                title: Text('التقاط صورة بالكاميرا', style: AppTypography.titleMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final ref = _refController.text.trim();
    if (ref.isEmpty && _receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة رقم المرجع أو إرفاق صورة الإشعار للمتابعة'),
          backgroundColor: Color(0xFFD63031),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final planId = widget.planId;
      final api = ApiService();
      final orderRes = await api.createOrder(planId);

      int? orderId;
      if (orderRes.data != null && orderRes.data is Map) {
        final data = orderRes.data['data'];
        if (data is Map) {
          if (data['id'] != null) {
            orderId = data['id'] is int ? data['id'] : int.tryParse(data['id'].toString());
          } else if (data['order'] != null && data['order'] is Map && data['order']['id'] != null) {
            final oId = data['order']['id'];
            orderId = oId is int ? oId : int.tryParse(oId.toString());
          }
        }
      }

      if (orderId == null) {
        throw Exception('تعذر استخراج رقم الطلب من استجابة الخادم');
      }

      final payRes = await api.submitManualPayment(
        orderId: orderId,
        transferReference: ref.isNotEmpty ? ref : 'REF-${DateTime.now().millisecondsSinceEpoch}',
        filePath: _receiptImage?.path,
      );

      if (payRes.statusCode == 200) {
        if (mounted) {
          setState(() {
            _submitted = true;
          });
        }
      } else {
        throw Exception(payRes.data?['message'] ?? 'فشل إرسال إثبات الدفع للخادم');
      }
    } catch (e) {
      debugPrint('Manual payment submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر إرسال الإشعار للخادم: $e'),
            backgroundColor: const Color(0xFFD63031),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إتمام التحويل اليدوي', style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _submitted
              ? _buildSuccessView()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ملخص الباقة
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.islandShadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الباقة المختارة:', style: AppTypography.bodyMedium),
                                Text(widget.planName, style: AppTypography.titleLarge),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.price,
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // بيانات الحساب البنكي الرسمي
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F2F6),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFCED6E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_rounded, color: AppColors.textDark),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('بيانات الحساب البنكي المعتمد:', style: AppTypography.titleMedium),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildBankRow('اسم البنك:', 'مصرف الراجحي / بنك الرياض'),
                          _buildBankRow('اسم المستفيد:', 'مؤسسة لولو للتعليم الذكي'),
                          _buildBankRow('رقم الآيبان (IBAN):', 'SA44 8000 0000 1234 5678 9000'),
                          const SizedBox(height: 8),
                          Text(
                            '⚠️ يرجى التأكد من تحويل المبلغ المحدد تماماً وكتابة اسمك في وصف الحوالة.',
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 12,
                              color: const Color(0xFFD63031),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // إدخال رقم المرجع
                    Text('رقم مرجع التحويل البنكي (اختياري عند إرفاق الصورة):', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _refController,
                      decoration: InputDecoration(
                        hintText: 'مثال: 9823471029',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // إرفاق صورة الإشعار (معاينة حقيقية)
                    Text('إشعار أو إيصال التحويل البنكي:', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    if (_receiptImage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.mintGreen, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.islandShadow,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                _receiptImage!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.mintGreen, size: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'تم تجهيز صورة الإيصال للرفع',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.mintGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _showImageSourceDialog,
                                  icon: const Icon(Icons.change_circle_outlined, size: 18),
                                  label: const Text('تغيير'),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => _receiptImage = null),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD63031)),
                                  tooltip: 'إزالة الصورة',
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.cloud_upload_rounded,
                                color: AppColors.primary,
                                size: 48,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'اضغط هنا لرفع صورة إشعار التحويل البنكي',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '(من معرض الصور أو عبر تصوير الإشعار بالكاميرا)',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textMedium,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // زر الإرسال
                    if (_isSubmitting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: AppColors.mintGreen),
                        ),
                      )
                    else
                      LuluButton(
                        label: 'إرسال طلب التحقق من الدفع',
                        backgroundColor: AppColors.mintGreen,
                        shadowColor: const Color(0xFF00947A),
                        icon: Icons.send_rounded,
                        onPressed: _handleSubmit,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(fontSize: 12, color: AppColors.textMedium)),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.mintGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: AppColors.mintGreen,
            size: 80,
          ),
        ),
        const SizedBox(height: 24),
        Text('تم استلام إثبات التحويل بنجاح!', style: AppTypography.displayMedium),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'حالة طلبك الآن: (قيد المراجعة - Pending).\nيقوم فريق الإدارة بمطابقة العملية وتفعيل باقتك فور التحقق. شكراً لثقتكم في لولو!',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
        ),
        const SizedBox(height: 40),
        LuluButton(
          label: 'العودة إلى منطقة ولي الأمر',
          backgroundColor: AppColors.primary,
          shadowColor: AppColors.primaryDark,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

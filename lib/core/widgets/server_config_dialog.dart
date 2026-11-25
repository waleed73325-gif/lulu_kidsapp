import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  bool? _testResult;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiService.defaultBaseUrl);
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(ApiService.customUrlKey);
    if (saved != null && saved.isNotEmpty && !saved.contains('192.168.8.197')) {
      setState(() {
        _urlController.text = saved;
      });
    } else {
      setState(() {
        _urlController.text = ApiService.defaultBaseUrl;
      });
    }
  }

  void _applyPreset(String host) {
    setState(() {
      _urlController.text = 'http://$host:8000/api/v1';
      _testResult = null;
      _statusMessage = null;
    });
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
      _statusMessage = 'جارٍ فحص الاتصال بالخادم...';
    });

    final stopwatch = Stopwatch()..start();
    final urlToTest = _urlController.text.trim();
    final success = await ApiService.testUrl(urlToTest);
    stopwatch.stop();

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testResult = success;
        _statusMessage = success
            ? 'تم الاتصال بالخادم بنجاح! 🚀 (${stopwatch.elapsedMilliseconds}ms)\nالخادم جاهز ويستقبل كافة الطلبات.'
            : 'تعذر الاتصال بالخادم على هذا العنوان.\n• تأكد من تشغيل الخادم بالأمر:\n  php artisan serve --host=0.0.0.0 --port=8000\n• عند التوصيل بـ USB نفذ: adb reverse tcp:8000 tcp:8000\n• أو جرب زر "كشف تلقائي ذكي" أدناه.';
      });
    }
  }

  Future<void> _autoDetectServer() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
      _statusMessage = 'جارٍ فحص كافة المنافذ والعناوين المتاحة لاكتشاف الخادم...';
    });

    final detected = await ApiService.autoDetectWorkingBaseUrl();

    if (mounted) {
      setState(() {
        _isTesting = false;
        if (detected != null) {
          _urlController.text = detected;
          _testResult = true;
          _statusMessage = 'تم اكتشاف الخادم الفعال وتحديده بنجاح! 🚀\nالعنوان: $detected';
        } else {
          _testResult = false;
          _statusMessage = 'لم يتم العثور على خادم يعمل على أي من العناوين المحتملة.\nتأكد من تشغيل الخادم بالأمر:\nphp artisan serve --host=0.0.0.0 --port=8000';
        }
      });
    }
  }

  Future<void> _save() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiService.customUrlKey, newUrl);
    ApiService.setBaseUrl(newUrl);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ عنوان الخادم بنجاح ✅'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _resetToDefault() async {
    await ApiService.resetBaseUrl();
    setState(() {
      _urlController.text = ApiService.defaultBaseUrl;
      _testResult = null;
      _statusMessage = null;
    });
    _testConnection();
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _urlController.text.trim();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('إعدادات الاتصال بالخادم', style: AppTypography.titleLarge),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر أحد العناوين الجاهزة أو أدخل عنوان IP لجهاز الكمبيوتر المتصل بنفس الشبكة:',
              style: AppTypography.bodyMedium.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),

            // أزرار سريعة للاختيار المباشر
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip(
                  label: 'USB / محلي (${ApiService.loopbackIp})',
                  isSelected: currentText.contains(ApiService.loopbackIp),
                  onTap: () => _applyPreset(ApiService.loopbackIp),
                ),
                _buildPresetChip(
                  label: 'Wi-Fi الكمبيوتر (${ApiService.defaultLanIp})',
                  isSelected: currentText.contains(ApiService.defaultLanIp),
                  onTap: () => _applyPreset(ApiService.defaultLanIp),
                ),
                _buildPresetChip(
                  label: 'محاكي أندرويد (${ApiService.emulatorIp})',
                  isSelected: currentText.contains(ApiService.emulatorIp),
                  onTap: () => _applyPreset(ApiService.emulatorIp),
                ),
                _buildPresetChip(
                  label: 'محلي (${ApiService.localhostIp})',
                  isSelected: currentText.contains(ApiService.localhostIp),
                  onTap: () => _applyPreset(ApiService.localhostIp),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _urlController,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'رابط الخادم (API Base URL)',
                hintText: 'http://192.168.1.101:8000/api/v1',
                filled: true,
                fillColor: const Color(0xFFF1F2F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cable_rounded, size: 18),
                    label: const Text('فحص الاتصال'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _isTesting ? null : _autoDetectServer,
                    icon: const Icon(Icons.travel_explore_rounded, size: 18),
                    label: const Text('كشف تلقائي ذكي'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isTesting ? null : _resetToDefault,
                icon: const Icon(Icons.restore_rounded, size: 16),
                label: const Text('استعادة العنوان الافتراضي', style: TextStyle(fontSize: 12)),
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult == true
                      ? AppColors.mintGreen.withValues(alpha: 0.12)
                      : const Color(0xFFFFEAEA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _testResult == true ? AppColors.mintGreen : const Color(0xFFFF7675),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _testResult == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: _testResult == true ? AppColors.mintGreen : const Color(0xFFD63031),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _testResult == true ? AppColors.mintGreen : const Color(0xFFD63031),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _save,
          child: const Text('حفظ وتطبيق', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textLight.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

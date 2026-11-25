import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lulu_kids/core/network/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiService.resetBaseUrl();
  });

  group('ApiService Configuration & Discovery Tests', () {
    test('defaultBaseUrl returns valid API base path', () {
      final defaultUrl = ApiService.defaultBaseUrl;
      expect(defaultUrl, isNotEmpty);
      expect(defaultUrl, endsWith('/api/v1'));
    });

    test('candidateBaseUrls contains loopback and default endpoints', () {
      final candidates = ApiService.candidateBaseUrls;
      expect(candidates, isNotEmpty);
      expect(candidates.any((url) => url.contains(ApiService.loopbackIp)), isTrue);
      expect(candidates.any((url) => url.contains(ApiService.defaultLanIp)), isTrue);
      expect(candidates.any((url) => url.contains(ApiService.emulatorIp)), isTrue);
    });

    test('setBaseUrl and resetBaseUrl update configured URL correctly', () async {
      const testCustomUrl = 'http://192.168.1.200:8000/api/v1';
      ApiService.setBaseUrl(testCustomUrl);
      expect(ApiService.defaultBaseUrl, testCustomUrl);

      await ApiService.resetBaseUrl();
      expect(ApiService.defaultBaseUrl, isNot(testCustomUrl));
    });

    test('init restores saved URL from SharedPreferences', () async {
      const savedTestUrl = 'http://192.168.1.150:8000/api/v1';
      SharedPreferences.setMockInitialValues({
        ApiService.customUrlKey: savedTestUrl,
      });

      await ApiService.init();
      expect(ApiService.defaultBaseUrl, savedTestUrl);
    });

    test('explicitBaseUrl passed in constructor is preserved', () {
      const explicitUrl = 'http://127.0.0.1:9999/api/v1';
      final service = ApiService(baseUrl: explicitUrl);
      expect(service.explicitBaseUrl, explicitUrl);
      expect(service.baseUrl, explicitUrl);
    });
  });
}


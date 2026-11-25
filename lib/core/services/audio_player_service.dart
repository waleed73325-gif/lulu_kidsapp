import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../network/api_service.dart';
import '../../features/lessons/models/lesson_model.dart';

/// خدمة تشغيل الصوتيات المخصصة والمرفوعة من لوحة التحكم (Cloud Audio Service)
/// تتيح لإدارة النظام رفع وتحديث أصوات الدروس والأصوات التحفيزية وتشغيلها مباشرة في التطبيق
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  AudioPlayer? _player;
  bool _isPlaying = false;
  bool isTesting = false;

  final Map<String, String> _motivationalSounds = {};

  VoidCallback? onAudioStarted;
  VoidCallback? onAudioCompleted;

  bool get isPlaying => _isPlaying;

  AudioPlayerService._internal();

  Future<AudioPlayer?> _initPlayer() async {
    if (isTesting) return null;
    if (_player != null) return _player;

    try {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);

      player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.playing) {
          _isPlaying = true;
          onAudioStarted?.call();
        } else if (state == PlayerState.completed || state == PlayerState.stopped) {
          _isPlaying = false;
          onAudioCompleted?.call();
        }
      });

      _player = player;
      return _player;
    } catch (e) {
      debugPrint('AudioPlayer init info: $e');
      return null;
    }
  }

  /// تحويل أي رابط نسبي أو مسار تخزين إلى رابط تشغيل كامل
  String resolveAudioUrl(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }

    final baseUrl = ApiService().baseUrl;
    final uri = Uri.parse(baseUrl);
    final hostOnly = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';

    final cleanPath = pathOrUrl.startsWith('/') ? pathOrUrl : '/$pathOrUrl';
    if (cleanPath.startsWith('/storage/')) {
      return '$hostOnly$cleanPath';
    }

    return '$hostOnly/storage$cleanPath';
  }

  /// تشغيل ملف صوتي من رابط عبر الإنترنت (Streaming)
  Future<void> playUrl(String rawUrl) async {
    if (rawUrl.trim().isEmpty) return;

    if (isTesting) {
      _isPlaying = true;
      onAudioStarted?.call();
      _isPlaying = false;
      onAudioCompleted?.call();
      return;
    }

    try {
      await stop();
      final player = await _initPlayer();
      if (player == null) {
        throw Exception('AudioPlayer is not available');
      }

      final resolvedUrl = resolveAudioUrl(rawUrl);
      debugPrint('🎵 [AudioPlayerService] جاري تشغيل المقطع: $resolvedUrl');

      _isPlaying = true;
      onAudioStarted?.call();
      await player.play(UrlSource(resolvedUrl));
    } catch (e) {
      debugPrint('⚠️ [AudioPlayerService] تعذر تشغيل المقطع الصوتي ($rawUrl): $e');
      _isPlaying = false;
      onAudioCompleted?.call();
    }
  }

  /// تشغيل رابط صوتي مباشر (Alias)
  Future<void> playAudioUrl(String rawUrl) => playUrl(rawUrl);

  /// تشغيل المقطع الصوتي المرفوع للدرس من لوحة التحكم
  Future<void> playLessonAudio(Lesson lesson) async {
    final audioUrl = lesson.audioUrl;
    if (audioUrl == null || audioUrl.trim().isEmpty) {
      debugPrint('ℹ️ [AudioPlayerService] لا يوجد مقطع صوتي مخصص مرفوع للدرس: "${lesson.title}"');
      return;
    }

    await playUrl(audioUrl);
  }

  /// تحميل روابط الأصوات التحفيزية المرفوعة من لوحة التحكم
  Future<void> loadMotivationalSounds([ApiService? apiService]) async {
    if (isTesting) return;

    final service = apiService ?? ApiService();
    try {
      final response = await service.getMotivationalSounds();
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map) {
          _motivationalSounds.clear();
          data.forEach((key, val) {
            if (val is Map && val['audio_url'] != null) {
              _motivationalSounds[key.toString()] = val['audio_url'].toString();
            } else if (val is String && val.isNotEmpty) {
              _motivationalSounds[key.toString()] = val;
            }
          });
          debugPrint('✅ [AudioPlayerService] تم تحميل الأصوات التحفيزية من الخادم: ${_motivationalSounds.keys.toList()}');
        }
      }
    } catch (e) {
      debugPrint('AudioPlayerService loadMotivationalSounds notice: $e');
    }
  }

  /// تشغيل صوت تحفيزي مرفوع من لوحة التحكم (مثل: stars_reward, cheer, correct_answer, welcome)
  Future<void> playMotivationalSound(String soundKey) async {
    final soundUrl = _motivationalSounds[soundKey];
    if (soundUrl != null && soundUrl.isNotEmpty) {
      await playUrl(soundUrl);
    } else {
      debugPrint('ℹ️ [AudioPlayerService] لا يوجد صوت تحفيزي مرفوع للحدث: "$soundKey"');
    }
  }

  /// إيقاف الصوت الحالي
  Future<void> stop() async {
    if (isTesting) {
      _isPlaying = false;
      onAudioCompleted?.call();
      return;
    }

    try {
      await _player?.stop();
      _isPlaying = false;
      onAudioCompleted?.call();
    } catch (_) {}
  }
}

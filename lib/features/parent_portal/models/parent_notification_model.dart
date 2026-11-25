import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ParentNotificationModel {
  final int id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const ParentNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory ParentNotificationModel.fromJson(Map<String, dynamic> json) {
    return ParentNotificationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
    );
  }

  ParentNotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return ParentNotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// أيقونة الإشعار المخصصة حسب نوع الحدث
  IconData get icon {
    switch (type) {
      case 'subscription_approved':
        return Icons.verified_user_rounded;
      case 'subscription_rejected':
        return Icons.error_outline_rounded;
      case 'payment_pending':
        return Icons.hourglass_top_rounded;
      case 'welcome':
        return Icons.celebration_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'offer':
        return Icons.local_offer_rounded;
      case 'update':
        return Icons.auto_awesome_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  /// اللون الرئيسي لأيقونة الإشعار
  Color get color {
    switch (type) {
      case 'subscription_approved':
        return AppColors.mintGreen;
      case 'subscription_rejected':
        return const Color(0xFFE74C3C);
      case 'payment_pending':
        return const Color(0xFFF39C12);
      case 'welcome':
        return AppColors.primary;
      case 'announcement':
        return AppColors.primary;
      case 'offer':
        return AppColors.goldenStar;
      case 'update':
        return AppColors.mintGreen;
      case 'alert':
        return AppColors.playfulCoral;
      default:
        return AppColors.skyBlue;
    }
  }

  /// لون الخلفية الخفيفة لبطاقة أو أيقونة الإشعار
  Color get bgColor {
    return color.withValues(alpha: 0.12);
  }

  /// نص توضيحي لنوع الإشعار
  String get typeLabel {
    switch (type) {
      case 'subscription_approved':
        return 'تم التفعيل ✅';
      case 'subscription_rejected':
        return 'تنبيه دفع ⚠️';
      case 'payment_pending':
        return 'قيد التدقيق ⏳';
      case 'welcome':
        return 'ترحيب 🐰';
      case 'announcement':
        return 'تعميم عام 📢';
      case 'offer':
        return 'عرض خاص 🎁';
      case 'update':
        return 'تحديث جديد ✨';
      case 'alert':
        return 'تنبيه هام ⚠️';
      default:
        return 'إشعار عام 🔔';
    }
  }

  /// تنسيق الوقت النسبي باللغة العربية
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      if (mins == 1) return 'منذ دقيقة';
      if (mins == 2) return 'منذ دقيقتين';
      if (mins <= 10) return 'منذ $mins دقائق';
      return 'منذ $mins دقيقة';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      if (hours == 1) return 'منذ ساعة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours <= 10) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'أمس';
      if (days == 2) return 'منذ يومين';
      return 'منذ $days أيام';
    } else {
      return '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}';
    }
  }
}

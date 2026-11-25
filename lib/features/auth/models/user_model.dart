class ChildModel {
  final int id;
  final String nickname;
  final int birthYear;
  final String avatarId;
  final int starsCount;
  final List<String> completedLessons;

  const ChildModel({
    required this.id,
    required this.nickname,
    required this.birthYear,
    required this.avatarId,
    this.starsCount = 12,
    this.completedLessons = const ['let_1', 'num_1'],
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    List<String> lessons = ['let_1', 'num_1'];
    if (json['completed_lessons'] is List) {
      lessons = (json['completed_lessons'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return ChildModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nickname: json['nickname']?.toString() ?? 'البطل الصغير',
      birthYear: json['birth_year'] is int ? json['birth_year'] as int : 2021,
      avatarId: json['avatar_id']?.toString() ?? 'rabbit_lulu',
      starsCount: json['stars_count'] is int
          ? json['stars_count'] as int
          : int.tryParse(json['stars_count']?.toString() ?? '12') ?? 12,
      completedLessons: lessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'birth_year': birthYear,
      'avatar_id': avatarId,
      'stars_count': starsCount,
      'completed_lessons': completedLessons,
    };
  }

  ChildModel copyWith({
    int? id,
    String? nickname,
    int? birthYear,
    String? avatarId,
    int? starsCount,
    List<String>? completedLessons,
  }) {
    return ChildModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      birthYear: birthYear ?? this.birthYear,
      avatarId: avatarId ?? this.avatarId,
      starsCount: starsCount ?? this.starsCount,
      completedLessons: completedLessons ?? this.completedLessons,
    );
  }
}

class ParentUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool hasActiveSubscription;
  final List<ChildModel> children;

  const ParentUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.hasActiveSubscription = false,
    this.children = const [],
  });

  factory ParentUser.fromJson(Map<String, dynamic> json, {bool? hasSubscription}) {
    List<ChildModel> childList = [];
    if (json['children'] is List) {
      childList = (json['children'] as List)
          .map((c) => ChildModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return ParentUser(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'parent',
      hasActiveSubscription: hasSubscription ?? (json['has_active_subscription'] == true),
      children: childList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'has_active_subscription': hasActiveSubscription,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  ParentUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? hasActiveSubscription,
    List<ChildModel>? children,
  }) {
    return ParentUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      children: children ?? this.children,
    );
  }
}


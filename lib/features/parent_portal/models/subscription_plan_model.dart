class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final int durationDays;
  final double price;
  final String currency;
  final String? description;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.durationDays,
    required this.price,
    this.currency = 'SAR',
    this.description,
    this.isActive = true,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? 'باقة لولو',
      slug: json['slug']?.toString() ?? 'plan',
      durationDays: json['duration_days'] is int
          ? json['duration_days'] as int
          : int.tryParse(json['duration_days']?.toString() ?? '30') ?? 30,
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'SAR',
      description: json['description']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'duration_days': durationDays,
      'price': price,
      'currency': currency,
      'description': description,
      'is_active': isActive,
    };
  }

  String get formattedPrice {
    final cur = (currency == 'SAR') ? 'ر.س' : currency;
    if (price == price.roundToDouble()) {
      return '${price.toInt()} $cur';
    }
    return '${price.toStringAsFixed(1)} $cur';
  }

  bool get isBestValue => durationDays >= 365 || slug.contains('1y') || slug.contains('annual');
}

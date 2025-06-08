// Models for advanced product features

class CompetitorPrice {
  final String store;
  final double price;
  final String currency;
  final DateTime lastUpdated;
  final String url;
  final bool isAvailable;

  CompetitorPrice({
    required this.store,
    required this.price,
    required this.currency,
    required this.lastUpdated,
    required this.url,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'store': store,
      'price': price,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
      'url': url,
      'isAvailable': isAvailable,
    };
  }

  factory CompetitorPrice.fromJson(Map<String, dynamic> json) {
    return CompetitorPrice(
      store: json['store'],
      price: json['price']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      lastUpdated: DateTime.parse(json['lastUpdated']),
      url: json['url'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class Coupon {
  final String id;
  final String code;
  final String description;
  final double discountValue;
  final DiscountType discountType;
  final DateTime expiryDate;
  final bool isValid;
  final String store;
  final double? minimumPurchase;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountValue,
    required this.discountType,
    required this.expiryDate,
    this.isValid = true,
    required this.store,
    this.minimumPurchase,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discountValue': discountValue,
      'discountType': discountType.toString(),
      'expiryDate': expiryDate.toIso8601String(),
      'isValid': isValid,
      'store': store,
      'minimumPurchase': minimumPurchase,
    };
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      discountValue: json['discountValue']?.toDouble() ?? 0.0,
      discountType: DiscountType.values.firstWhere(
        (e) => e.toString() == json['discountType'],
        orElse: () => DiscountType.percentage,
      ),
      expiryDate: DateTime.parse(json['expiryDate']),
      isValid: json['isValid'] ?? true,
      store: json['store'],
      minimumPurchase: json['minimumPurchase']?.toDouble(),
    );
  }
}

enum DiscountType { percentage, fixed, freeShipping }

class ProductReviews {
  final double averageRating;
  final int totalReviews;
  final String reviewSummary;
  final List<ReviewHighlight> highlights;
  final DateTime lastUpdated;

  ProductReviews({
    required this.averageRating,
    required this.totalReviews,
    required this.reviewSummary,
    required this.highlights,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'reviewSummary': reviewSummary,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ProductReviews.fromJson(Map<String, dynamic> json) {
    return ProductReviews(
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      reviewSummary: json['reviewSummary'] ?? '',
      highlights: (json['highlights'] as List?)
          ?.map((h) => ReviewHighlight.fromJson(h))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class ReviewHighlight {
  final String aspect;
  final double score;
  final String summary;

  ReviewHighlight({
    required this.aspect,
    required this.score,
    required this.summary,
  });

  Map<String, dynamic> toJson() {
    return {
      'aspect': aspect,
      'score': score,
      'summary': summary,
    };
  }

  factory ReviewHighlight.fromJson(Map<String, dynamic> json) {
    return ReviewHighlight(
      aspect: json['aspect'],
      score: json['score']?.toDouble() ?? 0.0,
      summary: json['summary'],
    );
  }
}

class ShippingInfo {
  final double cost;
  final String currency;
  final int estimatedDays;
  final bool isFreeShipping;
  final double? freeShippingThreshold;
  final List<String> availableMethods;
  final String carrier;

  ShippingInfo({
    required this.cost,
    required this.currency,
    required this.estimatedDays,
    this.isFreeShipping = false,
    this.freeShippingThreshold,
    this.availableMethods = const [],
    required this.carrier,
  });

  Map<String, dynamic> toJson() {
    return {
      'cost': cost,
      'currency': currency,
      'estimatedDays': estimatedDays,
      'isFreeShipping': isFreeShipping,
      'freeShippingThreshold': freeShippingThreshold,
      'availableMethods': availableMethods,
      'carrier': carrier,
    };
  }

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(
      cost: json['cost']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      estimatedDays: json['estimatedDays'] ?? 7,
      isFreeShipping: json['isFreeShipping'] ?? false,
      freeShippingThreshold: json['freeShippingThreshold']?.toDouble(),
      availableMethods: List<String>.from(json['availableMethods'] ?? []),
      carrier: json['carrier'] ?? '',
    );
  }
}

class PriceChangeNotification {
  final bool alertOnAnyDecrease;
  final bool alertOnTargetReached;
  final bool alertOnStockChange;
  final bool alertOnCoupons;
  final double? decreaseThreshold; // Percentage
  final List<String> alertTimes; // Times of day to check
  final bool emailNotifications;
  final bool pushNotifications;

  PriceChangeNotification({
    this.alertOnAnyDecrease = true,
    this.alertOnTargetReached = true,
    this.alertOnStockChange = false,
    this.alertOnCoupons = false,
    this.decreaseThreshold,
    this.alertTimes = const ['09:00', '18:00'],
    this.emailNotifications = false,
    this.pushNotifications = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'alertOnAnyDecrease': alertOnAnyDecrease,
      'alertOnTargetReached': alertOnTargetReached,
      'alertOnStockChange': alertOnStockChange,
      'alertOnCoupons': alertOnCoupons,
      'decreaseThreshold': decreaseThreshold,
      'alertTimes': alertTimes,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }

  factory PriceChangeNotification.fromJson(Map<String, dynamic> json) {
    return PriceChangeNotification(
      alertOnAnyDecrease: json['alertOnAnyDecrease'] ?? true,
      alertOnTargetReached: json['alertOnTargetReached'] ?? true,
      alertOnStockChange: json['alertOnStockChange'] ?? false,
      alertOnCoupons: json['alertOnCoupons'] ?? false,
      decreaseThreshold: json['decreaseThreshold']?.toDouble(),
      alertTimes: List<String>.from(json['alertTimes'] ?? ['09:00', '18:00']),
      emailNotifications: json['emailNotifications'] ?? false,
      pushNotifications: json['pushNotifications'] ?? true,
    );
  }
}

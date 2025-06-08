import 'advanced_models.dart';

class Product {
  final String id;
  final String name;
  final String url;
  final String? description;
  final String? imageUrl;
  final String category;
  final double currentPrice;
  final double? targetPrice;
  final String currency;
  final bool isInWishlist;
  final bool hasPriceAlert;
  final DateTime addedAt;
  final DateTime lastUpdated;
  final List<PriceHistory> priceHistory;
  final String store;
  final bool isAvailable;
  final double? originalPrice;
  
  // New advanced features
  final bool hasStockAlert;
  final int? stockQuantity;
  final List<String> similarProducts;
  final List<CompetitorPrice> competitorPrices;
  final List<Coupon> availableCoupons;
  final ProductReviews? reviews;
  final List<String> alternatives;
  final ShippingInfo? shipping;
  final bool isLinkedToAccount;
  final String? accountEmail;
  final double? aiPredictedPrice;
  final DateTime? aiPredictionDate;
  final PriceChangeNotification? priceNotificationSettings;

  Product({
    required this.id,
    required this.name,
    required this.url,
    this.description,
    this.imageUrl,
    required this.category,
    required this.currentPrice,
    this.targetPrice,
    this.currency = 'USD',
    this.isInWishlist = false,
    this.hasPriceAlert = false,
    required this.addedAt,
    required this.lastUpdated,
    this.priceHistory = const [],
    required this.store,
    this.isAvailable = true,
    this.originalPrice,
    // New features with defaults
    this.hasStockAlert = false,
    this.stockQuantity,
    this.similarProducts = const [],
    this.competitorPrices = const [],
    this.availableCoupons = const [],
    this.reviews,
    this.alternatives = const [],
    this.shipping,
    this.isLinkedToAccount = false,
    this.accountEmail,
    this.aiPredictedPrice,
    this.aiPredictionDate,
    this.priceNotificationSettings,
  });

  // Computed properties
  double? get discountPercentage {
    if (originalPrice == null || originalPrice! <= currentPrice) return null;
    return ((originalPrice! - currentPrice) / originalPrice!) * 100;
  }

  bool get isPriceDropped {
    if (priceHistory.length < 2) return false;
    return currentPrice < priceHistory[priceHistory.length - 2].price;
  }

  bool get isTargetPriceMet {
    if (targetPrice == null) return false;
    return currentPrice <= targetPrice!;
  }

  bool get isOutOfStock {
    return !isAvailable || (stockQuantity != null && stockQuantity! <= 0);
  }

  bool get hasActiveCoupons {
    return availableCoupons.isNotEmpty && 
           availableCoupons.any((coupon) => coupon.isValid && 
           coupon.expiryDate.isAfter(DateTime.now()));
  }

  double? get bestCompetitorPrice {
    if (competitorPrices.isEmpty) return null;
    return competitorPrices
        .where((cp) => cp.isAvailable)
        .map((cp) => cp.price)
        .reduce((a, b) => a < b ? a : b);
  }

  bool get hasBetterPriceElsewhere {
    final bestPrice = bestCompetitorPrice;
    return bestPrice != null && bestPrice < currentPrice;
  }

  Product copyWith({
    String? id,
    String? name,
    String? url,
    String? description,
    String? imageUrl,
    String? category,
    double? currentPrice,
    double? targetPrice,
    String? currency,
    bool? isInWishlist,
    bool? hasPriceAlert,
    DateTime? addedAt,
    DateTime? lastUpdated,
    List<PriceHistory>? priceHistory,
    String? store,
    bool? isAvailable,
    double? originalPrice,
    // New advanced features
    bool? hasStockAlert,
    int? stockQuantity,
    List<String>? similarProducts,
    List<CompetitorPrice>? competitorPrices,
    List<Coupon>? availableCoupons,
    ProductReviews? reviews,
    List<String>? alternatives,
    ShippingInfo? shipping,
    bool? isLinkedToAccount,
    String? accountEmail,
    double? aiPredictedPrice,
    DateTime? aiPredictionDate,
    PriceChangeNotification? priceNotificationSettings,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      currentPrice: currentPrice ?? this.currentPrice,
      targetPrice: targetPrice ?? this.targetPrice,
      currency: currency ?? this.currency,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      hasPriceAlert: hasPriceAlert ?? this.hasPriceAlert,
      addedAt: addedAt ?? this.addedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      priceHistory: priceHistory ?? this.priceHistory,
      store: store ?? this.store,
      isAvailable: isAvailable ?? this.isAvailable,
      originalPrice: originalPrice ?? this.originalPrice,
      hasStockAlert: hasStockAlert ?? this.hasStockAlert,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      similarProducts: similarProducts ?? this.similarProducts,
      competitorPrices: competitorPrices ?? this.competitorPrices,
      availableCoupons: availableCoupons ?? this.availableCoupons,
      reviews: reviews ?? this.reviews,
      alternatives: alternatives ?? this.alternatives,
      shipping: shipping ?? this.shipping,
      isLinkedToAccount: isLinkedToAccount ?? this.isLinkedToAccount,
      accountEmail: accountEmail ?? this.accountEmail,
      aiPredictedPrice: aiPredictedPrice ?? this.aiPredictedPrice,
      aiPredictionDate: aiPredictionDate ?? this.aiPredictionDate,
      priceNotificationSettings: priceNotificationSettings ?? this.priceNotificationSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'currentPrice': currentPrice,
      'targetPrice': targetPrice,
      'currency': currency,
      'isInWishlist': isInWishlist,
      'hasPriceAlert': hasPriceAlert,
      'addedAt': addedAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'priceHistory': priceHistory.map((ph) => ph.toJson()).toList(),
      'store': store,
      'isAvailable': isAvailable,
      'originalPrice': originalPrice,
      // New advanced features
      'hasStockAlert': hasStockAlert,
      'stockQuantity': stockQuantity,
      'similarProducts': similarProducts,
      'competitorPrices': competitorPrices.map((cp) => cp.toJson()).toList(),
      'availableCoupons': availableCoupons.map((c) => c.toJson()).toList(),
      'reviews': reviews?.toJson(),
      'alternatives': alternatives,
      'shipping': shipping?.toJson(),
      'isLinkedToAccount': isLinkedToAccount,
      'accountEmail': accountEmail,
      'aiPredictedPrice': aiPredictedPrice,
      'aiPredictionDate': aiPredictionDate?.toIso8601String(),
      'priceNotificationSettings': priceNotificationSettings?.toJson(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      currentPrice: json['currentPrice']?.toDouble() ?? 0.0,
      targetPrice: json['targetPrice']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      isInWishlist: json['isInWishlist'] ?? false,
      hasPriceAlert: json['hasPriceAlert'] ?? false,
      addedAt: DateTime.parse(json['addedAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      priceHistory: (json['priceHistory'] as List?)
          ?.map((ph) => PriceHistory.fromJson(ph))
          .toList() ?? [],
      store: json['store'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      originalPrice: json['originalPrice']?.toDouble(),
      // New advanced features
      hasStockAlert: json['hasStockAlert'] ?? false,
      stockQuantity: json['stockQuantity'],
      similarProducts: List<String>.from(json['similarProducts'] ?? []),
      competitorPrices: (json['competitorPrices'] as List?)
          ?.map((cp) => CompetitorPrice.fromJson(cp))
          .toList() ?? [],
      availableCoupons: (json['availableCoupons'] as List?)
          ?.map((c) => Coupon.fromJson(c))
          .toList() ?? [],
      reviews: json['reviews'] != null ? ProductReviews.fromJson(json['reviews']) : null,
      alternatives: List<String>.from(json['alternatives'] ?? []),
      shipping: json['shipping'] != null ? ShippingInfo.fromJson(json['shipping']) : null,
      isLinkedToAccount: json['isLinkedToAccount'] ?? false,
      accountEmail: json['accountEmail'],
      aiPredictedPrice: json['aiPredictedPrice']?.toDouble(),
      aiPredictionDate: json['aiPredictionDate'] != null 
          ? DateTime.parse(json['aiPredictionDate']) : null,
      priceNotificationSettings: json['priceNotificationSettings'] != null 
          ? PriceChangeNotification.fromJson(json['priceNotificationSettings']) : null,
    );
  }
}

// PriceHistory class is now defined in advanced_models.dart

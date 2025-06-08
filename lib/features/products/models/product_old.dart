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
    );
  }
}

class PriceHistory {
  final DateTime date;
  final double price;
  final bool isAvailable;

  PriceHistory({
    required this.date,
    required this.price,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'price': price,
      'isAvailable': isAvailable,
    };
  }

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      date: DateTime.parse(json['date']),
      price: json['price']?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

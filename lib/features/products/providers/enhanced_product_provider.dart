import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'dart:math';
import '../models/product.dart';
import '../models/advanced_models.dart';

class EnhancedProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  List<Product> get wishlistProducts => 
      _products.where((product) => product.isInWishlist).toList();
  List<Product> get productsWithAlerts => 
      _products.where((product) => product.hasPriceAlert).toList();
  List<Product> get outOfStockProducts => 
      _products.where((product) => product.isOutOfStock).toList();
  List<Product> get productsWithCoupons => 
      _products.where((product) => product.hasActiveCoupons).toList();
  List<Product> get productsWithBetterPrices => 
      _products.where((product) => product.hasBetterPriceElsewhere).toList();
  
  List<Product> get filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((product) => product.category == _selectedCategory).toList();
  }

  List<String> get categories {
    final categories = {'All', ..._products.map((product) => product.category)};
    return categories.toList();
  }

  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize provider
  EnhancedProductProvider() {
    loadProducts();
    _setupPeriodicPriceChecks();
  }

  // Category management
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Product management
  Future<void> addProduct(String url, String category, {String? name, double? targetPrice}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final product = await _scrapeProductInfo(url, category, name, targetPrice);
      
      // Enhance product with AI and competitor data
      final enhancedProduct = await _enhanceProduct(product);
      
      _products.add(enhancedProduct);
      
      await _saveProductsToStorage();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product> _scrapeProductInfo(String url, String category, String? name, double? targetPrice) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch product page');
      }

      final document = html_parser.parse(response.body);

      // Extract product name
      String productName = name ?? '';
      if (productName.isEmpty) {
        final nameSelectors = [
          'h1',
          '.product-title',
          '.product-name',
          '[data-testid="product-name"]',
          '.pdp-product-name',
        ];
        
        for (final selector in nameSelectors) {
          final element = document.querySelector(selector);
          if (element != null && element.text.trim().isNotEmpty) {
            productName = element.text.trim();
            break;
          }
        }
      }

      if (productName.isEmpty) {
        productName = 'Unknown Product';
      }

      // Extract current price
      double currentPrice = 0.0;
      final priceSelectors = [
        '.price',
        '.current-price',
        '.sale-price',
        '.product-price',
        '[data-testid="price"]',
      ];
      
      for (final selector in priceSelectors) {
        final elements = document.querySelectorAll(selector);
        for (final element in elements) {
          final priceText = element.text.replaceAll(RegExp(r'[^\d.]'), '');
          final price = double.tryParse(priceText);
          if (price != null && price > 0) {
            currentPrice = price;
            break;
          }
        }
        if (currentPrice > 0) break;
      }

      // Extract image
      String? imageUrl;
      final imgSelectors = [
        '.product-image img',
        '.main-image img',
        '[data-testid="product-image"] img',
        'img[alt*="product"]',
      ];
      
      for (final selector in imgSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          imageUrl = element.attributes['src'] ?? element.attributes['data-src'];
          if (imageUrl != null && imageUrl.isNotEmpty) {
            if (!imageUrl.startsWith('http')) {
              final uri = Uri.parse(url);
              imageUrl = '${uri.scheme}://${uri.host}$imageUrl';
            }
            break;
          }
        }
      }

      // Extract description
      String? description;
      final descSelectors = [
        '.product-description',
        '.description',
        '[data-testid="description"]',
        '.product-details',
      ];
      
      for (final selector in descSelectors) {
        final element = document.querySelector(selector);
        if (element != null && element.text.trim().isNotEmpty) {
          description = element.text.trim();
          if (description.length > 200) {
            description = '${description.substring(0, 200)}...';
          }
          break;
        }
      }

      // Extract stock information
      bool isAvailable = true;
      int? stockQuantity;
      final stockSelectors = [
        '.stock-status',
        '.availability',
        '[data-testid="stock"]',
      ];
      
      for (final selector in stockSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          final stockText = element.text.toLowerCase();
          if (stockText.contains('out of stock') || stockText.contains('unavailable')) {
            isAvailable = false;
          }
          // Try to extract quantity
          final quantityMatch = RegExp(r'(\d+)\s*in\s*stock').firstMatch(stockText);
          if (quantityMatch != null) {
            stockQuantity = int.tryParse(quantityMatch.group(1)!);
          }
          break;
        }
      }

      // Determine store name from URL
      final uri = Uri.parse(url);
      String store = uri.host.replaceFirst('www.', '');

      return Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: productName,
        url: url,
        description: description,
        imageUrl: imageUrl,
        category: category,
        currentPrice: currentPrice,
        targetPrice: targetPrice,
        addedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        store: store,
        isAvailable: isAvailable,
        stockQuantity: stockQuantity,
        priceHistory: [PriceHistory(
          date: DateTime.now(), 
          price: currentPrice, 
          currency: 'USD',
          store: store,
          isAvailable: isAvailable
        )],
      );
    } catch (e) {
      throw Exception('Failed to scrape product: $e');
    }
  }

  // Enhanced product with AI and competitor data
  Future<Product> _enhanceProduct(Product product) async {
    try {
      // Get similar products
      final similarProducts = await _findSimilarProducts(product);
      
      // Get competitor prices
      final competitorPrices = await _getCompetitorPrices(product);
      
      // Get available coupons
      final coupons = await _getCoupons(product);
      
      // Get AI price prediction
      final aiPrediction = await _getAIPricePrediction(product);
      
      // Get shipping info
      final shipping = await _getShippingInfo(product);
      
      // Get reviews summary
      final reviews = await _getReviewsSummary(product);

      return product.copyWith(
        similarProducts: similarProducts,
        competitorPrices: competitorPrices,
        availableCoupons: coupons,
        aiPredictedPrice: aiPrediction['price'],
        aiPredictionDate: aiPrediction['date'],
        shipping: shipping,
        reviews: reviews,
      );
    } catch (e) {
      print('Error enhancing product: $e');
      return product; // Return original product if enhancement fails
    }
  }

  Future<List<String>> _findSimilarProducts(Product product) async {
    // Mock implementation - in real app, use ML or search API
    final similar = <String>[];
    final keywords = product.name.toLowerCase().split(' ');
    
    // Simulate finding similar products
    for (int i = 0; i < 3; i++) {
      similar.add('Similar ${keywords.first} Product ${i + 1}');
    }
    
    return similar;
  }

  Future<List<CompetitorPrice>> _getCompetitorPrices(Product product) async {
    // Mock implementation - in real app, scrape competitor sites
    final competitors = <CompetitorPrice>[];
    final basePrice = product.currentPrice;
    final stores = ['Amazon', 'eBay', 'Walmart', 'Target'];
    
    for (final store in stores) {
      if (store.toLowerCase() != product.store.toLowerCase()) {
        final variation = (Random().nextDouble() - 0.5) * 0.2; // ±10% variation
        final price = basePrice * (1 + variation);
        
        competitors.add(CompetitorPrice(
          store: store,
          price: double.parse(price.toStringAsFixed(2)),
          currency: product.currency,
          lastUpdated: DateTime.now(),
          url: 'https://${store.toLowerCase()}.com/product/${product.id}',
          isAvailable: Random().nextBool(),
        ));
      }
    }
    
    return competitors;
  }

  Future<List<Coupon>> _getCoupons(Product product) async {
    // Mock implementation - in real app, scrape coupon sites
    final coupons = <Coupon>[];
    
    if (Random().nextBool()) {
      coupons.add(Coupon(
        id: 'COUPON_${DateTime.now().millisecondsSinceEpoch}',
        code: 'SAVE10',
        description: '10% off your purchase',
        discountValue: 10,
        discountType: DiscountType.percentage,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        store: product.store,
        minimumPurchase: 50,
      ));
    }
    
    return coupons;
  }

  Future<Map<String, dynamic>> _getAIPricePrediction(Product product) async {
    // Mock AI price prediction - in real app, use ML model
    final variation = (Random().nextDouble() - 0.5) * 0.15; // ±7.5% variation
    final predictedPrice = product.currentPrice * (1 + variation);
    
    return {
      'price': double.parse(predictedPrice.toStringAsFixed(2)),
      'date': DateTime.now().add(const Duration(days: 7)),
    };
  }

  Future<ShippingInfo?> _getShippingInfo(Product product) async {
    // Mock shipping info - in real app, scrape from product page
    if (Random().nextBool()) {
      return ShippingInfo(
        cost: Random().nextDouble() * 20,
        currency: product.currency,
        estimatedDays: Random().nextInt(10) + 1,
        isFreeShipping: Random().nextBool(),
        freeShippingThreshold: 35,
        availableMethods: ['Standard', 'Express', 'Overnight'],
        carrier: ['FedEx', 'UPS', 'DHL'][Random().nextInt(3)],
      );
    }
    return null;
  }

  Future<ProductReviews?> _getReviewsSummary(Product product) async {
    // Mock reviews - in real app, scrape reviews and use NLP
    if (Random().nextBool()) {
      return ProductReviews(
        averageRating: 3.0 + Random().nextDouble() * 2, // 3-5 stars
        totalReviews: Random().nextInt(1000) + 10,
        reviewSummary: 'Customers love the quality and value of this product.',
        highlights: [
          ReviewHighlight(
            aspect: 'Quality',
            score: 4.0 + Random().nextDouble(),
            summary: 'High quality materials and construction',
          ),
          ReviewHighlight(
            aspect: 'Value',
            score: 3.5 + Random().nextDouble() * 1.5,
            summary: 'Great value for the price',
          ),
        ],
        lastUpdated: DateTime.now(),
      );
    }
    return null;
  }

  // Advanced features
  Future<void> toggleStockAlert(String productId) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        hasStockAlert: !_products[index].hasStockAlert,
      );
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  Future<void> updatePriceNotificationSettings(String productId, PriceChangeNotification settings) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        priceNotificationSettings: settings,
      );
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  Future<void> linkProductToAccount(String productId, String email) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isLinkedToAccount: true,
        accountEmail: email,
      );
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  Future<void> refreshCompetitorPrices(String productId) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      final product = _products[index];
      final newCompetitorPrices = await _getCompetitorPrices(product);
      
      _products[index] = product.copyWith(
        competitorPrices: newCompetitorPrices,
      );
      
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  Future<void> refreshCoupons(String productId) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      final product = _products[index];
      final newCoupons = await _getCoupons(product);
      
      _products[index] = product.copyWith(
        availableCoupons: newCoupons,
      );
      
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  // Existing methods...
  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((product) => product.id == productId);
    await _saveProductsToStorage();
    notifyListeners();
  }

  Future<void> toggleWishlist(String productId) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isInWishlist: !_products[index].isInWishlist,
      );
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  Future<void> togglePriceAlert(String productId) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        hasPriceAlert: !_products[index].hasPriceAlert,
      );
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  Future<void> updateTargetPrice(String productId, double? targetPrice) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(targetPrice: targetPrice);
      await _saveProductsToStorage();
      notifyListeners();
    }
  }

  // Price tracking
  Future<void> refreshProduct(String productId) async {
    try {
      final index = _products.indexWhere((product) => product.id == productId);
      if (index == -1) return;

      final product = _products[index];
      final response = await http.get(Uri.parse(product.url));
      if (response.statusCode != 200) return;

      final document = html_parser.parse(response.body);
      
      // Extract current price
      double? newPrice;
      final priceSelectors = [
        '.price',
        '.current-price',
        '.sale-price',
        '.product-price',
        '[data-testid="price"]',
      ];
      
      for (final selector in priceSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          final priceText = element.text.replaceAll(RegExp(r'[^\d.]'), '');
          final price = double.tryParse(priceText);
          if (price != null && price > 0) {
            newPrice = price;
            break;
          }
        }
      }

      // Check stock status
      bool isAvailable = true;
      final stockSelectors = [
        '.stock-status',
        '.availability',
        '[data-testid="stock"]',
      ];
      
      for (final selector in stockSelectors) {
        final element = document.querySelector(selector);
        if (element != null) {
          final stockText = element.text.toLowerCase();
          if (stockText.contains('out of stock') || stockText.contains('unavailable')) {
            isAvailable = false;
            break;
          }
        }
      }

      if (newPrice != null && (newPrice != product.currentPrice || isAvailable != product.isAvailable)) {
        // Add to price history
        final newHistory = List<PriceHistory>.from(product.priceHistory)
          ..add(PriceHistory(
            date: DateTime.now(), 
            price: newPrice, 
            currency: product.currency,
            store: product.store,
            isAvailable: isAvailable
          ));

        _products[index] = product.copyWith(
          currentPrice: newPrice,
          isAvailable: isAvailable,
          lastUpdated: DateTime.now(),
          priceHistory: newHistory,
        );

        await _saveProductsToStorage();
        notifyListeners();

        // Check alerts
        if (product.hasPriceAlert && product.targetPrice != null && 
            newPrice <= product.targetPrice!) {
          _triggerPriceAlert(product, newPrice);
        }

        if (product.hasStockAlert && !product.isAvailable && isAvailable) {
          _triggerStockAlert(product);
        }
      }
    } catch (e) {
      print('Error refreshing product $productId: $e');
    }
  }

  Future<void> refreshAllProducts() async {
    _isLoading = true;
    notifyListeners();

    for (final product in _products) {
      await refreshProduct(product.id);
      await Future.delayed(const Duration(milliseconds: 500)); // Rate limiting
    }

    _isLoading = false;
    notifyListeners();
  }

  void _triggerPriceAlert(Product product, double newPrice) {
    print('Price alert: ${product.name} is now \$${newPrice.toStringAsFixed(2)}');
    // TODO: Implement notification service call
  }

  void _triggerStockAlert(Product product) {
    print('Stock alert: ${product.name} is back in stock!');
    // TODO: Implement notification service call
  }

  // Periodic price checks
  void _setupPeriodicPriceChecks() {
    // TODO: Setup periodic background checks
    // This would typically use a background service or scheduled job
  }

  // Storage management
  Future<void> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('products');

      if (productsJson != null) {
        final productsList = json.decode(productsJson) as List;
        _products = productsList.map((json) => Product.fromJson(json)).toList();
        _products.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      }

      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> _saveProductsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = json.encode(_products.map((product) => product.toJson()).toList());
      await prefs.setString('products', productsJson);
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  // Search functionality
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) =>
        product.name.toLowerCase().contains(lowercaseQuery) ||
        product.store.toLowerCase().contains(lowercaseQuery) ||
        product.category.toLowerCase().contains(lowercaseQuery) ||
        (product.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        product.alternatives.any((alt) => alt.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    _products.clear();
    _selectedCategory = 'All';
    _error = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('products');
    
    notifyListeners();
  }
}

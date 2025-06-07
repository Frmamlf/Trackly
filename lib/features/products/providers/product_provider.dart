import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
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
      _products.add(product);
      
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
      String productName = name ?? 'Unknown Product';
      final titleSelectors = [
        'h1',
        '.product-title',
        '.product-name',
        '[data-testid="product-title"]',
        'title',
      ];
      
      for (final selector in titleSelectors) {
        final element = document.querySelector(selector);
        if (element != null && element.text.trim().isNotEmpty) {
          productName = element.text.trim();
          break;
        }
      }

      // Extract price
      double currentPrice = 0.0;
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
            currentPrice = price;
            break;
          }
        }
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
        priceHistory: [PriceHistory(date: DateTime.now(), price: currentPrice)],
      );
    } catch (e) {
      throw Exception('Failed to scrape product: $e');
    }
  }

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

      if (newPrice != null && newPrice != product.currentPrice) {
        // Add to price history
        final newHistory = List<PriceHistory>.from(product.priceHistory)
          ..add(PriceHistory(date: DateTime.now(), price: newPrice));

        _products[index] = product.copyWith(
          currentPrice: newPrice,
          lastUpdated: DateTime.now(),
          priceHistory: newHistory,
        );

        await _saveProductsToStorage();
        notifyListeners();

        // Check if price alert should be triggered
        if (product.hasPriceAlert && product.targetPrice != null && 
            newPrice <= product.targetPrice!) {
          _triggerPriceAlert(product, newPrice);
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
    }

    _isLoading = false;
    notifyListeners();
  }

  void _triggerPriceAlert(Product product, double newPrice) {
    // TODO: Implement notification service call
    print('Price alert: ${product.name} is now \$${newPrice.toStringAsFixed(2)}');
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
        (product.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }
}

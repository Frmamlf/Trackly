import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingItem {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  bool isCompleted;

  TrackingItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TrackingItem.fromJson(Map<String, dynamic> json) {
    return TrackingItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class TrackingProvider extends ChangeNotifier {
  final List<TrackingItem> _items = [];
  bool _isLoading = false;

  List<TrackingItem> get items => _items;
  bool get isLoading => _isLoading;
  
  List<TrackingItem> get activeItems => _items.where((item) => !item.isCompleted).toList();
  List<TrackingItem> get completedItems => _items.where((item) => item.isCompleted).toList();

  TrackingProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList('tracking_items') ?? [];
      
      _items.clear();
      for (final jsonString in itemsJson) {
        final itemMap = Map<String, dynamic>.from(
          // Simple JSON parsing - in production, use proper JSON library
          Uri.splitQueryString(jsonString)
        );
        _items.add(TrackingItem.fromJson(itemMap));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading items: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(String title, String description) async {
    final newItem = TrackingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    _items.add(newItem);
    notifyListeners();
    await _saveItems();
  }

  Future<void> toggleItemCompletion(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isCompleted = !_items[index].isCompleted;
      if (_items[index].isCompleted) {
        _items[index] = TrackingItem(
          id: _items[index].id,
          title: _items[index].title,
          description: _items[index].description,
          createdAt: _items[index].createdAt,
          completedAt: DateTime.now(),
          isCompleted: true,
        );
      }
      notifyListeners();
      await _saveItems();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await _saveItems();
  }

  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = _items.map((item) => 
        item.toJson().entries.map((e) => '${e.key}=${e.value}').join('&')
      ).toList();
      
      await prefs.setStringList('tracking_items', itemsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving items: $e');
      }
    }
  }
}

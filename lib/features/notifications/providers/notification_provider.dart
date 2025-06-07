import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum NotificationType {
  rssNewArticle,
  productPriceAlert,
  githubNewRelease,
  githubNewIssue,
  general,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString(),
      'priority': priority.toString(),
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  NotificationType? _selectedFilter;
  bool _isLoading = false;

  // Getters
  List<NotificationItem> get notifications => _notifications;
  List<NotificationItem> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  
  List<NotificationItem> get filteredNotifications {
    if (_selectedFilter == null) {
      return _notifications;
    }
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  NotificationType? get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;

  List<NotificationType> get availableFilters {
    final types = _notifications.map((n) => n.type).toSet().toList();
    types.sort((a, b) => a.toString().compareTo(b.toString()));
    return types;
  }

  // Filter management
  void setFilter(NotificationType? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _selectedFilter = null;
    notifyListeners();
  }

  // Notification management
  Future<void> addNotification(NotificationItem notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteReadNotifications() async {
    _notifications.removeWhere((n) => n.isRead);
    await _saveNotifications();
    notifyListeners();
  }

  // Load notifications from storage
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        _notifications = decoded
            .map((item) => NotificationItem.fromJson(item))
            .toList();
        
        // Sort by creation date (newest first)
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString('notifications', notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Create specific notification types
  void createRssNotification({
    required String feedName,
    required String articleTitle,
    required String articleUrl,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Article from $feedName',
      body: articleTitle,
      type: NotificationType.rssNewArticle,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: {
        'feedName': feedName,
        'articleTitle': articleTitle,
        'articleUrl': articleUrl,
      },
    );
    addNotification(notification);
  }

  void createProductPriceAlert({
    required String productName,
    required double oldPrice,
    required double newPrice,
    required String productUrl,
  }) {
    final isDecrease = newPrice < oldPrice;
    final changePercent = ((newPrice - oldPrice) / oldPrice * 100).abs();
    
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Price Alert: $productName',
      body: 'Price ${isDecrease ? 'decreased' : 'increased'} by ${changePercent.toStringAsFixed(1)}%',
      type: NotificationType.productPriceAlert,
      priority: isDecrease ? NotificationPriority.high : NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: {
        'productName': productName,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'productUrl': productUrl,
        'isDecrease': isDecrease,
      },
    );
    addNotification(notification);
  }

  void createGitHubReleaseNotification({
    required String repositoryName,
    required String releaseName,
    required String releaseUrl,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Release: $repositoryName',
      body: releaseName,
      type: NotificationType.githubNewRelease,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: {
        'repositoryName': repositoryName,
        'releaseName': releaseName,
        'releaseUrl': releaseUrl,
      },
    );
    addNotification(notification);
  }

  void createGitHubIssueNotification({
    required String repositoryName,
    required String issueTitle,
    required String issueUrl,
    required bool isPullRequest,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New ${isPullRequest ? 'Pull Request' : 'Issue'}: $repositoryName',
      body: issueTitle,
      type: NotificationType.githubNewIssue,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: {
        'repositoryName': repositoryName,
        'issueTitle': issueTitle,
        'issueUrl': issueUrl,
        'isPullRequest': isPullRequest,
      },
    );
    addNotification(notification);
  }

  // Search functionality
  List<NotificationItem> searchNotifications(String query) {
    if (query.isEmpty) return filteredNotifications;
    
    final lowercaseQuery = query.toLowerCase();
    return filteredNotifications.where((notification) =>
        notification.title.toLowerCase().contains(lowercaseQuery) ||
        notification.body.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Statistics
  Map<NotificationType, int> getNotificationCounts() {
    final counts = <NotificationType, int>{};
    for (final notification in _notifications) {
      counts[notification.type] = (counts[notification.type] ?? 0) + 1;
    }
    return counts;
  }

  Map<NotificationType, int> getUnreadNotificationCounts() {
    final counts = <NotificationType, int>{};
    for (final notification in unreadNotifications) {
      counts[notification.type] = (counts[notification.type] ?? 0) + 1;
    }
    return counts;
  }
}

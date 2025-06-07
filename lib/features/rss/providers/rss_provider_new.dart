import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import '../models/rss_feed.dart';

class RssProvider extends ChangeNotifier {
  List<RssFeed> _feeds = [];
  List<RssArticle> _articles = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RssFeed> get feeds => _feeds;
  List<RssArticle> get articles => _articles;
  List<RssArticle> get favoriteArticles => 
      _articles.where((article) => article.isFavorite).toList();
  List<RssArticle> get unreadArticles => 
      _articles.where((article) => !article.isRead).toList();
  
  List<RssArticle> get filteredArticles {
    if (_selectedCategory == 'All') {
      return _articles;
    }
    final feedIds = _feeds
        .where((feed) => feed.category == _selectedCategory)
        .map((feed) => feed.id)
        .toSet();
    return _articles.where((article) => feedIds.contains(article.feedId)).toList();
  }

  List<String> get categories {
    final categories = {'All', ..._feeds.map((feed) => feed.category)};
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

  // Feed management
  Future<void> addFeed(String url, String category, {String? title}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final feed = await _fetchFeedInfo(url, category, title);
      _feeds.add(feed);
      
      await _saveFeedsToStorage();
      await refreshFeed(feed.id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RssFeed> _fetchFeedInfo(String url, String category, String? title) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch RSS feed');
    }

    final document = XmlDocument.parse(response.body);
    final channel = document.findAllElements('channel').first;
    
    final feedTitle = title ?? 
        channel.findElements('title').first.text;
    final description = channel.findElements('description').first.text;
    final imageUrl = channel.findElements('image').isNotEmpty
        ? channel.findElements('image').first.findElements('url').first.text
        : null;

    return RssFeed(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: feedTitle,
      url: url,
      description: description,
      imageUrl: imageUrl,
      category: category,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> deleteFeed(String feedId) async {
    _feeds.removeWhere((feed) => feed.id == feedId);
    _articles.removeWhere((article) => article.feedId == feedId);
    await _saveFeedsToStorage();
    await _saveArticlesToStorage();
    notifyListeners();
  }

  Future<void> toggleFeedActive(String feedId) async {
    final feedIndex = _feeds.indexWhere((feed) => feed.id == feedId);
    if (feedIndex != -1) {
      _feeds[feedIndex] = _feeds[feedIndex].copyWith(
        isActive: !_feeds[feedIndex].isActive,
      );
      await _saveFeedsToStorage();
      notifyListeners();
    }
  }

  // Article management
  Future<void> refreshFeed(String feedId) async {
    try {
      final feed = _feeds.firstWhere((f) => f.id == feedId);
      if (!feed.isActive) return;

      final response = await http.get(Uri.parse(feed.url));
      if (response.statusCode != 200) return;

      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      final newArticles = <RssArticle>[];
      for (final item in items) {
        final article = _parseArticleFromXml(item, feedId);
        
        // Check if article already exists
        if (!_articles.any((a) => a.link == article.link)) {
          newArticles.add(article);
        }
      }

      _articles.addAll(newArticles);
      _articles.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

      // Update feed last updated time
      final feedIndex = _feeds.indexWhere((f) => f.id == feedId);
      if (feedIndex != -1) {
        _feeds[feedIndex] = _feeds[feedIndex].copyWith(
          lastUpdated: DateTime.now(),
          unreadCount: _articles.where((a) => a.feedId == feedId && !a.isRead).length,
        );
      }

      await _saveFeedsToStorage();
      await _saveArticlesToStorage();
      notifyListeners();
    } catch (e) {
      print('Error refreshing feed $feedId: $e');
    }
  }

  RssArticle _parseArticleFromXml(XmlElement item, String feedId) {
    final title = item.findElements('title').first.text;
    final link = item.findElements('link').first.text;
    final description = item.findElements('description').isNotEmpty
        ? item.findElements('description').first.text
        : null;
    final author = item.findElements('author').isNotEmpty
        ? item.findElements('author').first.text
        : null;
    final pubDate = item.findElements('pubDate').isNotEmpty
        ? DateTime.tryParse(item.findElements('pubDate').first.text) ?? DateTime.now()
        : DateTime.now();
    
    // Extract image from content
    String? imageUrl;
    final enclosure = item.findElements('enclosure').where((e) => 
        e.getAttribute('type')?.startsWith('image/') == true);
    if (enclosure.isNotEmpty) {
      imageUrl = enclosure.first.getAttribute('url');
    }

    final categories = item.findElements('category').map((e) => e.text).toList();

    return RssArticle(
      id: '${feedId}_${link.hashCode}',
      feedId: feedId,
      title: title,
      description: description,
      author: author,
      link: link,
      publishedDate: pubDate,
      imageUrl: imageUrl,
      categories: categories,
    );
  }

  Future<void> refreshAllFeeds() async {
    _isLoading = true;
    notifyListeners();

    for (final feed in _feeds.where((f) => f.isActive)) {
      await refreshFeed(feed.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(String articleId) async {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isRead: true);
      
      // Update feed unread count
      final feedIndex = _feeds.indexWhere((f) => f.id == _articles[index].feedId);
      if (feedIndex != -1) {
        _feeds[feedIndex] = _feeds[feedIndex].copyWith(
          unreadCount: _articles.where((a) => 
              a.feedId == _feeds[feedIndex].id && !a.isRead).length,
        );
      }
      
      await _saveArticlesToStorage();
      await _saveFeedsToStorage();
      notifyListeners();
    }
  }

  void toggleArticleFavorite(String articleId) async {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        isFavorite: !_articles[index].isFavorite,
      );
      await _saveArticlesToStorage();
      notifyListeners();
    }
  }

  void toggleArticleBookmark(String articleId) async {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        isBookmarked: !_articles[index].isBookmarked,
      );
      await _saveArticlesToStorage();
      notifyListeners();
    }
  }

  // Storage management
  Future<void> loadFeeds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedsJson = prefs.getString('rss_feeds');
      final articlesJson = prefs.getString('rss_articles');

      if (feedsJson != null) {
        final feedsList = json.decode(feedsJson) as List;
        _feeds = feedsList.map((json) => RssFeed.fromJson(json)).toList();
      }

      if (articlesJson != null) {
        final articlesList = json.decode(articlesJson) as List;
        _articles = articlesList.map((json) => RssArticle.fromJson(json)).toList();
        _articles.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
      }

      notifyListeners();
    } catch (e) {
      print('Error loading feeds: $e');
    }
  }

  Future<void> _saveFeedsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedsJson = json.encode(_feeds.map((feed) => feed.toJson()).toList());
      await prefs.setString('rss_feeds', feedsJson);
    } catch (e) {
      print('Error saving feeds: $e');
    }
  }

  Future<void> _saveArticlesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articlesJson = json.encode(_articles.map((article) => article.toJson()).toList());
      await prefs.setString('rss_articles', articlesJson);
    } catch (e) {
      print('Error saving articles: $e');
    }
  }

  // Search functionality
  List<RssArticle> searchArticles(String query) {
    if (query.isEmpty) return _articles;
    
    final lowercaseQuery = query.toLowerCase();
    return _articles.where((article) =>
        article.title.toLowerCase().contains(lowercaseQuery) ||
        (article.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        (article.author?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  List<RssFeed> searchFeeds(String query) {
    if (query.isEmpty) return _feeds;
    
    final lowercaseQuery = query.toLowerCase();
    return _feeds.where((feed) =>
        feed.title.toLowerCase().contains(lowercaseQuery) ||
        feed.description.toLowerCase().contains(lowercaseQuery) ||
        feed.category.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}

extension on String? {
  toLowerCase() {}
}

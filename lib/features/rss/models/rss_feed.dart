class RssFeed {
  final String id;
  final String title;
  final String url;
  final String? description;
  final String? imageUrl;
  final String category;
  final bool isActive;
  final DateTime lastUpdated;
  final int unreadCount;
  final List<String> tags;

  RssFeed({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.imageUrl,
    required this.category,
    this.isActive = true,
    required this.lastUpdated,
    this.unreadCount = 0,
    this.tags = const [],
  });

  RssFeed copyWith({
    String? id,
    String? title,
    String? url,
    String? description,
    String? imageUrl,
    String? category,
    bool? isActive,
    DateTime? lastUpdated,
    int? unreadCount,
    List<String>? tags,
  }) {
    return RssFeed(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      unreadCount: unreadCount ?? this.unreadCount,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'isActive': isActive,
      'lastUpdated': lastUpdated.toIso8601String(),
      'unreadCount': unreadCount,
      'tags': tags,
    };
  }

  factory RssFeed.fromJson(Map<String, dynamic> json) {
    return RssFeed(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      isActive: json['isActive'] ?? true,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      unreadCount: json['unreadCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

class RssArticle {
  final String id;
  final String feedId;
  final String title;
  final String? description;
  final String? content;
  final String? author;
  final String link;
  final DateTime publishedDate;
  final String? imageUrl;
  final List<String> categories;
  final bool isRead;
  final bool isFavorite;
  final bool isBookmarked;

  RssArticle({
    required this.id,
    required this.feedId,
    required this.title,
    this.description,
    this.content,
    this.author,
    required this.link,
    required this.publishedDate,
    this.imageUrl,
    this.categories = const [],
    this.isRead = false,
    this.isFavorite = false,
    this.isBookmarked = false,
  });

  RssArticle copyWith({
    String? id,
    String? feedId,
    String? title,
    String? description,
    String? content,
    String? author,
    String? link,
    DateTime? publishedDate,
    String? imageUrl,
    List<String>? categories,
    bool? isRead,
    bool? isFavorite,
    bool? isBookmarked,
  }) {
    return RssArticle(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      link: link ?? this.link,
      publishedDate: publishedDate ?? this.publishedDate,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      isRead: isRead ?? this.isRead,
      isFavorite: isFavorite ?? this.isFavorite,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feedId': feedId,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'link': link,
      'publishedDate': publishedDate.toIso8601String(),
      'imageUrl': imageUrl,
      'categories': categories,
      'isRead': isRead,
      'isFavorite': isFavorite,
      'isBookmarked': isBookmarked,
    };
  }

  factory RssArticle.fromJson(Map<String, dynamic> json) {
    return RssArticle(
      id: json['id'],
      feedId: json['feedId'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      author: json['author'],
      link: json['link'],
      publishedDate: DateTime.parse(json['publishedDate']),
      imageUrl: json['imageUrl'],
      categories: List<String>.from(json['categories'] ?? []),
      isRead: json['isRead'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }
}

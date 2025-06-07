class GitHubRepository {
  final String id;
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final int openIssuesCount;
  final String? avatarUrl;
  final String owner;
  final bool isPrivate;
  final bool isWatched;
  final bool isStarred;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pushedAt;
  final String? defaultBranch;
  final List<String> topics;

  GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.openIssuesCount,
    this.avatarUrl,
    required this.owner,
    this.isPrivate = false,
    this.isWatched = false,
    this.isStarred = false,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.pushedAt,
    this.defaultBranch,
    this.topics = const [],
  });

  GitHubRepository copyWith({
    String? id,
    String? name,
    String? fullName,
    String? description,
    String? htmlUrl,
    String? language,
    int? stargazersCount,
    int? forksCount,
    int? openIssuesCount,
    String? avatarUrl,
    String? owner,
    bool? isPrivate,
    bool? isWatched,
    bool? isStarred,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? pushedAt,
    String? defaultBranch,
    List<String>? topics,
  }) {
    return GitHubRepository(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      description: description ?? this.description,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      language: language ?? this.language,
      stargazersCount: stargazersCount ?? this.stargazersCount,
      forksCount: forksCount ?? this.forksCount,
      openIssuesCount: openIssuesCount ?? this.openIssuesCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      owner: owner ?? this.owner,
      isPrivate: isPrivate ?? this.isPrivate,
      isWatched: isWatched ?? this.isWatched,
      isStarred: isStarred ?? this.isStarred,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pushedAt: pushedAt ?? this.pushedAt,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'description': description,
      'htmlUrl': htmlUrl,
      'language': language,
      'stargazersCount': stargazersCount,
      'forksCount': forksCount,
      'openIssuesCount': openIssuesCount,
      'avatarUrl': avatarUrl,
      'owner': owner,
      'isPrivate': isPrivate,
      'isWatched': isWatched,
      'isStarred': isStarred,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pushedAt': pushedAt?.toIso8601String(),
      'defaultBranch': defaultBranch,
      'topics': topics,
    };
  }

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      id: json['id'].toString(),
      name: json['name'],
      fullName: json['fullName'] ?? json['full_name'],
      description: json['description'],
      htmlUrl: json['htmlUrl'] ?? json['html_url'],
      language: json['language'],
      stargazersCount: json['stargazersCount'] ?? json['stargazers_count'] ?? 0,
      forksCount: json['forksCount'] ?? json['forks_count'] ?? 0,
      openIssuesCount: json['openIssuesCount'] ?? json['open_issues_count'] ?? 0,
      avatarUrl: json['avatarUrl'] ?? (json['owner'] != null ? json['owner']['avatar_url'] : null),
      owner: json['owner'] is String ? json['owner'] : json['owner']['login'],
      isPrivate: json['isPrivate'] ?? json['private'] ?? false,
      isWatched: json['isWatched'] ?? false,
      isStarred: json['isStarred'] ?? false,
      category: json['category'] ?? 'General',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      pushedAt: json['pushedAt'] != null || json['pushed_at'] != null
          ? DateTime.parse(json['pushedAt'] ?? json['pushed_at'])
          : null,
      defaultBranch: json['defaultBranch'] ?? json['default_branch'],
      topics: List<String>.from(json['topics'] ?? []),
    );
  }
}

class GitHubRelease {
  final String id;
  final String repositoryId;
  final String repositoryName;
  final String name;
  final String tagName;
  final String? description;
  final String htmlUrl;
  final bool isPrerelease;
  final bool isDraft;
  final DateTime publishedAt;
  final String author;
  final List<GitHubAsset> assets;

  GitHubRelease({
    required this.id,
    required this.repositoryId,
    required this.repositoryName,
    required this.name,
    required this.tagName,
    this.description,
    required this.htmlUrl,
    this.isPrerelease = false,
    this.isDraft = false,
    required this.publishedAt,
    required this.author,
    this.assets = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repositoryId': repositoryId,
      'repositoryName': repositoryName,
      'name': name,
      'tagName': tagName,
      'description': description,
      'htmlUrl': htmlUrl,
      'isPrerelease': isPrerelease,
      'isDraft': isDraft,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'assets': assets.map((asset) => asset.toJson()).toList(),
    };
  }

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    return GitHubRelease(
      id: json['id'].toString(),
      repositoryId: json['repositoryId'],
      repositoryName: json['repositoryName'],
      name: json['name'],
      tagName: json['tagName'] ?? json['tag_name'],
      description: json['description'] ?? json['body'],
      htmlUrl: json['htmlUrl'] ?? json['html_url'],
      isPrerelease: json['isPrerelease'] ?? json['prerelease'] ?? false,
      isDraft: json['isDraft'] ?? json['draft'] ?? false,
      publishedAt: DateTime.parse(json['publishedAt'] ?? json['published_at']),
      author: json['author'] is String ? json['author'] : json['author']['login'],
      assets: (json['assets'] as List?)
          ?.map((asset) => GitHubAsset.fromJson(asset))
          .toList() ?? [],
    );
  }
}

class GitHubAsset {
  final String id;
  final String name;
  final String downloadUrl;
  final int size;
  final int downloadCount;

  GitHubAsset({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.size,
    required this.downloadCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'downloadUrl': downloadUrl,
      'size': size,
      'downloadCount': downloadCount,
    };
  }

  factory GitHubAsset.fromJson(Map<String, dynamic> json) {
    return GitHubAsset(
      id: json['id'].toString(),
      name: json['name'],
      downloadUrl: json['downloadUrl'] ?? json['browser_download_url'],
      size: json['size'] ?? 0,
      downloadCount: json['downloadCount'] ?? json['download_count'] ?? 0,
    );
  }
}

class GitHubIssue {
  final String id;
  final String repositoryId;
  final String repositoryName;
  final int number;
  final String title;
  final String? description;
  final String state;
  final String htmlUrl;
  final String author;
  final List<String> labels;
  final bool isPullRequest;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;

  GitHubIssue({
    required this.id,
    required this.repositoryId,
    required this.repositoryName,
    required this.number,
    required this.title,
    this.description,
    required this.state,
    required this.htmlUrl,
    required this.author,
    this.labels = const [],
    this.isPullRequest = false,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repositoryId': repositoryId,
      'repositoryName': repositoryName,
      'number': number,
      'title': title,
      'description': description,
      'state': state,
      'htmlUrl': htmlUrl,
      'author': author,
      'labels': labels,
      'isPullRequest': isPullRequest,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
    };
  }

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    return GitHubIssue(
      id: json['id'].toString(),
      repositoryId: json['repositoryId'],
      repositoryName: json['repositoryName'],
      number: json['number'],
      title: json['title'],
      description: json['description'] ?? json['body'],
      state: json['state'],
      htmlUrl: json['htmlUrl'] ?? json['html_url'],
      author: json['author'] is String ? json['author'] : json['user']['login'],
      labels: (json['labels'] as List?)
          ?.map((label) => label is String ? label : label['name'])
          .cast<String>()
          .toList() ?? [],
      isPullRequest: json['isPullRequest'] ?? json['pull_request'] != null,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
      closedAt: json['closedAt'] != null || json['closed_at'] != null
          ? DateTime.parse(json['closedAt'] ?? json['closed_at'])
          : null,
    );
  }
}

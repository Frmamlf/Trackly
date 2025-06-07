import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/github_repository.dart';

class GitHubProvider extends ChangeNotifier {
  List<GitHubRepository> _repositories = [];
  List<GitHubRelease> _releases = [];
  List<GitHubIssue> _issues = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;
  String? _accessToken;

  // Getters
  List<GitHubRepository> get repositories => _repositories;
  List<GitHubRepository> get starredRepositories => 
      _repositories.where((repo) => repo.isStarred).toList();
  List<GitHubRepository> get watchedRepositories => 
      _repositories.where((repo) => repo.isWatched).toList();
  
  List<GitHubRepository> get filteredRepositories {
    if (_selectedCategory == 'All') {
      return _repositories;
    }
    return _repositories.where((repo) => repo.category == _selectedCategory).toList();
  }

  List<String> get categories {
    final categories = {'All', ..._repositories.map((repo) => repo.category)};
    return categories.toList();
  }

  List<GitHubRelease> get allReleases => _releases;
  List<GitHubIssue> get allIssues => _issues;

  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Category management
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Authentication
  void setAccessToken(String token) {
    _accessToken = token;
    notifyListeners();
  }

  // Repository management
  Future<void> addRepository(String owner, String repo, String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final repository = await _fetchRepositoryInfo(owner, repo, category);
      _repositories.add(repository);
      
      await _saveRepositoriesToStorage();
      await refreshRepository(repository.id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<GitHubRepository> _fetchRepositoryInfo(String owner, String repo, String category) async {
    final url = 'https://api.github.com/repos/$owner/$repo';
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      if (_accessToken != null) 'Authorization': 'token $_accessToken',
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch repository information');
    }

    final data = json.decode(response.body);
    return GitHubRepository.fromJson({
      ...data,
      'category': category,
    });
  }

  Future<void> deleteRepository(String repositoryId) async {
    _repositories.removeWhere((repo) => repo.id == repositoryId);
    _releases.removeWhere((release) => release.repositoryId == repositoryId);
    _issues.removeWhere((issue) => issue.repositoryId == repositoryId);
    
    await _saveRepositoriesToStorage();
    await _saveReleasesToStorage();
    await _saveIssuesToStorage();
    notifyListeners();
  }

  Future<void> toggleWatch(String repositoryId) async {
    final index = _repositories.indexWhere((repo) => repo.id == repositoryId);
    if (index != -1) {
      _repositories[index] = _repositories[index].copyWith(
        isWatched: !_repositories[index].isWatched,
      );
      await _saveRepositoriesToStorage();
      notifyListeners();
    }
  }

  Future<void> toggleStar(String repositoryId) async {
    final index = _repositories.indexWhere((repo) => repo.id == repositoryId);
    if (index != -1) {
      _repositories[index] = _repositories[index].copyWith(
        isStarred: !_repositories[index].isStarred,
      );
      await _saveRepositoriesToStorage();
      notifyListeners();
    }
  }

  // Data fetching
  Future<void> refreshRepository(String repositoryId) async {
    try {
      final repo = _repositories.firstWhere((r) => r.id == repositoryId);
      
      // Fetch latest repository info
      await _updateRepositoryInfo(repo);
      
      // Fetch latest releases
      await _fetchRepositoryReleases(repo);
      
      // Fetch latest issues
      await _fetchRepositoryIssues(repo);
      
      notifyListeners();
    } catch (e) {
      print('Error refreshing repository $repositoryId: $e');
    }
  }

  Future<void> _updateRepositoryInfo(GitHubRepository repo) async {
    final url = 'https://api.github.com/repos/${repo.fullName}';
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      if (_accessToken != null) 'Authorization': 'token $_accessToken',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final index = _repositories.indexWhere((r) => r.id == repo.id);
        if (index != -1) {
          _repositories[index] = GitHubRepository.fromJson({
            ...data,
            'category': repo.category,
            'isWatched': repo.isWatched,
            'isStarred': repo.isStarred,
          });
        }
      }
    } catch (e) {
      print('Error updating repository info: $e');
    }
  }

  Future<void> _fetchRepositoryReleases(GitHubRepository repo) async {
    final url = 'https://api.github.com/repos/${repo.fullName}/releases';
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      if (_accessToken != null) 'Authorization': 'token $_accessToken',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        
        // Remove old releases for this repository
        _releases.removeWhere((release) => release.repositoryId == repo.id);
        
        // Add new releases
        for (final releaseData in data.take(10)) { // Limit to latest 10 releases
          final release = GitHubRelease.fromJson({
            ...releaseData,
            'repositoryId': repo.id,
            'repositoryName': repo.fullName,
          });
          _releases.add(release);
        }
        
        _releases.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        await _saveReleasesToStorage();
      }
    } catch (e) {
      print('Error fetching releases: $e');
    }
  }

  Future<void> _fetchRepositoryIssues(GitHubRepository repo) async {
    final url = 'https://api.github.com/repos/${repo.fullName}/issues?state=all&per_page=20';
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      if (_accessToken != null) 'Authorization': 'token $_accessToken',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        
        // Remove old issues for this repository
        _issues.removeWhere((issue) => issue.repositoryId == repo.id);
        
        // Add new issues
        for (final issueData in data) {
          final issue = GitHubIssue.fromJson({
            ...issueData,
            'repositoryId': repo.id,
            'repositoryName': repo.fullName,
          });
          _issues.add(issue);
        }
        
        _issues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        await _saveIssuesToStorage();
      }
    } catch (e) {
      print('Error fetching issues: $e');
    }
  }

  Future<void> refreshAllRepositories() async {
    _isLoading = true;
    notifyListeners();

    for (final repo in _repositories) {
      await refreshRepository(repo.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Storage management
  Future<void> loadRepositories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load repositories
      final repositoriesJson = prefs.getString('github_repositories');
      if (repositoriesJson != null) {
        final repositoriesList = json.decode(repositoriesJson) as List;
        _repositories = repositoriesList.map((json) => GitHubRepository.fromJson(json)).toList();
      }

      // Load releases
      final releasesJson = prefs.getString('github_releases');
      if (releasesJson != null) {
        final releasesList = json.decode(releasesJson) as List;
        _releases = releasesList.map((json) => GitHubRelease.fromJson(json)).toList();
        _releases.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      }

      // Load issues
      final issuesJson = prefs.getString('github_issues');
      if (issuesJson != null) {
        final issuesList = json.decode(issuesJson) as List;
        _issues = issuesList.map((json) => GitHubIssue.fromJson(json)).toList();
        _issues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      // Load access token
      _accessToken = prefs.getString('github_access_token');

      notifyListeners();
    } catch (e) {
      print('Error loading GitHub data: $e');
    }
  }

  Future<void> _saveRepositoriesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final repositoriesJson = json.encode(_repositories.map((repo) => repo.toJson()).toList());
      await prefs.setString('github_repositories', repositoriesJson);
    } catch (e) {
      print('Error saving repositories: $e');
    }
  }

  Future<void> _saveReleasesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final releasesJson = json.encode(_releases.map((release) => release.toJson()).toList());
      await prefs.setString('github_releases', releasesJson);
    } catch (e) {
      print('Error saving releases: $e');
    }
  }

  Future<void> _saveIssuesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final issuesJson = json.encode(_issues.map((issue) => issue.toJson()).toList());
      await prefs.setString('github_issues', issuesJson);
    } catch (e) {
      print('Error saving issues: $e');
    }
  }

  // Search functionality
  List<GitHubRepository> searchRepositories(String query) {
    if (query.isEmpty) return _repositories;
    
    final lowercaseQuery = query.toLowerCase();
    return _repositories.where((repo) =>
        repo.name.toLowerCase().contains(lowercaseQuery) ||
        repo.fullName.toLowerCase().contains(lowercaseQuery) ||
        repo.owner.toLowerCase().contains(lowercaseQuery) ||
        (repo.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        (repo.language?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  List<GitHubRelease> searchReleases(String query) {
    if (query.isEmpty) return _releases;
    
    final lowercaseQuery = query.toLowerCase();
    return _releases.where((release) =>
        release.name.toLowerCase().contains(lowercaseQuery) ||
        release.tagName.toLowerCase().contains(lowercaseQuery) ||
        release.repositoryName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  List<GitHubIssue> searchIssues(String query) {
    if (query.isEmpty) return _issues;
    
    final lowercaseQuery = query.toLowerCase();
    return _issues.where((issue) =>
        issue.title.toLowerCase().contains(lowercaseQuery) ||
        issue.repositoryName.toLowerCase().contains(lowercaseQuery) ||
        issue.author.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/github/providers/github_provider.dart';
import '../../../features/github/models/github_repository.dart';
import '../../widgets/github_repo_card.dart';
import '../../widgets/filter_chips.dart';
import 'github_repo_detail_screen.dart';

class GitHubScreen extends StatefulWidget {
  const GitHubScreen({super.key});

  @override
  State<GitHubScreen> createState() => _GitHubScreenState();
}

class _GitHubScreenState extends State<GitHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load repositories on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GitHubProvider>(context, listen: false).loadRepositories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GitHubProvider>(
      builder: (context, githubProvider, child) {
        return Column(
          children: [
            // Filter chips
            FilterChips(
              categories: githubProvider.categories,
              selectedCategory: githubProvider.selectedCategory,
              onCategorySelected: githubProvider.setSelectedCategory,
            ),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Repositories', icon: Icon(Icons.folder)),
                Tab(text: 'Releases', icon: Icon(Icons.new_releases)),
                Tab(text: 'Issues', icon: Icon(Icons.bug_report)),
                Tab(text: 'Stars', icon: Icon(Icons.star)),
              ],
            ),
            
            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRepositoriesTab(githubProvider),
                  _buildReleasesTab(githubProvider),
                  _buildIssuesTab(githubProvider),
                  _buildStarsTab(githubProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRepositoriesTab(GitHubProvider githubProvider) {
    if (githubProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (githubProvider.repositories.isEmpty) {
      return _buildEmptyState(
        icon: Icons.folder,
        title: 'No Repositories',
        subtitle: 'Add GitHub repositories to start tracking',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/add-repository'),
          icon: const Icon(Icons.add),
          label: const Text('Add Repository'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: githubProvider.refreshAllRepositories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: githubProvider.filteredRepositories.length,
        itemBuilder: (context, index) {
          final repository = githubProvider.filteredRepositories[index];
          return GitHubRepoCard(
            repository: repository,
            onTap: () => _openRepository(repository),
          );
        },
      ),
    );
  }

  Widget _buildReleasesTab(GitHubProvider githubProvider) {
    final releases = githubProvider.allReleases;

    if (releases.isEmpty) {
      return _buildEmptyState(
        icon: Icons.new_releases,
        title: 'No Releases',
        subtitle: 'Track repositories to see their latest releases',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: releases.length,
      itemBuilder: (context, index) {
        final release = releases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.new_releases),
            title: Text(release.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(release.repositoryName),
                Text(release.tagName),
              ],
            ),
            trailing: Text(_formatDate(release.publishedAt)),
            onTap: () => _openRelease(release),
          ),
        );
      },
    );
  }

  Widget _buildIssuesTab(GitHubProvider githubProvider) {
    final issues = githubProvider.allIssues;

    if (issues.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bug_report,
        title: 'No Issues',
        subtitle: 'Track repositories to see their latest issues',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              issue.isPullRequest ? Icons.call_merge : Icons.bug_report,
              color: issue.state == 'open' ? Colors.green : Colors.red,
            ),
            title: Text(issue.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(issue.repositoryName),
                Text('by ${issue.author}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('#${issue.number}'),
                Text(_formatDate(issue.createdAt)),
              ],
            ),
            onTap: () => _openIssue(issue),
          ),
        );
      },
    );
  }

  Widget _buildStarsTab(GitHubProvider githubProvider) {
    final starredRepos = githubProvider.starredRepositories;

    if (starredRepos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star,
        title: 'No Starred Repositories',
        subtitle: 'Star repositories to see them here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: starredRepos.length,
      itemBuilder: (context, index) {
        final repository = starredRepos[index];
        return GitHubRepoCard(
          repository: repository,
          onTap: () => _openRepository(repository),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  void _openRepository(GitHubRepository repository) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GitHubRepoDetailScreen(repository: repository),
      ),
    );
  }

  void _openRelease(GitHubRelease release) {
    Navigator.pushNamed(
      context,
      '/release',
      arguments: release,
    );
  }

  void _openIssue(GitHubIssue issue) {
    Navigator.pushNamed(
      context,
      '/issue',
      arguments: issue,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

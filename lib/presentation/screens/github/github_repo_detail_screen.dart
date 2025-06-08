import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/github/models/github_repository.dart';
import '../../../features/github/providers/github_provider.dart';

class GitHubRepoDetailScreen extends StatelessWidget {
  final GitHubRepository repository;

  const GitHubRepoDetailScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(repository.name),
        actions: [
          Consumer<GitHubProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove Repository'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'open_github',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(width: 8),
                        Text('Open in GitHub'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRepoHeader(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildLatestRelease(context),
            const SizedBox(height: 20),
            _buildRepoDetails(),
            const SizedBox(height: 20),
            _buildLanguages(),
            const SizedBox(height: 20),
            _buildTopics(),
          ],
        ),
      ),
      floatingActionButton: repository.latestRelease != null
          ? FloatingActionButton.extended(
              onPressed: () => _downloadLatestRelease(context),
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            )
          : null,
    );
  }

  Widget _buildRepoHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  repository.isPrivate ? Icons.lock : Icons.public,
                  color: repository.isPrivate ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repository.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (repository.description?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                repository.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(repository.language ?? 'Unknown'),
                  backgroundColor: _getLanguageColor(repository.language),
                ),
                if (repository.license?.isNotEmpty == true)
                  Chip(
                    label: Text(repository.license!),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repository Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.star,
                    'Stars',
                    repository.stargazersCount.toString(),
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.call_split,
                    'Forks',
                    repository.forksCount.toString(),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.bug_report,
                    'Issues',
                    repository.openIssuesCount.toString(),
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.visibility,
                    'Watchers',
                    repository.watchersCount.toString(),
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLatestRelease(BuildContext context) {
    final release = repository.latestRelease;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Latest Release',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (release != null)
                  IconButton(
                    onPressed: () => _downloadLatestRelease(context),
                    icon: const Icon(Icons.download),
                    tooltip: 'Download',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (release != null) ...[
              Row(
                children: [
                  Chip(
                    label: Text(release.tagName),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                  const SizedBox(width: 8),
                  if (release.prerelease)
                    Chip(
                      label: const Text('Pre-release'),
                      backgroundColor: Colors.orange.withOpacity(0.1),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                release.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Released on ${_formatDate(release.publishedAt)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (release.body?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  release.body!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ] else ...[
              Row(
                children: [
                  Icon(Icons.info, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    'No releases available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRepoDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repository Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Owner', repository.owner),
            _buildDetailRow('Created', _formatDate(repository.createdAt)),
            _buildDetailRow('Updated', _formatDate(repository.updatedAt)),
            _buildDetailRow('Size', '${repository.size} KB'),
            _buildDetailRow('Default Branch', repository.defaultBranch ?? 'main'),
            if (repository.homepage?.isNotEmpty == true)
              _buildDetailRow('Homepage', repository.homepage!, isLink: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: () => _launchUrl(value),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguages() {
    if (repository.languages.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Languages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: repository.languages.map((language) => Chip(
                label: Text(language),
                backgroundColor: _getLanguageColor(language),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopics() {
    if (repository.topics.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Topics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: repository.topics.map((topic) => Chip(
                label: Text(topic),
                backgroundColor: Colors.purple.withOpacity(0.1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String? language) {
    switch (language?.toLowerCase()) {
      case 'dart':
        return Colors.blue.withOpacity(0.1);
      case 'flutter':
        return Colors.blue.withOpacity(0.2);
      case 'javascript':
        return Colors.yellow.withOpacity(0.2);
      case 'typescript':
        return Colors.blue.withOpacity(0.3);
      case 'python':
        return Colors.green.withOpacity(0.2);
      case 'java':
        return Colors.orange.withOpacity(0.2);
      case 'kotlin':
        return Colors.purple.withOpacity(0.2);
      case 'swift':
        return Colors.orange.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(BuildContext context, String action, GitHubProvider provider) {
    switch (action) {
      case 'delete':
        _showDeleteConfirmation(context, provider);
        break;
      case 'open_github':
        _launchUrl(repository.htmlUrl);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, GitHubProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Repository'),
        content: Text('Are you sure you want to remove "${repository.name}" from tracking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeRepository(repository.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to GitHub screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${repository.name} removed from tracking')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _downloadLatestRelease(BuildContext context) async {
    final release = repository.latestRelease;
    if (release == null) return;

    try {
      // Try to find the first downloadable asset
      final downloadUrl = release.assets.isNotEmpty 
          ? release.assets.first.downloadUrl 
          : release.tarballUrl;

      if (downloadUrl == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No download URL available')),
          );
        }
        return;
      }

      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download started for ${release.tagName}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open download URL')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error initiating download')),
        );
      }
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

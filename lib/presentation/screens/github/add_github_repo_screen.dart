import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/github/providers/github_provider.dart';
import '../../../features/github/models/github_repository.dart';

class AddGitHubRepoScreen extends StatefulWidget {
  final GitHubRepository? existingRepo;

  const AddGitHubRepoScreen({
    super.key,
    this.existingRepo,
  });

  @override
  State<AddGitHubRepoScreen> createState() => _AddGitHubRepoScreenState();
}

class _AddGitHubRepoScreenState extends State<AddGitHubRepoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _watchReleases = true;
  bool _watchIssues = false;
  bool _notificationsEnabled = true;

  final List<String> _categories = [
    'Frontend',
    'Backend',
    'Mobile',
    'DevOps',
    'Machine Learning',
    'Data Science',
    'Security',
    'Tools',
    'Education',
    'Open Source',
    'Work',
    'Personal',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingRepo != null) {
      _urlController.text = 'https://github.com/${widget.existingRepo!.owner}/${widget.existingRepo!.name}';
      _categoryController.text = widget.existingRepo!.category;
      _notesController.text = widget.existingRepo!.notes ?? '';
      _watchReleases = widget.existingRepo!.watchReleases;
      _watchIssues = widget.existingRepo!.watchIssues;
      _notificationsEnabled = widget.existingRepo!.notificationsEnabled;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingRepo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Repository' : 'Add Repository'),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _deleteRepo,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Repository',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Repository Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repository Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'GitHub Repository URL',
                          hintText: 'https://github.com/owner/repository',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                          helperText: 'Enter the full GitHub repository URL',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a repository URL';
                          }
                          
                          final uri = Uri.tryParse(value!);
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Please enter a valid URL';
                          }
                          
                          if (!uri.host.contains('github.com')) {
                            return 'Please enter a GitHub repository URL';
                          }
                          
                          final pathSegments = uri.pathSegments;
                          if (pathSegments.length < 2) {
                            return 'URL must include owner and repository name';
                          }
                          
                          return null;
                        },
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _categoryController.text.isEmpty ? null : _categoryController.text,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                          helperText: 'Organize your repositories by category',
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _categoryController.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Why are you tracking this repository?',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tracking Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking Options',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Notifications'),
                        subtitle: const Text('Get notified of updates'),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        secondary: const Icon(Icons.notifications),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Watch Releases'),
                        subtitle: const Text('Get notified of new releases'),
                        value: _watchReleases,
                        onChanged: _notificationsEnabled ? (value) {
                          setState(() {
                            _watchReleases = value;
                          });
                        } : null,
                        secondary: const Icon(Icons.new_releases),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Watch Issues'),
                        subtitle: const Text('Get notified of new issues'),
                        value: _watchIssues,
                        onChanged: _notificationsEnabled ? (value) {
                          setState(() {
                            _watchIssues = value;
                          });
                        } : null,
                        secondary: const Icon(Icons.bug_report),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // GitHub Access Token Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'GitHub Access',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'For private repositories or to avoid rate limits, you may need to configure a GitHub access token in Settings.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to settings or show access token dialog
                          _showAccessTokenInfo();
                        },
                        icon: const Icon(Icons.settings, size: 16),
                        label: const Text('Configure Access Token'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  if (!isEditing) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _testRepo,
                        icon: const Icon(Icons.preview),
                        label: const Text('Test Repository'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _saveRepo,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Save Changes' : 'Add Repository'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccessTokenInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GitHub Access Token'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To access private repositories or avoid rate limits:'),
              SizedBox(height: 12),
              Text('1. Go to GitHub Settings > Developer settings > Personal access tokens'),
              SizedBox(height: 8),
              Text('2. Generate a new token with "repo" permissions'),
              SizedBox(height: 8),
              Text('3. Add the token in Trackly Settings > GitHub'),
              SizedBox(height: 12),
              Text('Public repositories work without a token, but with limited API calls.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _testRepo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final githubProvider = context.read<GitHubProvider>();
      final url = _urlController.text.trim();
      
      // Extract owner and repo name from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final owner = pathSegments[0];
      final repoName = pathSegments[1];

      // Test the repository by trying to fetch its info
      await githubProvider.testRepository(owner, repoName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repository test successful! ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to test repository: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveRepo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final githubProvider = context.read<GitHubProvider>();
      final url = _urlController.text.trim();
      
      // Extract owner and repo name from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final owner = pathSegments[0];
      final repoName = pathSegments[1];
      
      if (widget.existingRepo != null) {
        // Update existing repository
        final updatedRepo = widget.existingRepo!.copyWith(
          category: _categoryController.text.trim(),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          watchReleases: _watchReleases,
          watchIssues: _watchIssues,
          notificationsEnabled: _notificationsEnabled,
        );
        
        await githubProvider.updateRepository(updatedRepo);
      } else {
        // Add new repository
        await githubProvider.addRepository(
          owner: owner,
          name: repoName,
          category: _categoryController.text.trim(),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          watchReleases: _watchReleases,
          watchIssues: _watchIssues,
          notificationsEnabled: _notificationsEnabled,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingRepo != null 
                ? 'Repository updated successfully!' 
                : 'Repository added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save repository: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRepo() async {
    if (widget.existingRepo == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Repository'),
        content: const Text('Are you sure you want to remove this repository from tracking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final githubProvider = context.read<GitHubProvider>();
        await githubProvider.removeRepository(widget.existingRepo!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Repository removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove repository: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

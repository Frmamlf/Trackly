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
  bool _isLoading = false;

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
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _categoryController.dispose();
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
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
        // For editing - would need an updateRepository method in provider
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repository editing not yet implemented'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Add new repository using the correct addRepository signature
        await githubProvider.addRepository(
          owner,
          repoName,
          _categoryController.text.trim(),
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
        await githubProvider.deleteRepository(widget.existingRepo!.id);
        
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

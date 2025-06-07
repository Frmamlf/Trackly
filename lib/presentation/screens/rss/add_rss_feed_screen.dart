import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/rss/providers/rss_provider.dart';
import '../../../features/rss/models/rss_feed.dart';

class AddRssFeedScreen extends StatefulWidget {
  final RssFeed? existingFeed;

  const AddRssFeedScreen({
    super.key,
    this.existingFeed,
  });

  @override
  State<AddRssFeedScreen> createState() => _AddRssFeedScreenState();
}

class _AddRssFeedScreenState extends State<AddRssFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingFeed != null) {
      _urlController.text = widget.existingFeed!.url;
      _titleController.text = widget.existingFeed!.title;
      _descriptionController.text = widget.existingFeed!.description ?? '';
      _categoryController.text = widget.existingFeed!.category;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingFeed != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit RSS Feed' : 'Add RSS Feed'),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _deleteFeed,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Feed',
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
              // URL Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feed Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'RSS Feed URL',
                          hintText: 'https://example.com/feed.xml',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a feed URL';
                          }
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        enabled: !isEditing, // Don't allow URL editing
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Title (Optional)',
                          hintText: 'Override feed title',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Custom description for this feed',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organization',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'Tech, News, Sports, etc.',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
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
                        onPressed: _isLoading ? null : _testFeed,
                        icon: const Icon(Icons.preview),
                        label: const Text('Test Feed'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _saveFeed,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Save Changes' : 'Add Feed'),
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

  Future<void> _testFeed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Just validate the URL format for now
      // A proper implementation would make a test HTTP request
      final url = _urlController.text.trim();
      final uri = Uri.tryParse(url);
      
      if (uri == null || !uri.hasAbsolutePath) {
        throw Exception('Invalid URL format');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL format is valid ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to test feed: ${e.toString()}'),
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

  Future<void> _saveFeed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rssProvider = context.read<RssProvider>();
      
      if (widget.existingFeed != null) {
        // For editing, we can't change the URL, so we just update the display info
        // The RSS provider doesn't currently have an update method, so we'll show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feed editing not yet implemented'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Add new feed
        await rssProvider.addFeed(
          _urlController.text.trim(),
          _categoryController.text.trim(),
          title: _titleController.text.trim().isEmpty 
              ? null 
              : _titleController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feed added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save feed: ${e.toString()}'),
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

  Future<void> _deleteFeed() async {
    if (widget.existingFeed == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feed'),
        content: const Text('Are you sure you want to delete this RSS feed? This action cannot be undone.'),
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
        final rssProvider = context.read<RssProvider>();
        await rssProvider.deleteFeed(widget.existingFeed!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feed deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete feed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

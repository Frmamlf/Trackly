import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../features/products/providers/product_provider.dart';
import '../../../features/products/models/product.dart';

class AddProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const AddProductScreen({
    super.key,
    this.existingProduct,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _targetPriceController = TextEditingController();
  bool _isLoading = false;
  String _selectedCurrency = 'USD';

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AED', 'SAR'];
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Health & Beauty',
    'Automotive',
    'Toys & Games',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      _urlController.text = widget.existingProduct!.url;
      _nameController.text = widget.existingProduct!.name;
      _categoryController.text = widget.existingProduct!.category;
      _targetPriceController.text = widget.existingProduct!.targetPrice?.toString() ?? '';
      _selectedCurrency = widget.existingProduct!.currency;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _targetPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _deleteProduct,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Product',
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
              // Product Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'Product URL',
                          hintText: 'https://example.com/product',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a product URL';
                          }
                          if (!Uri.tryParse(value!)?.hasAbsolutePath ?? true) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name (Optional)',
                          hintText: 'Custom name for the product',
                          prefixIcon: Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _categoryController.text.isEmpty ? null : _categoryController.text,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
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
                          hintText: 'Additional notes about this product',
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

              // Price Tracking
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Tracking',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _targetPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Target Price (Optional)',
                                hintText: '99.99',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(),
                              ),
                              items: _currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCurrency = value ?? 'USD';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Price Alerts'),
                        subtitle: const Text('Get notified when price changes'),
                        value: _priceAlertsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _priceAlertsEnabled = value;
                          });
                        },
                        secondary: const Icon(Icons.notifications),
                      ),
                      if (_priceAlertsEnabled) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Price Drop Threshold: ${_priceDropThreshold.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Slider(
                          value: _priceDropThreshold,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          onChanged: (value) {
                            setState(() {
                              _priceDropThreshold = value;
                            });
                          },
                        ),
                        Text(
                          'Alert when price drops by more than ${_priceDropThreshold.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
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
                        onPressed: _isLoading ? null : _testProduct,
                        icon: const Icon(Icons.preview),
                        label: const Text('Test URL'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _saveProduct,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Save Changes' : 'Add Product'),
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

  Future<void> _testProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productProvider = context.read<ProductProvider>();
      
      // Test the URL by trying to scrape it
      await productProvider.testProductUrl(_urlController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product URL test successful! ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to test URL: ${e.toString()}'),
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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productProvider = context.read<ProductProvider>();
      
      if (widget.existingProduct != null) {
        // Update existing product
        final updatedProduct = widget.existingProduct!.copyWith(
          url: _urlController.text.trim(),
          name: _nameController.text.trim().isEmpty 
              ? widget.existingProduct!.name 
              : _nameController.text.trim(),
          category: _categoryController.text.trim(),
          targetPrice: _targetPriceController.text.trim().isEmpty 
              ? null 
              : double.tryParse(_targetPriceController.text.trim()),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          priceAlertsEnabled: _priceAlertsEnabled,
          currency: _selectedCurrency,
          priceDropThreshold: _priceDropThreshold,
        );
        
        await productProvider.updateProduct(updatedProduct);
      } else {
        // Add new product
        await productProvider.addProduct(
          _urlController.text.trim(),
          name: _nameController.text.trim().isEmpty 
              ? null 
              : _nameController.text.trim(),
          category: _categoryController.text.trim(),
          targetPrice: _targetPriceController.text.trim().isEmpty 
              ? null 
              : double.tryParse(_targetPriceController.text.trim()),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          priceAlertsEnabled: _priceAlertsEnabled,
          currency: _selectedCurrency,
          priceDropThreshold: _priceDropThreshold,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingProduct != null 
                ? 'Product updated successfully!' 
                : 'Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: ${e.toString()}'),
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

  Future<void> _deleteProduct() async {
    if (widget.existingProduct == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
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
        final productProvider = context.read<ProductProvider>();
        await productProvider.removeProduct(widget.existingProduct!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete product: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

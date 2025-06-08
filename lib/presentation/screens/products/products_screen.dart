import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/products/providers/enhanced_product_provider.dart';
import '../../../features/products/models/product.dart';
import '../../widgets/enhanced_product_card.dart';
import '../../widgets/filter_chips.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load products on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EnhancedProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedProductProvider>(
      builder: (context, productProvider, child) {
        return Column(
          children: [
            // Filter chips
            FilterChips(
              categories: productProvider.categories,
              selectedCategory: productProvider.selectedCategory,
              onCategorySelected: productProvider.setSelectedCategory,
            ),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Products', icon: Icon(Icons.inventory)),
                Tab(text: 'Price Alerts', icon: Icon(Icons.notifications_active)),
                Tab(text: 'Wishlist', icon: Icon(Icons.favorite)),
              ],
            ),
            
            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllProductsTab(productProvider),
                  _buildPriceAlertsTab(productProvider),
                  _buildWishlistTab(productProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllProductsTab(EnhancedProductProvider productProvider) {
    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory,
        title: 'No Products',
        subtitle: 'Add products to start tracking prices',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/add-product'),
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: productProvider.refreshAllProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: productProvider.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = productProvider.filteredProducts[index];
          return EnhancedProductCard(
            product: product,
            onTap: () => _openProduct(product),
            onToggleWishlist: () => productProvider.toggleWishlist(product.id),
            onToggleAlert: () => productProvider.togglePriceAlert(product.id),
            onToggleStockAlert: () => productProvider.toggleStockAlert(product.id),
            onDelete: () => _deleteProduct(product),
          );
        },
      ),
    );
  }

  Widget _buildPriceAlertsTab(EnhancedProductProvider productProvider) {
    final alertProducts = productProvider.productsWithAlerts;

    if (alertProducts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_active,
        title: 'No Price Alerts',
        subtitle: 'Enable price alerts on products to get notified of price changes',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alertProducts.length,
      itemBuilder: (context, index) {
        final product = alertProducts[index];
        return EnhancedProductCard(
          product: product,
          onTap: () => _openProduct(product),
          onToggleWishlist: () => productProvider.toggleWishlist(product.id),
          onToggleAlert: () => productProvider.togglePriceAlert(product.id),
          onToggleStockAlert: () => productProvider.toggleStockAlert(product.id),
          onDelete: () => _deleteProduct(product),
          showPriceHistory: true,
        );
      },
    );
  }

  Widget _buildWishlistTab(EnhancedProductProvider productProvider) {
    final wishlistProducts = productProvider.wishlistProducts;

    if (wishlistProducts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite,
        title: 'No Wishlist Items',
        subtitle: 'Add products to your wishlist to see them here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlistProducts.length,
      itemBuilder: (context, index) {
        final product = wishlistProducts[index];
        return EnhancedProductCard(
          product: product,
          onTap: () => _openProduct(product),
          onToggleWishlist: () => productProvider.toggleWishlist(product.id),
          onToggleAlert: () => productProvider.togglePriceAlert(product.id),
          onToggleStockAlert: () => productProvider.toggleStockAlert(product.id),
          onDelete: () => _deleteProduct(product),
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

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<EnhancedProductProvider>(context, listen: false)
                  .deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/products/models/product.dart';
import '../../core/theme/app_theme.dart';

class EnhancedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onToggleWishlist;
  final VoidCallback onToggleAlert;
  final VoidCallback onToggleStockAlert;
  final VoidCallback onDelete;
  final VoidCallback? onViewCompetitors;
  final VoidCallback? onViewCoupons;
  final VoidCallback? onViewSimilar;
  final bool showPriceHistory;
  final bool showAdvancedFeatures;

  const EnhancedProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onToggleWishlist,
    required this.onToggleAlert,
    required this.onToggleStockAlert,
    required this.onDelete,
    this.onViewCompetitors,
    this.onViewCoupons,
    this.onViewSimilar,
    this.showPriceHistory = false,
    this.showAdvancedFeatures = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme),
              const SizedBox(height: 16),
              _buildProductContent(context, theme),
              if (showAdvancedFeatures) ...[
                const SizedBox(height: 16),
                _buildAdvancedFeatures(context, theme),
              ],
              const SizedBox(height: 16),
              _buildStatusIndicators(context, theme),
              if (showPriceHistory && product.priceHistory.length > 1) ...[
                const SizedBox(height: 16),
                _buildPriceHistory(context, theme),
              ],
              const SizedBox(height: 12),
              _buildFooter(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.store,
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const Spacer(),
        _buildActionButtons(context, theme),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onToggleWishlist,
          icon: Icon(
            product.isInWishlist ? Icons.favorite : Icons.favorite_border,
            color: product.isInWishlist ? Colors.red : theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: product.isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
        ),
        IconButton(
          onPressed: onToggleAlert,
          icon: Icon(
            product.hasPriceAlert ? Icons.notifications_active : Icons.notifications_none,
            color: product.hasPriceAlert ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: product.hasPriceAlert ? 'Disable price alert' : 'Enable price alert',
        ),
        if (showAdvancedFeatures)
          IconButton(
            onPressed: onToggleStockAlert,
            icon: Icon(
              product.hasStockAlert ? Icons.inventory : Icons.inventory_2_outlined,
              color: product.hasStockAlert ? Colors.orange : theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: product.hasStockAlert ? 'Disable stock alert' : 'Enable stock alert',
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                onDelete();
                break;
              case 'competitors':
                onViewCompetitors?.call();
                break;
              case 'coupons':
                onViewCoupons?.call();
                break;
              case 'similar':
                onViewSimilar?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            if (showAdvancedFeatures && product.competitorPrices.isNotEmpty)
              PopupMenuItem(
                value: 'competitors',
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Compare Prices'),
                  ],
                ),
              ),
            if (showAdvancedFeatures && product.hasActiveCoupons)
              const PopupMenuItem(
                value: 'coupons',
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.green),
                    SizedBox(width: 8),
                    Text('View Coupons'),
                  ],
                ),
              ),
            if (showAdvancedFeatures && product.similarProducts.isNotEmpty)
              const PopupMenuItem(
                value: 'similar',
                child: Row(
                  children: [
                    Icon(Icons.recommend, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Similar Products'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductContent(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(theme),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  product.description!,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              _buildPriceSection(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: product.imageUrl != null
            ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(theme),
              )
            : _buildImagePlaceholder(theme),
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image,
        color: theme.colorScheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '\$${product.currentPrice.toStringAsFixed(2)}',
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              product.currency,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (product.originalPrice != null && product.discountPercentage != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '\$${product.originalPrice!.toStringAsFixed(2)}',
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product.discountPercentage!.toStringAsFixed(0)}% OFF',
                  style: GoogleFonts.rubik(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (product.targetPrice != null) ...[
          const SizedBox(height: 4),
          Text(
            'Target: \$${product.targetPrice!.toStringAsFixed(2)}',
            style: GoogleFonts.rubik(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (showAdvancedFeatures && product.aiPredictedPrice != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.auto_graph,
                size: 16,
                color: Colors.purple,
              ),
              const SizedBox(width: 4),
              Text(
                'AI Prediction: \$${product.aiPredictedPrice!.toStringAsFixed(2)}',
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  color: Colors.purple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedFeatures(BuildContext context, ThemeData theme) {
    final features = <Widget>[];
    
    if (product.hasActiveCoupons) {
      features.add(_buildFeatureChip(
        'Coupons Available',
        Icons.local_offer,
        Colors.green,
        onTap: onViewCoupons,
      ));
    }
    
    if (product.hasBetterPriceElsewhere) {
      final bestPrice = product.bestCompetitorPrice!;
      final savings = product.currentPrice - bestPrice;
      features.add(_buildFeatureChip(
        'Save \$${savings.toStringAsFixed(2)}',
        Icons.compare_arrows,
        Colors.orange,
        onTap: onViewCompetitors,
      ));
    }
    
    if (product.similarProducts.isNotEmpty) {
      features.add(_buildFeatureChip(
        '${product.similarProducts.length} Similar',
        Icons.recommend,
        Colors.blue,
        onTap: onViewSimilar,
      ));
    }
    
    if (product.reviews != null) {
      features.add(_buildRatingChip(product.reviews!, theme));
    }
    
    if (product.shipping?.isFreeShipping == true) {
      features.add(_buildFeatureChip(
        'Free Shipping',
        Icons.local_shipping,
        Colors.teal,
      ));
    }
    
    if (features.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features,
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip(dynamic reviews, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${reviews.averageRating.toStringAsFixed(1)} (${reviews.totalReviews})',
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators(BuildContext context, ThemeData theme) {
    final indicators = <Widget>[];
    
    if (!product.isAvailable || product.isOutOfStock) {
      indicators.add(_buildStatusChip(
        'Out of Stock',
        Colors.red,
        Icons.remove_shopping_cart,
      ));
    } else if (product.stockQuantity != null && product.stockQuantity! < 10) {
      indicators.add(_buildStatusChip(
        'Low Stock (${product.stockQuantity})',
        Colors.orange,
        Icons.warning,
      ));
    }
    
    if (product.isPriceDropped) {
      indicators.add(_buildStatusChip(
        'Price Dropped',
        Colors.green,
        Icons.trending_down,
      ));
    }
    
    if (product.isTargetPriceMet) {
      indicators.add(_buildStatusChip(
        'Target Met',
        Colors.blue,
        Icons.check_circle,
      ));
    }
    
    if (indicators.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: indicators,
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistory(BuildContext context, ThemeData theme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price History',
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildSimplePriceChart(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePriceChart(ThemeData theme) {
    // Simple price trend visualization
    if (product.priceHistory.length < 2) {
      return Center(
        child: Text(
          'Not enough data',
          style: GoogleFonts.rubik(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    
    final prices = product.priceHistory.map((h) => h.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;
    
    if (priceRange == 0) {
      return Center(
        child: Text(
          'Stable price',
          style: GoogleFonts.rubik(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    
    return CustomPaint(
      painter: SimplePriceChartPainter(
        prices: prices,
        minPrice: minPrice,
        maxPrice: maxPrice,
        color: theme.colorScheme.primary,
      ),
      size: const Size.fromHeight(60),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Text(
          'Updated ${_formatDate(product.lastUpdated)}',
          style: GoogleFonts.rubik(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (product.isLinkedToAccount) ...[
          Icon(
            Icons.link,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Linked',
            style: GoogleFonts.rubik(
              fontSize: 11,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
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

class SimplePriceChartPainter extends CustomPainter {
  final List<double> prices;
  final double minPrice;
  final double maxPrice;
  final Color color;
  
  SimplePriceChartPainter({
    required this.prices,
    required this.minPrice,
    required this.maxPrice,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final stepX = size.width / (prices.length - 1);
    final priceRange = maxPrice - minPrice;
    
    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final y = size.height - ((prices[i] - minPrice) / priceRange) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final y = size.height - ((prices[i] - minPrice) / priceRange) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../../features/products/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onToggleWishlist;
  final VoidCallback onToggleAlert;
  final VoidCallback onDelete;
  final bool showPriceHistory;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onToggleWishlist,
    required this.onToggleAlert,
    required this.onDelete,
    this.showPriceHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with store and actions
              Row(
                children: [
                  Chip(
                    label: Text(
                      product.store,
                      style: const TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleWishlist,
                    icon: Icon(
                      product.isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: product.isInWishlist ? Colors.red : null,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    onPressed: onToggleAlert,
                    icon: Icon(
                      product.hasPriceAlert ? Icons.notifications_active : Icons.notifications_none,
                      color: product.hasPriceAlert ? Theme.of(context).colorScheme.primary : null,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: onDelete,
                        child: const Row(
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
              ),
              
              const SizedBox(height: 12),
              
              // Product content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (product.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        
                        // Price information
                        Row(
                          children: [
                            Text(
                              '\$${product.currentPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: product.isPriceDropped
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            
                            if (product.discountPercentage != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${product.discountPercentage!.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        if (product.originalPrice != null && product.originalPrice! > product.currentPrice) ...[
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.originalPrice!.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                        
                        if (product.targetPrice != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 16,
                                color: product.isTargetPriceMet ? Colors.green : null,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Target: \$${product.targetPrice!.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: product.isTargetPriceMet ? Colors.green : null,
                                  fontWeight: product.isTargetPriceMet ? FontWeight.bold : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              // Status indicators
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!product.isAvailable)
                    Chip(
                      label: const Text('Out of Stock'),
                      backgroundColor: Colors.red.withOpacity(0.1),
                      side: const BorderSide(color: Colors.red),
                    ),
                  
                  if (product.isPriceDropped)
                    Chip(
                      label: const Text('Price Dropped'),
                      backgroundColor: Colors.green.withOpacity(0.1),
                      side: const BorderSide(color: Colors.green),
                    ),
                  
                  if (product.isTargetPriceMet)
                    Chip(
                      label: const Text('Target Met'),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      side: const BorderSide(color: Colors.blue),
                    ),
                  
                  const Spacer(),
                  
                  Text(
                    'Updated ${_formatDate(product.lastUpdated)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              // Price history chart (if enabled)
              if (showPriceHistory && product.priceHistory.length > 1) ...[
                const SizedBox(height: 12),
                Container(
                  height: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildPriceChart(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_bag),
    );
  }

  Widget _buildPriceChart() {
    // Simple line chart representation
    return CustomPaint(
      painter: PriceChartPainter(product.priceHistory),
      child: Container(),
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

class PriceChartPainter extends CustomPainter {
  final List<PriceHistory> priceHistory;

  PriceChartPainter(this.priceHistory);

  @override
  void paint(Canvas canvas, Size size) {
    if (priceHistory.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    final maxPrice = priceHistory.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final minPrice = priceHistory.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    for (int i = 0; i < priceHistory.length; i++) {
      final x = (i / (priceHistory.length - 1)) * size.width;
      final y = size.height - ((priceHistory[i].price - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

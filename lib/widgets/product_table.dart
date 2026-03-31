import 'package:flutter/material.dart';

import '../models/product_table_item.dart';
import '../screens/webview_screen.dart';

/// 以卡片形式展示产品表格数据
class ProductTable extends StatelessWidget {
  final List<ProductTableItem> products;

  const ProductTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products.map((p) => _ProductCard(product: p)).toList(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductTableItem product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: product.titleUrl != null
          ? () => WebViewScreen.open(context, url: product.titleUrl!, title: product.title)
          : null,
      child: Card(
      color: colorScheme.surface,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ImagePlaceholder(
                          colorScheme: colorScheme,
                        ),
                      )
                    : _ImagePlaceholder(colorScheme: colorScheme),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.salesVolume,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.source,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ImagePlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported,
        color: colorScheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}

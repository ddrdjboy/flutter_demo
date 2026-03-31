import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.network(
              item.product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, size: 32, color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(item.product.currentPrice, style: textTheme.titleSmall?.copyWith(color: colorScheme.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.outlined(
                      onPressed: () => onQuantityChanged(item.quantity - 1),
                      icon: const Icon(Icons.remove, size: 16),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}', style: textTheme.bodyLarge),
                    ),
                    IconButton.outlined(
                      onPressed: () => onQuantityChanged(item.quantity + 1),
                      icon: const Icon(Icons.add, size: 16),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    const Spacer(),
                    IconButton(onPressed: onRemove, icon: Icon(Icons.delete_outline, color: colorScheme.error)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

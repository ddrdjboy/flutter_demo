import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListenableBuilder(
        listenable: CartService(),
        builder: (context, _) {
          final cart = CartService();
          if (cart.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse products and add items to your cart',
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return CartItemTile(
                      item: item,
                      onQuantityChanged: (qty) => cart.updateQuantity(item.product, qty),
                      onRemove: () => cart.removeItem(item.product),
                    );
                  },
                ),
              ),
              // Price summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Text('${cart.totalCount} items', style: textTheme.bodyLarge),
                      const Spacer(),
                      Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}', style: textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartBadge extends StatelessWidget {
  final Widget child;

  const CartBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService(),
      builder: (context, _) {
        final count = CartService().totalCount;
        if (count == 0) return child;
        return Badge.count(count: count, child: child);
      },
    );
  }
}

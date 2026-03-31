import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Subtotal: parses currentPrice string (e.g. "$17.84") to double.
  /// Returns 0.0 for PriceType.seeInCart or if parsing fails.
  double get subtotal {
    if (product.priceType == PriceType.seeInCart) return 0.0;
    final cleaned = product.currentPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    return (double.tryParse(cleaned) ?? 0.0) * quantity;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product.title == other.product.title;

  @override
  int get hashCode => product.title.hashCode;
}

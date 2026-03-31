import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// 购物车服务，全局单例，通过 ChangeNotifier 通知状态变化
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  /// 添加商品到购物车，若已存在则数量+1
  void addItem(Product product) {
    final index = _items.indexWhere((item) => item.product.title == product.title);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  /// 更新商品数量，quantity <= 0 时移除
  void updateQuantity(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.title == product.title);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }
    notifyListeners();
  }

  /// 移除商品
  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.title == product.title);
    notifyListeners();
  }

  /// 清空购物车
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

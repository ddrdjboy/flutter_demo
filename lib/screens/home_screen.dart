import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_repository.dart';
import '../widgets/product_card_list.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_nav.dart';
import '../widgets/recently_viewed_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = ProductRepository();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _repository.getRecommendedProducts();
    if (mounted) setState(() { _products = products; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              final recent = await _repository.getRecentlyViewed();
              if (mounted && recent.isNotEmpty) {
                RecentlyViewedSheet.show(context, recent);
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView(
                children: [
                  const PromoBanner(),
                  const CategoryNav(),
                  const SizedBox(height: 8),
                  ..._products.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ProductCardList(
                      product: p,
                      onAddToCart: () => CartService().addItem(p),
                    ),
                  )),
                ],
              ),
            ),
    );
  }
}

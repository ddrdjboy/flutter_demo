import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_card_list.dart';

class RecentlyViewedSheet extends StatelessWidget {
  final List<Product> products;

  const RecentlyViewedSheet({super.key, required this.products});

  static show1(BuildContext context, List<Product> products) {}

  static Future<void> show(BuildContext context, List<Product> products) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecentlyViewedSheet(products: products),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                offset: Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              // Divider space
              const SizedBox(height: 8),
              // Product list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => _buildDivider(),
                  itemBuilder: (_, index) => ProductCardList(
                    product: products[index],
                    onAddToCart: () {
                      // Handle add to cart
                    },
                  ),
                ),
              ),
              // Footer with home indicator
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Recently viewed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 24 / 18,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
          // Close button
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 24),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 12),
      child: Container(height: 1, color: const Color(0xFFF0F0F0)),
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 21),
            Center(
              child: Container(
                width: 144,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

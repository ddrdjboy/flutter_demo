import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_flag.dart';

class ProductCardList extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;

  const ProductCardList({super.key, required this.product, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with flag overlay
          _buildImageSection(),
          const SizedBox(width: 12),
          // Card body
          Expanded(child: _buildCardBody()),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          // Product image
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F7),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_outlined,
                size: 48,
                color: Color(0xFFCCCCCC),
              ),
            ),
          ),
          // Flag overlay
          if (product.flagText != null && product.flagType != null)
            Positioned(
              top: 0,
              left: 0,
              child: ProductFlag(
                text: product.flagText!,
                type: product.flagType!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        Text(
          product.brand,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        // Title
        Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        // Rating
        _buildRating(),
        const SizedBox(height: 8),
        // Price
        _buildPrice(),
        const SizedBox(height: 4),
        // Add to cart button
        _buildAddButton(),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.rating.toString(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 16 / 12,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.star, size: 16, color: Color(0xFFF5A623)),
        const SizedBox(width: 2),
        Text(
          '(${_formatReviewCount(product.reviewCount)})',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    switch (product.priceType) {
      case PriceType.discount:
        return Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              product.currentPrice,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 24 / 18,
                color: Color(0xFFCA2222),
              ),
            ),
            if (product.originalPrice != null)
              Text(
                product.originalPrice!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                  color: Color(0xFF666666),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        );
      case PriceType.trial:
        return Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              product.currentPrice,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 24 / 18,
                color: Color(0xFF2C7500),
              ),
            ),
            if (product.originalPrice != null)
              Text(
                product.originalPrice!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                  color: Color(0xFF666666),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        );
      case PriceType.seeInCart:
        return Row(
          children: [
            const Text(
              'See price in cart',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 20 / 14,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 16, color: Colors.grey[700]),
          ],
        );
      case PriceType.regular:
        return Text(
          product.currentPrice,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 24 / 18,
            color: Color(0xFF333333),
          ),
        );
    }
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 48,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 32,
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF38A00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 20 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      final formatted = count.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      return formatted;
    }
    return count.toString();
  }
}

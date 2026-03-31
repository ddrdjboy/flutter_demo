class Product {
  final String brand;
  final String title;
  final double rating;
  final int reviewCount;
  final String currentPrice;
  final String? originalPrice;
  final String? flagText;
  final FlagType? flagType;
  final PriceType priceType;
  final String imageUrl;

  const Product({
    required this.brand,
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.currentPrice,
    this.originalPrice,
    this.flagText,
    this.flagType,
    this.priceType = PriceType.regular,
    required this.imageUrl,
  });
}

enum FlagType { special, tryIt, saveInCart }

enum PriceType { regular, discount, trial, seeInCart }

import '../models/product.dart';

/// 商品数据仓库，封装数据获取和缓存逻辑
/// 当前阶段使用本地 mock 数据，后续可替换为真实 API
class ProductRepository {
  static const _sampleProducts = [
    Product(
      brand: 'Ultima Replenisher',
      title:
          '6 Essential Electrolytes, Daily Electrolyte Drink Mix, Original Variety Pack, 20 Stickpacks, 0.13 oz (3.7 g)',
      rating: 4.6,
      reviewCount: 188,
      currentPrice: '\$17.84',
      originalPrice: '\$20.99',
      flagText: 'Special!',
      flagType: FlagType.special,
      priceType: PriceType.discount,
      imageUrl:
          'https://www.figma.com/api/mcp/asset/5f4ab273-30c3-441e-a895-3ae7bbefa668',
    ),
    Product(
      brand: 'Lemme',
      title: 'Sleep Tight Gummies, Berry, 60 Gummies',
      rating: 4.6,
      reviewCount: 116,
      currentPrice: '\$30.00',
      priceType: PriceType.regular,
      imageUrl:
          'https://www.figma.com/api/mcp/asset/407a59ad-be7f-40f7-a9a2-85ab05279989',
    ),
    Product(
      brand: 'Bloom Kids',
      title: 'Greens & Superfoods + Multivitamin, Tropical Punch,',
      rating: 4.6,
      reviewCount: 4,
      currentPrice: '\$39.99',
      priceType: PriceType.regular,
      flagText: 'Save 10% in cart',
      flagType: FlagType.saveInCart,
      imageUrl:
          'https://www.figma.com/api/mcp/asset/da56ca5e-5ce0-47cc-8637-e9a9d5c53dc8',
    ),
    Product(
      brand: 'iHerb Goods',
      title:
          'Strada, Insulated Stainless Steel Blender Bottle, Green, 24 oz (710 ml)',
      rating: 4.8,
      reviewCount: 666,
      currentPrice: '\$15.00',
      originalPrice: '\$25.00',
      flagText: 'Try it!',
      flagType: FlagType.tryIt,
      priceType: PriceType.trial,
      imageUrl:
          'https://www.figma.com/api/mcp/asset/daa1995b-1d46-4088-8e84-235ecbfa431e',
    ),
    Product(
      brand: 'Nordic Naturals',
      title:
          "Children's DHA Gummy Chews, Ages 3+, Tropical Punch, 600 mg, 30 Gummies",
      rating: 4.9,
      reviewCount: 10564,
      currentPrice: '',
      priceType: PriceType.seeInCart,
      imageUrl:
          'https://www.figma.com/api/mcp/asset/2129d679-cf3b-4cc4-a84f-bfb1dc1c9b7a',
    ),
  ];

  final List<Product> _recentlyViewed = [];

  /// 获取推荐商品列表
  Future<List<Product>> getRecommendedProducts() async {
    return _sampleProducts;
  }

  /// 搜索商品（在 brand 和 title 中不区分大小写匹配）
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _sampleProducts
        .where((p) =>
            p.brand.toLowerCase().contains(lowerQuery) ||
            p.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 获取商品详情（按 title 查找）
  Future<Product?> getProductDetail(String title) async {
    try {
      return _sampleProducts.firstWhere((p) => p.title == title);
    } catch (_) {
      return null;
    }
  }

  /// 获取最近浏览商品
  Future<List<Product>> getRecentlyViewed() async {
    return List.unmodifiable(_recentlyViewed);
  }

  /// 添加到最近浏览
  void addToRecentlyViewed(Product product) {
    _recentlyViewed.removeWhere((p) => p.title == product.title);
    _recentlyViewed.insert(0, product);
    if (_recentlyViewed.length > 10) {
      _recentlyViewed.removeLast();
    }
  }
}

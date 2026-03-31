class ProductTableItem {
  final String title;
  final String? titleUrl;
  final String? imageUrl;
  final String price;
  final String salesVolume;
  final String source;

  const ProductTableItem({
    required this.title,
    this.titleUrl,
    this.imageUrl,
    required this.price,
    required this.salesVolume,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'titleUrl': titleUrl,
        'imageUrl': imageUrl,
        'price': price,
        'salesVolume': salesVolume,
        'source': source,
      };

  factory ProductTableItem.fromJson(Map<String, dynamic> json) {
    return ProductTableItem(
      title: json['title'] as String,
      titleUrl: json['titleUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      price: json['price'] as String,
      salesVolume: json['salesVolume'] as String,
      source: json['source'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductTableItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          titleUrl == other.titleUrl &&
          imageUrl == other.imageUrl &&
          price == other.price &&
          salesVolume == other.salesVolume &&
          source == other.source;

  @override
  int get hashCode =>
      title.hashCode ^
      titleUrl.hashCode ^
      imageUrl.hashCode ^
      price.hashCode ^
      salesVolume.hashCode ^
      source.hashCode;
}

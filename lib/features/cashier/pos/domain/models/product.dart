class Product {
  const Product({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.tag,
  });

  final String id;
  final String category;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final String? tag;

  factory Product.fromApi(Map<String, dynamic> json) {
    final categoryValue = json['category'] ?? json['cat'];
    final category = categoryValue is Map
        ? (categoryValue['name'] ?? 'Lainnya').toString()
        : (categoryValue ?? 'Lainnya').toString();
    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.round()
        : (double.tryParse(rawPrice?.toString() ?? '') ?? 0).round();
    return Product(
      id: (json['id'] ?? '').toString(),
      category: category,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? json['desc'] ?? '').toString(),
      price: price,
      imageUrl: (json['image_url'] ?? json['image'] ?? json['img'] ?? '')
          .toString(),
      tag: json['tag']?.toString(),
    );
  }
}

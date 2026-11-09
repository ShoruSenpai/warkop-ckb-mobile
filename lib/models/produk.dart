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
}

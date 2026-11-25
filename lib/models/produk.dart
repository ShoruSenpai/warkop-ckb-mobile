class Product {
  const Product({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.tag,
    this.availableQuantity,
  });

  final String id;
  final String category;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final String? tag;
  final int? availableQuantity;

  factory Product.fromJson(Map<String, dynamic> data) => Product(
    id: data['id'].toString(),
    category: data['category'] as String? ?? 'Umum',
    name: data['name'] as String,
    description: data['description'] as String? ?? '',
    price: (data['price'] as num).toInt(),
    imageUrl: data['image_url'] as String? ?? '',
    availableQuantity: (data['available_quantity'] as num?)?.toInt(),
    tag: data['available_quantity'] == 0
        ? 'Stok habis / resep belum siap'
        : null,
  );
}

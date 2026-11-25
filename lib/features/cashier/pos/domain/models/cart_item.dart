class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.variant,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String variant;
  final int price;
  final int quantity;

  int get totalPrice => price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      variant: variant,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

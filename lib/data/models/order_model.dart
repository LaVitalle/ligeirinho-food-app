class OrderItemModel {
  final String productName;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

class OrderModel {
  final String id;
  final String storeId;
  final String storeName;
  final String? storeLogo;
  final List<OrderItemModel> items;
  final double total;
  final OrderStatus status;
  final String pickupTime;
  final String paymentMethod;
  final DateTime createdAt;
  final double? rating;

  const OrderModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    this.storeLogo,
    required this.items,
    required this.total,
    required this.status,
    required this.pickupTime,
    required this.paymentMethod,
    required this.createdAt,
    this.rating,
  });
}

enum OrderStatus { pending, preparing, ready, done }

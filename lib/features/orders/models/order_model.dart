class OrderModel {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'PENDING',
      total: (json['total'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

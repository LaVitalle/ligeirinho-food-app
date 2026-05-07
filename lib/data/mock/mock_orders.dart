import '../models/order_model.dart';

export '../models/order_model.dart';

final List<OrderModel> mockOpenOrders = [
  OrderModel(
    id: '#842',
    storeId: 's2',
    storeName: 'Burguer Mania',
    items: [
      const OrderItemModel(productName: 'Te Combo Burguer e Batata Miinha', quantity: 1, price: 45.00),
      const OrderItemModel(productName: '1x Refrigerante Lata', quantity: 1, price: 6.00),
    ],
    total: 74.90,
    status: OrderStatus.preparing,
    pickupTime: '12:30 - 13:00',
    paymentMethod: 'PIX',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  OrderModel(
    id: '#843',
    storeId: 's1',
    storeName: 'Cantina Central',
    items: [
      const OrderItemModel(productName: '3x Salgado de Fritas com Requeijão', quantity: 3, price: 8.00),
      const OrderItemModel(productName: '1x Suco de Laranja 200ml', quantity: 1, price: 8.00),
    ],
    total: 32.00,
    status: OrderStatus.pending,
    pickupTime: '13:00 - 13:30',
    paymentMethod: 'Cartão',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
];

final List<OrderModel> mockOrderHistory = [
  OrderModel(
    id: '#810',
    storeId: 's3',
    storeName: 'Pizzaria Bella Italia',
    items: [
      const OrderItemModel(productName: '1x Pizza Margherita G', quantity: 1, price: 78.90),
    ],
    total: 78.90,
    status: OrderStatus.done,
    pickupTime: '12:00 - 12:30',
    paymentMethod: 'PIX',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    rating: 4.5,
  ),
  OrderModel(
    id: '#795',
    storeId: 's4',
    storeName: 'Sushi House',
    items: [
      const OrderItemModel(productName: '1x Combo Executivo 20 peças', quantity: 1, price: 45.00),
    ],
    total: 45.00,
    status: OrderStatus.done,
    pickupTime: '12:30 - 13:00',
    paymentMethod: 'Cartão',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    rating: 3.0,
  ),
  OrderModel(
    id: '#780',
    storeId: 's5',
    storeName: 'Açaí do Porto',
    items: [
      const OrderItemModel(productName: '1x Açaí com morango e Leite Ninho', quantity: 1, price: 22.00),
    ],
    total: 22.00,
    status: OrderStatus.done,
    pickupTime: '14:00 - 14:30',
    paymentMethod: 'PIX',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    rating: 5.0,
  ),
];

// Vendor panel orders
class VendorOrderModel {
  final String id;
  final String customerName;
  final String time;
  final List<String> items;
  final int waitingMinutes;
  final OrderStatus status;

  const VendorOrderModel({
    required this.id,
    required this.customerName,
    required this.time,
    required this.items,
    required this.waitingMinutes,
    required this.status,
  });
}

final List<VendorOrderModel> mockVendorOrders = [
  const VendorOrderModel(
    id: '#842',
    customerName: 'Lucas Silva',
    time: '12:45',
    items: ['1x Combo Universitário (X-Burguer + Batata)', '1x Suco de Laranja 300ml'],
    waitingMinutes: 5,
    status: OrderStatus.pending,
  ),
  const VendorOrderModel(
    id: '#843',
    customerName: 'Mariana Oliveira',
    time: '12:30',
    items: ['2x Coxinha de Frango com Catupiry', '1x Refrigerante Lata 300ml'],
    waitingMinutes: 13,
    status: OrderStatus.pending,
  ),
  const VendorOrderModel(
    id: '#830',
    customerName: 'Ricardo Mendes',
    time: '12:10',
    items: ['1x Marmita Fit G (Frango Grelhado)'],
    waitingMinutes: 29,
    status: OrderStatus.pending,
  ),
];

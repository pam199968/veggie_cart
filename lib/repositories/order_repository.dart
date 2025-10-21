import '../models/delivery_method.dart';
import '../models/order_item.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  final OrderService service;

  OrderRepository({required this.service});

  /// 🔹 Flux temps réel pour toutes les commandes avec filtre optionnel sur le statut
  Stream<List<OrderModel>> streamAllOrders({List<OrderStatus>? statuses}) {
    return service.streamAllOrders(statuses: statuses);
  }

  /// 🔹 Pagination pour toutes les commandes avec filtre optionnel sur le statut
  Future<List<OrderModel>> fetchAllOrders({
    int limit = 20,
    OrderModel? startAfter,
    List<OrderStatus>? statuses, // 🔹 nouveau paramètre
  }) async {
    return service.getAllOrdersPaginated(
      limit: limit,
      startAfter: startAfter,
      statuses: statuses,
    );
  }

  /// 🔹 Mise à jour du statut d’une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    return service.updateOrderStatus(orderId, status);
  }

  /// 🔹 Flux temps réel pour les commandes d’un client
  Stream<List<OrderModel>> streamOrdersForCustomer(String customerId) {
    return service.streamOrdersByCustomer(customerId: customerId);
  }

  /// 🔹 Pagination pour les commandes d’un client
  Future<List<OrderModel>> fetchOrdersForCustomer({
    required String customerId,
    int limit = 20,
    OrderModel? startAfter,
  }) async {
    return service.getOrdersByCustomerPaginated(
      customerId: customerId,
      limit: limit,
      startAfter: startAfter,
    );
  }

  /// 🔹 Création de commande via le service
  Future<OrderModel> createOrder({
    required String customerId,
    required WeeklyOfferSummary offerSummary,
    required DeliveryMethod deliveryMethod,
    List<OrderItem> items = const [],
    OrderStatus status = OrderStatus.pending,
    String? notes,
  }) async {
    return service.createOrder(
      customerId: customerId,
      offerSummary: offerSummary,
      deliveryMethod: deliveryMethod,
      items: items,
      status: status,
      notes: notes,
    );
  }
}

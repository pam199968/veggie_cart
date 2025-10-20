import '../services/order_service.dart';
import '../models/order_model.dart';

class OrderRepository {
  final OrderService service;

  OrderRepository({required this.service});

  Stream<List<OrderModel>> streamOrdersForCustomer(String customerId) {
    return service.streamOrdersByCustomer(customerId: customerId);
  }

  Future<List<OrderModel>> fetchOrdersForCustomer({
    required String customerId,
    int limit = 20,
    OrderModel? startAfter,
  }) async {
    // Ici tu peux utiliser ton service pour faire une requête paginée
    // Firestore ne supporte pas vraiment "limit + startAfter" sur un stream directement,
    // mais tu peux l’implémenter côté service avec .startAfterDocument()
    return service.getOrdersByCustomerPaginated(
      customerId: customerId,
      limit: limit,
      startAfter: startAfter,
    );
  }
}

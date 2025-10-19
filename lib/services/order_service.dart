import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final CollectionReference _ordersRef =
      FirebaseFirestore.instance.collection('orders');

  /// 🔹 Créer une nouvelle commande
  Future<void> createOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).set(order.toMap());
  }

  /// 🔹 Récupérer une commande par son ID
  Future<OrderModel?> getOrderById(String id) async {
    final doc = await _ordersRef.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data, doc.id);
  }

  /// 🔹 Récupérer toutes les commandes
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot =
        await _ordersRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// 🔹 Mettre à jour une commande
  Future<void> updateOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).update(order.toMap());
  }

  /// 🔹 Supprimer une commande
  Future<void> deleteOrder(String id) async {
    await _ordersRef.doc(id).delete();
  }

  /// 🔹 Flux temps réel de commandes
  Stream<List<OrderModel>> streamOrders() {
    return _ordersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// 🔹 Exemple de filtre par client
  Stream<List<OrderModel>> streamOrdersByCustomer(String customerId) {
    return _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}

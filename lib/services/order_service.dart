import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final CollectionReference _ordersRef =
      FirebaseFirestore.instance.collection('orders');

<<<<<<< HEAD
=======
  /// 🔹 Créer une nouvelle commande
>>>>>>> 172df15 (order model added)
  Future<void> createOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).set(order.toMap());
  }

<<<<<<< HEAD
=======
  /// 🔹 Récupérer une commande par son ID
>>>>>>> 172df15 (order model added)
  Future<OrderModel?> getOrderById(String id) async {
    final doc = await _ordersRef.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data, doc.id);
  }

<<<<<<< HEAD
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _ordersRef.orderBy('createdAt', descending: true).get();
=======
  /// 🔹 Récupérer toutes les commandes
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot =
        await _ordersRef.orderBy('createdAt', descending: true).get();
>>>>>>> 172df15 (order model added)
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

<<<<<<< HEAD
=======
  /// 🔹 Mettre à jour une commande
>>>>>>> 172df15 (order model added)
  Future<void> updateOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).update(order.toMap());
  }

<<<<<<< HEAD
=======
  /// 🔹 Supprimer une commande
>>>>>>> 172df15 (order model added)
  Future<void> deleteOrder(String id) async {
    await _ordersRef.doc(id).delete();
  }

<<<<<<< HEAD
=======
  /// 🔹 Flux temps réel de commandes
>>>>>>> 172df15 (order model added)
  Stream<List<OrderModel>> streamOrders() {
    return _ordersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
<<<<<<< HEAD
=======

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
>>>>>>> 172df15 (order model added)
}

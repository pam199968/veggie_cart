import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final CollectionReference _ordersRef =
      FirebaseFirestore.instance.collection('orders');

  Future<void> createOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).set(order.toMap());
  }

  Future<OrderModel?> getOrderById(String id) async {
    final doc = await _ordersRef.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data, doc.id);
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _ordersRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> updateOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).update(order.toMap());
  }

  Future<void> deleteOrder(String id) async {
    await _ordersRef.doc(id).delete();
  }

  Stream<List<OrderModel>> streamOrders() {
    return _ordersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}

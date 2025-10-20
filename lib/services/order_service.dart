import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final CollectionReference _ordersRef =
      FirebaseFirestore.instance.collection('orders');

  CollectionReference get ordersRef => _ordersRef;

  /// 🔹 Flux temps réel paginé par client
  Stream<List<OrderModel>> streamOrdersByCustomer({
    required String customerId,
    int limit = 10,
    DocumentSnapshot? startAfterDoc,
  }) {
    Query query = _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<List<OrderModel>> getOrdersByCustomerPaginated({
    required String customerId,
    int limit = 20,
    OrderModel? startAfter,
  }) async {
    Query query = _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      final doc = await _ordersRef.doc(startAfter.id).get();
      query = query.startAfterDocument(doc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// 🔹 Récupère une seule page (sans flux) pour le scroll infini
  Future<List<OrderModel>> fetchOrdersPage({
    required String customerId,
    int limit = 10,
    DocumentSnapshot? startAfterDoc,
  }) async {
    Query query = _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}

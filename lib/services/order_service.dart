import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_method.dart';
import '../models/order_item.dart';
import '../models/order_model.dart';
import '../models/vegetable_model.dart';

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

extension OrderServiceExtension on OrderService {
  /// Crée une commande et génère automatiquement orderNumber à partir de l'ID Firestore
  Future<OrderModel> createOrder({
    required String customerId,
    required WeeklyOfferSummary offerSummary,
    required DeliveryMethod deliveryMethod,
    OrderStatus status = OrderStatus.pending,
    String? notes,
    required List<OrderItem> items, // 🔹 changé de VegetableModel à OrderItem
  }) async {
    final newOrderRef = _ordersRef.doc();
    final orderNumber = _generateOrderNumber(newOrderRef.id);
    final now = DateTime.now();

    final order = OrderModel(
      id: newOrderRef.id,
      orderNumber: orderNumber,
      customerId: customerId,
      offerSummary: offerSummary,
      deliveryMethod: deliveryMethod,
      status: status,
      notes: notes,
      items: items, // 🔹 on passe directement la liste d'OrderItem
      createdAt: now,
      updatedAt: now,
    );

    await newOrderRef.set(order.toMap());

    return order;
  }

  /// Génération du numéro de commande lisible
  String _generateOrderNumber(String firestoreId) {
    final datePart = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
    final idPart = firestoreId.substring(firestoreId.length - 4).toUpperCase();
    return 'CMD-$datePart-$idPart';
  }
}

